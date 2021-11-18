#! /bin/bash
set -eu

GOCD_DOMAIN=$1
GOCD_ACCESS_TOKEN=$2
REPO_ID=$3
CONFIG_REPO_URL=$4
PATTERN=${5:-**/*.gocd.yaml}

if [[ -z $GOCD_DOMAIN ]]; then
 echo "Please supply the GoCD domain"
 exit 1
fi

if [[ -z $GOCD_ACCESS_TOKEN ]]; then
 echo "Please supply your GoCD personal access token"
 exit 1
fi

curl --insecure "https://${GOCD_DOMAIN}/go/api/admin/config_repos/${REPO_ID}" \
      -H "Authorization: Bearer $GOCD_ACCESS_TOKEN" \
      -H 'Accept: application/vnd.go.cd.v2+json' \
      -X DELETE

curl --insecure "https://${GOCD_DOMAIN}/go/api/admin/config_repos" \
  -H "Authorization: Bearer $GOCD_ACCESS_TOKEN" \
  -H 'Accept:application/vnd.go.cd.v2+json' \
  -H 'Content-Type:application/json' \
  -X POST -d '{
    "id": "'${REPO_ID}'",
    "plugin_id": "yaml.config.plugin",
    "material": {
      "type": "git",
      "attributes": {
        "url": "'${CONFIG_REPO_URL}'",
        "branch": "master",
        "auto_update": true
      }
    },
    "configuration": [
      {
       "key": "file_pattern",
       "value": "'"${PATTERN}"'"
     }
    ]
  }'
