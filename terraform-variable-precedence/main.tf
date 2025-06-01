output "demo_var_value" {
  value = var.demo_var
}


//Show env variable first before tfvars file to demonstrate precedence

//export TF_VAR_demo_var="env_value"
//terraform apply -auto-approve
//$env:TF_VAR_demo_var = "env_value"

//Showcase cli precedence
//tf apply -var=demo_var="test_demo" --auto-approve