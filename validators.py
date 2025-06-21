import re

def is_valid_remote_state_value(field, value):
    # Storage Account Name: 3-24 chars, lowercase letters and numbers only
    if field == "storage_account_name":
        if not re.match(r'^[a-z0-9]{3,24}$', value):
            return False
        return True
    # Resource Group Name: 1-90 chars, alfanumeric, -, _ (nu începe/termină cu -)
    if field == "resource_group_name":
        if not re.match(r'^[a-zA-Z0-9-_]{1,90}$', value):
            return False
        if value.startswith('-') or value.endswith('-'):
            return False
        if value.isdigit():
            return False
        return True
    # Container Name: 3-63 chars, lowercase, numbers, dash (nu începe/termină cu dash, nu dublu dash)
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

    if variable_type == "string":
        if not isinstance(default_value, str):
            return False
        if default_value.strip() == "":
            return False
        if default_value != default_value.strip():
            return False

        if "password" in var_name or "secret" in var_name:
            return True

        if "id" in var_name and not any(x in var_name for x in ["storage", "account", "name"]):
            return True

        if "location" in var_name:
            return True

        if "resource_group_name" in var_name:
            if not re.match(r'^[a-zA-Z0-9-_]+$', default_value):
                return False
            if default_value.startswith("-") or default_value.endswith("-"):
                return False
            if default_value.isdigit():
                return False
            if len(default_value) > 90:
                return False
            return True

        if "db_name" in var_name:
            # Must start with a lowercase letter and contain only lowercase letters, numbers, and underscores
            if not re.match(r'^[a-z][a-z0-9_]{0,62}$', default_value):
                return False
            return True

        if "storage_account_name" in var_name:
            if not re.match(r'^[a-z0-9]{3,24}$', default_value):
                return False
            return True

        if "username" in var_name:
            if not re.match(r'^\w+$', default_value):
                return False
            return True

        if "app_name" in var_name or "aks_cluster_name" in var_name:
            if not re.match(r'^[a-zA-Z0-9-]+$', default_value):
                return False
            if default_value.startswith("-") or default_value.endswith("-"):
                return False
            return True

        if re.search(r'[^a-zA-Z0-9\-_ ]', default_value):
            return False
        if default_value.startswith("-") or default_value.endswith("-"):
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

    return False
