from pathlib import Path
from openai import OpenAI
import os
import re
import hcl2
import ast
from variables import BACKEND_CONFIG
from validators import is_valid_default_value

# === CONFIG ===
INFRA_PATH = Path.cwd()
API_KEY = os.getenv("OPENAI_API_KEY") or "your_key"
OUTPUT_PATH = INFRA_PATH / "terragrunt.hcl"
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

def collect_inputs_from_modules(modules):
    collected = {}
    for module in modules:
        module_inputs = {}
        variables_file = module / "variables.tf"
        if not variables_file.exists():
            print(f"⚠️ No variables.tf found for module: {module.name}")
            continue

        variables = parse_variables_tf(variables_file)
        print(f"\n📥 Variables for module: {module.name}")

        for var in variables:
            var_name = var['name']
            var_type = var['type']
            default_val = var["default"]

            if default_val is not None:
                print(f"Default for {var_name}: {default_val}")

            while True:
                val = input(f"Enter value for {var_name} ({var['description']}) [ENTER to keep default]: ").strip()

                # Dacă userul apasă ENTER și avem default valid
                if val == "" and default_val is not None:
                    if is_valid_default_value(var_name, var_type, default_val):
                        module_inputs[var_name] = default_val
                        print(f"✅ Using default for {var_name}: {default_val}")
                        break
                    else:
                        print(f"❌ Default for {var_name} is invalid for type {var_type}. Please enter manually.")

                # Dacă userul introduce o valoare
                elif val != "":
                    if var_type == "number":
                        try:
                            module_inputs[var_name] = float(val)
                            break
                        except ValueError:
                            print(f"❌ Invalid number for {var_name}. Try again.")
                    elif var_type == "bool":
                        if val.lower() in ["true", "false"]:
                            module_inputs[var_name] = val.lower() == "true"
                            break
                        else:
                            print(f"❌ Invalid boolean. Enter 'true' or 'false'.")
                    elif var_type.startswith("list"):
                        try:
                            parsed_list = ast.literal_eval(val)
                            if isinstance(parsed_list, list):
                                module_inputs[var_name] = parsed_list
                                break
                            else:
                                print(f"❌ Input is not a valid list. Example: ['item1', 'item2']")
                        except Exception:
                            print(f"❌ Invalid list syntax. Example: ['item1', 'item2']")
                    else:  # String
                        if is_valid_default_value(var_name, var_type, val):
                            module_inputs[var_name] = val
                            break
                        else:
                            print(f"❌ Invalid string for {var_name}. Cannot be empty or contain leading/trailing spaces.")

                else:
                    print(f"❌ Please enter a value for {var_name}. Cannot skip if no default exists.")

        collected.update(module_inputs)
    return collected

def clean_code_fences(hcl_str):
    cleaned = re.sub(r"^```(?:hcl)?\s*", "", hcl_str.strip())
    cleaned = re.sub(r"\s*```$", "", cleaned)
    return cleaned.strip()

def build_prompt(selected_modules, inputs_block):
    backend_block = f'''
generate "backend" {{
  path      = "backend.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
terraform {{
  backend "azurerm" {{
    resource_group_name  = "{BACKEND_CONFIG['resource_group_name']}"
    storage_account_name = "{BACKEND_CONFIG['storage_account_name']}"
    container_name       = "{BACKEND_CONFIG['container_name']}"
    key                  = "{BACKEND_CONFIG['key']}"
    access_key  ="{BACKEND_CONFIG['access_key']}"
  }}
}}
EOF
}}
'''

    provider_block = f'''
generate "provider" {{
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {{
  required_version = ">= 1.0"
  required_providers {{
    azurerm = {{
      source  = "hashicorp/azurerm"
      version = "~> 4.34.0"
    }}
  }}
}}

provider "azurerm" {{
  features {{}}
  subscription_id = "{BACKEND_CONFIG['subscription_id']}"
}}
EOF
}}
'''

    module_names = ', '.join([m.name for m in selected_modules])

    prompt = f"""
You are a Terraform and Terragrunt expert.

Your task:
Generate the **full and final content** of a single file called `terragrunt.hcl` for my Azure infrastructure project.

Sections (in exact order):

1. ✅ Backend block  
Use exactly the following block (no modifications allowed):

{backend_block}

2. ✅ Provider block  
Include exactly this provider block (no modifications allowed):

{provider_block}

3. ✅ Inputs block  
After the provider block, add a single inputs block with the following variables:

{inputs_block}

Rules for inputs block:
- Keep variable names EXACTLY as given above.
- Do NOT rename, reformat, or alter them.
- Quote all string values with double quotes.
- For lists, use correct HCL syntax (e.g., ["item1", "item2"]).
- Do not add comments or explanations.
- Output MUST be pure, production-ready HCL. No markdown, no code fences.

Modules included: {module_names}
"""

    return prompt

def format_inputs_block(inputs):
    formatted = "inputs = {\n"
    for key, val in inputs.items():
        if isinstance(val, list):
            list_items = ', '.join([f'"{item}"' for item in val])
            formatted += f'  {key} = [{list_items}]\n'
        else:
            formatted += f'  {key} = "{val}"\n'
    formatted += "}\n"
    return formatted

def main():
    modules = get_available_modules()
    print("\n📦 Available modules:")
    for i, mod in enumerate(modules, 1):
        print(f"{i}. {mod.name}")

    while True:
        selection = input("\n👉 Which modules do you want to include? (Type numbers separated by commas, or 'all' for all modules): ").strip()
        if selection.lower() == "all":
            selected = modules
            break
        else:
            try:
                indices = [int(i.strip()) for i in selection.split(",") if i.strip().isdigit()]
                if all(0 < i <= len(modules) for i in indices):
                    selected = [modules[i - 1] for i in indices]
                    break
                else:
                    print("❌ Invalid selection. Please enter valid module numbers.")
            except ValueError:
                print("❌ Invalid input. Please enter numbers like 1,2,3 or 'all'.")

    user_inputs = collect_inputs_from_modules(selected)
    inputs_block = format_inputs_block(user_inputs)

    prompt = build_prompt(selected, inputs_block)
    print("\n⏳ Sending prompt to OpenAI...")

    response = openai_client.chat.completions.create(
        model="gpt-4o",
        messages=[{"role": "user", "content": prompt}],
        temperature=0.1,
        max_tokens=2000
    )

    hcl_content = response.choices[0].message.content
    hcl_content = clean_code_fences(hcl_content)

    OUTPUT_PATH.write_text(hcl_content)
    print(f"\n✅ terragrunt.hcl written successfully at: {OUTPUT_PATH}\n")

    # Afișare comenzi deploy
    print("📢 Deployment commands you can now run:\n")
    print("terragrunt refresh")
    included_dirs = ' '.join([f'--terragrunt-include-dir \"{m.name}\"' for m in selected])
    print(f"terragrunt run-all init {included_dirs}")
    print(f"terragrunt run-all plan {included_dirs} -lock=false")
    print(f"terragrunt run-all apply {included_dirs} -lock=false")

if __name__ == "__main__":
    main()
