# To prevent github token from being placed in source control, we use environment variables
# Note, the .gitignore for the project ignores the .terraform.tfstate and .terraform.tfstate.backup by default 
# to prevent commiting sensitive terraform state info (like github token)
# See this issue (where I have commented on, and is STILL OPEN years later about solutions to this state file dilemma): https://github.com/hashicorp/terraform/issues/516

# In a shell, run the following:
# export TF_VAR_github_oauth_token=<token goes here>
repo_owner = "stelligent"
repo_name = "miniproject-REICHERT-BEN"
branch = "master"
poll_source_changes = true