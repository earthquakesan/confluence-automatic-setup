docker network create ${DOCKER_NETWORK_NAME} -d bridge

# Render config.yaml to /home/user/config.yaml
cat <<EOF > /home/user/config.yaml
cluster_name: "confluence"
verbose: true
audit: false
insecure_skip_verify: false
scrape_enabled_label: "prometheus.io/scrape"
scrape_services: true
scrape_endpoints: false
require_scrape_enabled_label_for_nodes: true
targets:
  - description: Confluence Server
    urls: ["http://confluence:8090/plugins/servlet/prometheus/metrics"]
EOF

docker run -d \
    --name confluence \
    --network ${DOCKER_NETWORK_NAME} \
    --restart unless-stopped \
    -v confluence-data:/var/atlassian/confluence \
    -p 8090:8090 \
    xalt/confluence:nightly-7.19.5

docker run -d \
    --name postgres \
    --network ${DOCKER_NETWORK_NAME} \
    --restart unless-stopped \
    -v postgres-data:/var/lib/postgresql/data \
    --env POSTGRES_USER=${POSTGRES_USER} \
    --env POSTGRES_PASSWORD=${POSTGRES_PASSWORD} \
    --env POSTGRES_DB=${POSTGRES_DB} \
    postgres:15.1

docker run -d \
    --name newrelic-docker \
    --network ${DOCKER_NETWORK_NAME} \
    --restart unless-stopped \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v /:/host:ro \
    --env NRIA_LICENSE_KEY=${NRIA_LICENSE_KEY} \
    --pid host \
    --cap-add SYS_PTRACE \
    --privileged \
    newrelic/infrastructure:latest

docker run -d \
    --name newrelic-prometheus-nri \
    --network ${DOCKER_NETWORK_NAME} \
    --restart unless-stopped \
    -v /home/user/config.yaml:/config.yaml \
    -v /:/host:ro \
    --env LICENSE_KEY=${NRIA_LICENSE_KEY} \
    newrelic/nri-prometheus:1.5
