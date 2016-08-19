#!/bin/sh

project_url_set=0

for arg in "$0"; do
  if [ $(echo "$arg" | grep -e "\-\-project_url=") ]; then
    project_url_set=1
  fi
done

if [ ! $project_url_set -a -n "$PROJECT_URL" ]; then
  project_url_arg="--project-url=${PROJECT_URL}"
fi

${DOCKER_TEMPLATE_WRAPPER_HOME}/update-dockerfile  "$@"
