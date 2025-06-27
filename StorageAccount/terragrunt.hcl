
include "root" {
  path = find_in_parent_folders("terragrunt.hcl")
  expose = true # Expose variables from the root include
}


terraform {
  source = "."
}



