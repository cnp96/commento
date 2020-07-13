#!/bin/bash

nodes=$NODES
servers=(${nodes//,/ })
host=""
PEM_FILE=".temp.pem"
APP_ENV_FILE=".env"

# Decode base64
decode_b64() {
  echo -e $@ | base64 -d
  [[ $? -ne 0 ]] && exit 1
}

# Execute command in remote server via SSH
exec_ssh() {
  echo -e "\n**** Executing ****"
  echo $@
  ssh -o StrictHostKeyChecking=no -o ConnectTimeout=1 -i $PEM_FILE $host $@
}

exec_scp() {
  echo -e "\n**** Copying ****"
  echo $@
  scp -o StrictHostKeyChecking=no -o ConnectTimeout=1 -i $PEM_FILE $@ $host:~
}

# Deploy to list of servers
deploy() {
  local container_name=$(echo $CI_PROJECT_TITLE | awk '{print tolower($0)}')
  local result

  for i in "${!servers[@]}"; do
    host="ubuntu@${servers[i]}"
    echo -e "Info: Deploying on server $host"

    # Docker login in the remote machine
    exec_ssh $DOCKER_LOGIN_CMD

    failed=0
    exec_scp $APP_ENV_FILE $APP_ENV_FILE
    if [[ $? -ne 0 ]]; then
      echo "Error: Copy env failed!"
      failed=1

    else
      create_docker_compose_file
      exec_scp "docker-compose.yml" "docker-compose.yml"
      if [[ $? -ne 0 ]]; then
        echo "Error: Copy compose file failed!"
        failed=1

      else
        exec_ssh "docker pull $CI_REGISTRY_IMAGE:latest"
        if [[ $? -ne 0 ]]; then
          echo "Error: Pull latest tag failed!"
          failed=1

        else
          exec_ssh "[[ \$(docker ps -q --filter 'name=comments_db') == '' ]] && docker-compose up --force-recreate -d comments_db"
          exec_ssh "docker-compose up --force-recreate -d comments_server"
          if [[ $? -ne 0 ]]; then
            echo "Error: Start Comments API service failed!"
            failed=1
          else
            echo "Success: $host All comments services are operational!"
          fi
        fi
      fi
    fi

    if [[ failed -eq 1 ]]; then
      echo "Error: Deployment on Node $host -- failed!"
      return 1
    fi

  done
}

# Application Env
create_env_file() {
  echo "Creating env file -- "$APP_ENV_FILE
  echo -e "COMMENTO_ORIGIN=$(decode_b64 $COMMENTO_ORIGIN)" >$APP_ENV_FILE
  echo -e "COMMENTO_PORT=$(decode_b64 $COMMENTO_PORT)" >>$APP_ENV_FILE

  echo -e "COMMENTO_SMTP_HOST=$(decode_b64 $COMMENTO_SMTP_HOST)" >>$APP_ENV_FILE
  echo -e "COMMENTO_SMTP_PORT=$(decode_b64 $COMMENTO_SMTP_PORT)" >>$APP_ENV_FILE
  echo -e "COMMENTO_SMTP_USERNAME=$(decode_b64 $COMMENTO_SMTP_USERNAME)" >>$APP_ENV_FILE
  echo -e "COMMENTO_SMTP_PASSWORD=$(decode_b64 $COMMENTO_SMTP_PASSWORD)" >>$APP_ENV_FILE
  echo -e "COMMENTO_SMTP_FROM_ADDRESS=$(decode_b64 $COMMENTO_SMTP_FROM_ADDRESS)" >>$APP_ENV_FILE

  echo -e "COMMENTO_GOOGLE_KEY=$(decode_b64 $COMMENTO_GOOGLE_KEY)" >>$APP_ENV_FILE
  echo -e "COMMENTO_GOOGLE_SECRET=$(decode_b64 $COMMENTO_GOOGLE_SECRET)" >>$APP_ENV_FILE
  echo -e "COMMENTO_GITHUB_KEY=$(decode_b64 $COMMENTO_GITHUB_KEY)" >>$APP_ENV_FILE
  echo -e "COMMENTO_GITHUB_SECRET=$(decode_b64 $COMMENTO_GITHUB_SECRET)" >>$APP_ENV_FILE

  echo -e "COMMENTO_IDP_ENDPOINT=$(decode_b64 $COMMENTO_IDP_ENDPOINT)" >>$APP_ENV_FILE
  echo -e "COMMENTO_IDP_APIKEY=$(decode_b64 $COMMENTO_IDP_APIKEY)" >>$APP_ENV_FILE

  # Database
  echo -e "COMMENTO_POSTGRES=$(decode_b64 $COMMENTO_POSTGRES)" >>$APP_ENV_FILE
  echo -e "POSTGRES_DB=$(decode_b64 $POSTGRES_DB)" >>$APP_ENV_FILE
  echo -e "POSTGRES_USER=$(decode_b64 $POSTGRES_USER)" >>$APP_ENV_FILE
  echo -e "POSTGRES_PASSWORD=$(decode_b64 $POSTGRES_PASSWORD)" >>$APP_ENV_FILE
}

create_docker_compose_file() {
  echo "Creating docker-compose.yml"
  echo -e "version: '3'

services:
  comments_server:
    image: $CI_REGISTRY_IMAGE:latest
    ports:
      - $LISTEN_PORT:8080
    environment:
      COMMENTO_ORIGIN: \"\${COMMENTO_ORIGIN}\"
      COMMENTO_PORT: \"\${COMMENTO_PORT}\"
      COMMENTO_POSTGRES: \"\${COMMENTO_POSTGRES}\"
      COMMENTO_SMTP_HOST: \"\${COMMENTO_SMTP_HOST}\"
      COMMENTO_SMTP_PORT: \"\${COMMENTO_SMTP_PORT}\"
      COMMENTO_SMTP_USERNAME: \"\${COMMENTO_SMTP_USERNAME}\"
      COMMENTO_SMTP_PASSWORD: \"\${COMMENTO_SMTP_PASSWORD}\"
      COMMENTO_SMTP_FROM_ADDRESS: \"\${COMMENTO_SMTP_FROM_ADDRESS}\"
      COMMENTO_GOOGLE_KEY: \"\${COMMENTO_GOOGLE_KEY}\"
      COMMENTO_GOOGLE_SECRET: \"\${COMMENTO_GOOGLE_SECRET}\"
      COMMENTO_GITHUB_KEY: \"\${COMMENTO_GITHUB_KEY}\"
      COMMENTO_GITHUB_SECRET: \"\${COMMENTO_GITHUB_SECRET}\"
      COMMENTO_IDP_ENDPOINT: \"\${COMMENTO_IDP_ENDPOINT}\"
      COMMENTO_IDP_APIKEY: \"\${COMMENTO_IDP_APIKEY}\"
    
    depends_on:
    - comments_db
    networks:
      - db_network

  comments_db:
    image: postgres
    ports:
      - $POSTGRES_PORT:5432
    environment:
      POSTGRES_DB: \"\${POSTGRES_DB}\"
      POSTGRES_USER: \"\${POSTGRES_USER}\"
      POSTGRES_PASSWORD: \"\${POSTGRES_PASSWORD}\"
    
    networks:
      - db_network
    volumes:
      - ./commentsdb:/var/lib/postgresql/data

networks:
  db_network:

" >"docker-compose.yml"
}

# Begin
run() {
  local ssh_key
  if [ "production" == "$CI_ENVIRONMENT_NAME" ]; then
    ssh_key=$SSH_KEY
  else
    ssh_key=$DEV_SSH_KEY
  fi

  if [ -z "$ssh_key" ]; then
    echo "Error: No SSH key provided for service connection."
    exit 1
  else
    create_env_file

    echo $ssh_key | base64 -d >$PEM_FILE
    chmod 400 $PEM_FILE

    local failed=0
    if deploy; then
      echo -e "\nInfo: Deployment succeeded."
    else
      echo -e "\nError: Deployment failed."
      failed=1
    fi

    [[ -f "$PEM_FILE" ]] && rm -f $PEM_FILE
    [[ -f "$APP_ENV_FILE" ]] && rm -f $APP_ENV_FILE
    exit $failed
  fi
}

# Execute script
run
