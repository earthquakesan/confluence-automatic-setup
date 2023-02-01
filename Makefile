compose_file := .devcontainer/docker-compose.yml
project_name := puppeteer-automation_devcontainer

GIT_BRANCH=$(shell git rev-parse --abbrev-ref HEAD)

include .env

clean:
	docker-compose -f ${compose_file} -p ${project_name} down --volumes

TF_INIT_DIR=terraform_init
TF_INIT_PLAN_FILE=init.tfplan
TF_RUN_INIT=terraform -chdir=${TF_INIT_DIR}

s3-bucket-init:
	$(TF_RUN_INIT) init -reconfigure
	$(TF_RUN_INIT) plan -var "bucket_name=${TF_STATE_BUCKET_NAME}" -out=${TF_INIT_PLAN_FILE}
	$(TF_RUN_INIT) apply ${TF_INIT_PLAN_FILE}

s3-bucket-destroy:
	$(TF_RUN_INIT) init -reconfigure
	$(TF_RUN_INIT) plan -destroy -var "bucket_name=${TF_STATE_BUCKET_NAME}" -out=${TF_INIT_PLAN_FILE}
	$(TF_RUN_INIT) apply ${TF_INIT_PLAN_FILE}

TF_DIR=terraform
TF_RUN=terraform -chdir=${TF_DIR}
TF_PLAN_FILE=apply.tfplan
ENV_LOCATION=environment

render-user-data:
	rm -f ${TF_DIR}/.user_data.sh
	cat ${TF_DIR}/user_data_init.sh > ${TF_DIR}/.user_data.sh
	cat ${TF_DIR}/user_data_docker_run.sh | envsubst >> ${TF_DIR}/.user_data.sh

tf-init:
	$(TF_RUN) init -reconfigure \
		-backend-config="bucket=${TF_STATE_BUCKET_NAME}" \
		-backend-config="key=${TF_STATE_BUCKET_KEY}" \
		-backend-config="region=${AWS_REGION}"

tf-plan: tf-init
	$(TF_RUN) plan -var-file=../${ENV_LOCATION}/${ENV}.tfvars -out=${TF_PLAN_FILE}

tf-apply: tf-plan
	$(TF_RUN) apply ${TF_PLAN_FILE}

tf-destroy: tf-init
	$(TF_RUN) plan -destroy -var-file=../${ENV_LOCATION}/${ENV}.tfvars -out=${TF_PLAN_FILE}
	$(TF_RUN) apply ${TF_PLAN_FILE}

tf-show: tf-init
	$(TF_RUN) show

tf-get-ip-address: tf-init
	$(TF_RUN) output -raw server_ip > ip_address.tmp

connect:
	ssh user@$(shell cat ip_address.tmp)
