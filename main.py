from pathlib import Path
import re
import os
from openai import OpenAI
import hcl2
from validators import is_valid_default_value, is_valid_remote_state_value

# === CONFIG ===
INFRA_PATH = Path.cwd()
API_KEY = os.getenv("OPENAI_API_KEY") or ""
OUTPUT_PATH = INFRA_PATH / "root.hcl"
openai_client = OpenAI(api_key=API_KEY)

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

def collect_remote_state_inputs():
    print("\n🔒 Set remote_state backend values for Azure storage (leave empty for default):")
    while True:
        resource_group_name = input("Resource group name [default: thesisRG]: ").strip() or "thesisRG"
        if is_valid_remote_state_value("resource_group_name", resource_group_name):
            break
        print("❌ Invalid resource group name. Must be 1-90 chars, alphanum/-/_ (not starting/ending with dash).")
    while True:
        storage_account_name = input("Storage account name [default: thesisstorage]: ").strip() or "thesisstorage"
        if is_valid_remote_state_value("storage_account_name", storage_account_name):
            break
        print("❌ Invalid storage account name. Must be 3-24 chars, only lowercase letters and numbers.")
    while True:
        container_name = input("Container name [default: tfstate]: ").strip() or "tfstate"
        if is_valid_remote_state_value("container_name", container_name):
            break
        print("❌ Invalid container name. Must be 3-63 chars, lowercase, numbers, dash, not start/end with dash or contain double dash.")
    key = input("State file key [default: terragrunt.tfstate]: ").strip() or "terragrunt.tfstate"
    return resource_group_name, storage_account_name, container_name, key

def get_remote_state_block(resource_group, storage_account, container, key):
    return f'''
remote_state {{
  backend = "azurerm"
  config = {{
    resource_group_name  = "{resource_group}"
    storage_account_name = "{storage_account}"
    container_name       = "{container}"
    key                  = "{key}"
  }}
}}
'''

def clean_code_fences(hcl_str):
    # Elimină orice block de tip ``` sau ```hcl de la început/sfârșit
    cleaned = re.sub(r"^```(?:hcl)?\s*", "", hcl_str.strip())
    cleaned = re.sub(r"\s*```$", "", cleaned)
    return cleaned.strip()

def query_openai_for_terragrunt(modules, inputs, remote_state_block):
    # Detectăm dacă avem un singur modul
    single_module = len(modules) == 1
    inputs_block = format_prefixed_inputs(modules, inputs)
    dependencies_block = format_dependencies(modules) if len(modules) > 1 else ""

    # Numim explicit ce vrem, pe scurt și la obiect:
    prompt = f"""
You are a Terraform and Terragrunt expert.

Your task:
Generate the **complete content** for a file named **root.hcl** to be used as the root Terragrunt configuration for my infrastructure, running on Azure.

Rules:
- The file name must be **root.hcl**.
- The first block in the file must always be the remote_state block below (no changes).
- If there is only one module, do NOT add any dependency block.
- If there are two or more modules, add one dependency block for EACH selected module, but NEVER point a dependency block to root.hcl or to the module itself.
- After remote_state (and dependencies, if any), add a single global inputs block containing all variables, each prefixed with the module name (lowercase).
- Quote ALL string values with double quotes.
- The generated HCL must be valid, ready to use and complete.
- **Return ONLY raw HCL code. DO NOT return code fences, backticks, comments, explanations, or any extra text.**
- List values (e.g., `["10.0.0.0/16"]`) must appear as valid HCL lists, not strings that look like lists.
Context:
- Selected module(s): {', '.join([m.name for m in modules])}
- remote_state block:

{remote_state_block}

{f"{dependencies_block}" if dependencies_block else ""}

inputs block:

{inputs_block}

Remember: Do NOT include any dependency block if there is only one module. The output must be production-ready and valid.
"""

    response = openai_client.chat.completions.create(
        model="gpt-4o",
        messages=[{"role": "user", "content": prompt}],
        temperature=0.1,
        max_tokens=1800
    )
    hcl_content = response.choices[0].message.content
    hcl_content = clean_code_fences(hcl_content)
    return hcl_content


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

    # Collect remote_state info (Azure backend) with validation
    resource_group, storage_account, container, key = collect_remote_state_inputs()
    remote_state_block = get_remote_state_block(resource_group, storage_account, container, key)

    print("\n⏳ Sending prompt to OpenAI...")
    terragrunt_hcl = query_openai_for_terragrunt(selected, user_inputs, remote_state_block)
    print("DEBUG: OpenAI response:\n", terragrunt_hcl)
    print("✅ Response received.")

    if validate_hcl(terragrunt_hcl):
        OUTPUT_PATH.write_text(terragrunt_hcl)
        print(f"✅ root.hcl written to: {OUTPUT_PATH}")
    else:
        print("❌ root.hcl was not saved due to validation failure.")

# === RUN ===
if __name__ == "__main__":
    main()
