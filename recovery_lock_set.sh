#!/bin/bash

username=""
password=""
url=""
computer_id=""
recovery_pw='TheScriptWorks'

getBearerToken() {
	response=$(curl -s -u "$username":"$password" "$url"/api/v1/auth/token -X POST)
	bearerToken=$(echo "$response" | plutil -extract token raw -)
	#tokenExpiration=$(echo "$response" | plutil -extract expires raw - | awk -F . '{print $1}')
	#tokenExpirationEpoch=$(date -j -f "%Y-%m-%dT%T" "$tokenExpiration" +"%s")
}


getComputerManagementId() {
  # check if bearer token is still valid
  # if [[ $(date +"%s") -ge $tokenExpirationEpoch ]]; then
  #   getBearerToken
  # fi
  # Save management ID as a variable
  management_id=$(curl -s "${url}/api/v1/computers-inventory-detail/$computer_id" -H "Accept: application/json" -H "Authorization: Bearer ${bearerToken}" | jq -r '.general.managementId')
}

setRecoveryLockRequestBody() {
  api_request_body=$(cat <<EOF
{
  "clientData": [
    {
      "managementId": "$management_id"
    }
  ],
  "commandData": {
    "commandType": "SET_RECOVERY_LOCK",
    "newPassword": ""
  }
}
EOF
)
}

#Obtain bearer token and target computer's management ID, and then form the request body for the Recovery Lock command
getBearerToken
getComputerManagementId
setRecoveryLockRequestBody

#Run API call to set Recovery Lock command with information gathered thus far
curl -s -H "Authorization: Bearer $bearerToken" -H "Content-Type: application/json" -d "$api_request_body" "$url/api/preview/mdm/commands"
