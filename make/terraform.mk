.PHONY: \
	init \
	fmt \
	fmt-check \
	validate \
	tflint \
	tfsec \
	checkov \
	security \
	plan \
	apply \
	destroy \
	clean

init:
	terraform -chdir=$(TF_DIR) init

fmt:
	terraform fmt -recursive $(TF_ROOT)

fmt-check:
	terraform fmt -check -recursive $(TF_ROOT)

validate: init
	terraform -chdir=$(TF_DIR) validate

tflint:
	tflint --chdir=$(TF_DIR) --recursive

tfsec:
	tfsec $(TF_ROOT)

checkov:
	checkov --directory $(TF_ROOT) --framework terraform --compact

security: tflint tfsec checkov

plan: validate
	terraform -chdir=$(TF_DIR) plan -out=$(PLAN_FILE)

apply:
	terraform -chdir=$(TF_DIR) apply $(PLAN_FILE)

destroy:
	terraform -chdir=$(TF_DIR) destroy

clean:
	rm -rf $(TF_DIR)/.terraform
	rm -f $(TF_DIR)/$(PLAN_FILE)
