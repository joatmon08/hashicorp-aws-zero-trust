FROM vault:1.8.5

RUN mkdir -p /vault-agent
COPY agent.hcl /vault-agent/agent.hcl
COPY entrypoint.sh ./entrypoint.sh

ENTRYPOINT [ "sh", "./entrypoint.sh" ]