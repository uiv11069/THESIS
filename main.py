from pathlib import Path
import re
import os
from openai import OpenAI
import hcl2

# === CONFIG ===
INFRA_PATH = Path.cwd()


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
                })
    return variables

def collect_user_inputs(modules):
    collected = {}
    for module in modules:
        print(f"\n📥 Variables for module: {module.name}")
        variables = parse_variables_tf(module / "variables.tf")
        mod_inputs = {}
        for var in variables:
            prompt_text = f"{var['name']} ({var['description']})"
            if var["default"] is not None:
                prompt_text += f" [default: {var['default']}]"
            prompt_text += ": "
            val = input(prompt_text).strip()
            if val == "" and var["default"] is not None:
                mod_inputs[var["name"]] = var["default"]
            elif val == "" and var["default"] is None:
                print(f"⚠️  {var['name']} has no default. Please enter a value.")
                val = input(f"{var['name']}: ").strip()
                mod_inputs[var["name"]] = val
            else:
                mod_inputs[var["name"]] = val
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
