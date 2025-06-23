import re
import ast

def is_valid_remote_state_value(field, value):
    if field == "storage_account_name":
        if not re.match(r'^[a-z0-9]{3,24}$', value):
            return False
        return True
    if field == "resource_group_name":
        if not re.match(r'^[a-zA-Z0-9-_]{1,90}$', value):
            return False
        if value.startswith('-') or value.endswith('-'):
            return False
        if value.isdigit():
            return False
        return True
    if field == "container_name":
        if not re.match(r'^[a-z0-9-]{3,63}$', value):
            return False
        if value.startswith('-') or value.endswith('-'):
            return False
        if '--' in value:
            return False
        return True
    return False

def is_valid_default_value(variable_name: str, variable_type: str, default_value) -> bool:
    variable_type = variable_type.strip().lower()
    var_name = variable_name.lower()

    # --- DEBUG: vezi exact cum arata valoarea si tipul pentru list ---
    if variable_type.startswith("list"):
        print(f"[DEBUG] address_space: {default_value} (type: {type(default_value)})")

    if variable_type == "string":
        if not isinstance(default_value, str):
            return False
        if default_value.strip() == "":
            return False
        if default_value != default_value.strip():
            return False
        return True

    elif variable_type == "number":
        try:
            float(default_value)
            return True
        except ValueError:
            return False

    elif variable_type == "bool":
        return str(default_value).lower() in ("true", "false")

    elif variable_type.startswith("${list"):
        return True
    return False
