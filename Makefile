compose_file := .devcontainer/docker-compose.yml
project_name := puppeteer-automation_devcontainer

clean:
	docker-compose -f ${compose_file} -p ${project_name} down --volumes
