
.PHONY: init
init:
	cd terraform; terraform init --backend-config backend_config/aws.tfvars

.PHONY: plan
plan:
	cd terraform; terraform plan --var-file tfvars_files/aws.tfvars

.PHONY: apply
apply:
	cd terraform ; terraform apply -var-file tfvars_files/aws.tfvars --auto-approve

.PHONY: deploy-aws
deploy-aws:
	cd terraform ; \
	terraform init --backend-config backend_config/aws.tfvars; \
	terraform apply -var-file tfvars_files/aws.tfvars --auto-approve

.PHONY: destroy-aws
destroy-aws:
	cd terraform ; \
	terraform init --backend-config backend_config/aws.tfvars; \
	terraform destroy -var-file tfvars_files/aws.tfvars --auto-approve