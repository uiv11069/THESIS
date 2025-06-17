from pathlib import Path
import re
import os
from openai import OpenAI
import hcl2
from validators import is_valid_default_value


# === CONFIG ===
INFRA_PATH = Path.cwd()
API_KEY = os.getenv("OPENAI_API_KEY") or "your-API-key"
OUTPUT_PATH = INFRA_PATH / "terragrunt.hcl"
openai_client = OpenAI(api_key=API_KEY)

# === UTILS ===

def get_available_modules():
    return sorted([
        p for p in INFRA_PATH.iterdir()
        if p.is_dir() and (p / "main.tf").exists()
    ])

def parse_variables_tf(variables_tf_path):
    variables = []
    with open(variables_tf_path, "r") as f:
        obj = hcl2.load(f)
        for var in obj.get("variable", []):
            for name, props in var.items():
                variables.append({
                    "name": name,
                    "description": props.get("description", ""),
                    "default": props.get("default", None),
                    "type": props.get("type", "string")
                })
    return variables

# def is_valid_default_value(variable_name: str, variable_type: str, default_value) -> bool:
#     variable_type = variable_type.strip().lower()

#     if variable_type == "string":
#         if not isinstance(default_value, str):
#             return False
#         if default_value.strip() == "":
#             return False
#         if default_value != default_value.strip():
#             return False

#         var_name = variable_name.lower()

#         # ✅ Allow anything for password, secret
#         if "password" in var_name or "secret" in var_name:
#             return True

#         # ✅ Allow anything for Azure IDs (like subnet_id, vnet_id, etc.)
#         if "id" in var_name and not any(x in var_name for x in ["storage", "account", "name"]):
#             return True

#         # ✅ Allow anything for location
#         if "location" in var_name:
#             return True

#         # ❌ Restrictive rules for other strings
#         if re.search(r'[^a-zA-Z0-9\-_ ]', default_value):
#             return False
#         if default_value.startswith("-") or default_value.endswith("-"):
#             return False
#         if "storage" in var_name or "account" in var_name:
#             if "-" in default_value:
#                 return False
#             if not default_value.islower():
#                 return False
#         return True

#     elif variable_type == "number":
#         try:
#             float(default_value)
#             return True
#         except ValueError:
#             return False

#     elif variable_type == "bool":
#         return str(default_value).lower() in ("true", "false")

#     return False


def collect_user_inputs(modules):
    collected = {}
    for module in modules:
        print(f"\n📥 Variables for module: {module.name}")
        variables = parse_variables_tf(module / "variables.tf")
        mod_inputs = {}
        for var in variables:
            default_valid = (
                var["default"] is not None and
                is_valid_default_value(var["name"], var["type"], var["default"])
            )

            prompt_text = f"{var['name']} ({var['description']})"
            if default_valid:
                prompt_text += f" [default: {var['default']}]"
            prompt_text += ": "

            val = input(prompt_text).strip()

            if val == "":
                if default_valid:
                    mod_inputs[var["name"]] = var["default"]
                else:
                    print(f"❌ The default value '{var['default']}' is not valid for {var['name']}.")
                    while True:
                        val = input(f"Please enter a valid value for {var['name']}: ").strip()
                        if is_valid_default_value(var["name"], var["type"], val):
                            mod_inputs[var["name"]] = val
                            break
                        else:
                            print("❌ Invalid value. Please try again.")
            else:
                if is_valid_default_value(var["name"], var["type"], val):
                    mod_inputs[var["name"]] = val
                else:
                    print("❌ Invalid value.")
                    while True:
                        val = input(f"Please enter a valid value for {var['name']}: ").strip()
                        if is_valid_default_value(var["name"], var["type"], val):
                            mod_inputs[var["name"]] = val
                            break
        collected[module.name] = mod_inputs
    return collected

def format_prefixed_inputs(modules, inputs):
    formatted = ""
    for module in modules:
        values = inputs[module.name]
        mod_prefix = module.name.lower().replace(" ", "_")
        for k, v in values.items():
            key = f"{mod_prefix}_{k}"
            if isinstance(v, dict):
                formatted += f'  {key} = {{\n'
                for dk, dv in v.items():
                    formatted += f'    {dk} = "{dv}"\n'
                formatted += f'  }}\n'
            else:
                formatted += f'  {key} = "{v}"\n'
    return formatted

def format_dependencies(modules):
    blocks = ""
    for module in modules:
        blocks += f'''
dependency "{module.name}" {{
  config_path = "${{path_relative_from_include()}}/{module.name}"
}}
'''
    return blocks

def query_openai_for_terragrunt(modules, inputs):
    dependencies_block = format_dependencies(modules)
    inputs_block = format_prefixed_inputs(modules, inputs)

    prompt = f"""
You are a Terraform and Terragrunt expert.

Generate a single `terragrunt.hcl` file that:

- Includes dependency blocks for each module listed below
- Includes a single global `inputs` block containing all the inputs for these modules
- All variable names must be prefixed with the module name (lowercase), e.g., 'db_location'
- The infrastructure is deployed on Azure
- All values must be quoted properly
- Do NOT include triple backticks or explanations
- Only return valid HCL

Return only the content of the terragrunt.hcl file without code fences (no ```hcl), comments, or explanations. Just raw HCL.

Dependencies:
{dependencies_block}

Inputs:
{inputs_block}
"""

    response = openai_client.chat.completions.create(
        model="gpt-4o",
        messages=[{"role": "user", "content": prompt}],
        temperature=0.1,
        max_tokens=1500
    )
    return response.choices[0].message.content

def validate_hcl(hcl_text):
    try:
        from io import StringIO
        hcl2.load(StringIO(hcl_text))
        return True
    except Exception as e:
        print(f"❌ Invalid HCL: {e}")
        return False

def main():
    modules = get_available_modules()
    print("\n📦 Available modules:")
    for i, mod in enumerate(modules, 1):
        print(f"{i}. {mod.name}")

    selection = input("\nWhich modules do you want Terragrunt generated for? (e.g., 1,3,5 or 'all'): ").strip()
    if selection.lower() == "all":
        selected = modules
    else:
        indices = [int(i.strip()) for i in selection.split(",") if i.strip().isdigit()]
        selected = [modules[i - 1] for i in indices if 0 < i <= len(modules)]

    user_inputs = collect_user_inputs(selected)

    print("\n⏳ Sending prompt to OpenAI...")
    terragrunt_hcl = query_openai_for_terragrunt(selected, user_inputs)
    print("✅ Response received.")

    if validate_hcl(terragrunt_hcl):
        OUTPUT_PATH.write_text(terragrunt_hcl)
        print(f"✅ terragrunt.hcl written to: {OUTPUT_PATH}")
    else:
        print("❌ terragrunt.hcl was not saved due to validation failure.")

# === RUN ===
if __name__ == "__main__":
    main()
