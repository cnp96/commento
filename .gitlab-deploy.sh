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

    exec_scp $APP_ENV_FILE $APP_ENV_FILE
    if [[ $? -ne 0 ]]; then
      echo "Error: Copy failed!" && return 1
    fi

    exec_ssh "docker pull $IMAGE"
    exec_ssh "docker tag $IMAGE s9_comments:latest"

    exec_ssh "[[ $(docker ps -q --filter 'name=comments_db') == \"\" ]] && docker-compose up --force-recreate -d comments_db"
    exec_ssh "docker-compose up --force-recreate -d comments_server"

    result=$?
    exec_ssh "rm -f $APP_ENV_FILE"
    if [[ "$result" -ne 0 ]]; then
      echo "Error: Start services failed!" && return 1
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
run
