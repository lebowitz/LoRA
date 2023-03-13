#!/bin/bash

RUNPOD_API_KEY=<YOUR KEY HERE>
rm /tmp/rp
curl --request POST   --header 'content-type: application/json'   --url "https://api.runpod.io/graphql?api_key=$RUNPOD_API_KEY"   --data '{"query": "query Pods { myself { pods { id name runtime { uptimeInSeconds ports { ip isIpPublic privatePort publicPort type } } } } }"}' -o /tmp/rp

SERVER=$(jq -r '.data.myself.pods[0].runtime.ports[] | select ( any(.; .privatePort == 22)).ip' < /tmp/rp)
PORT=$(jq -r '.data.myself.pods[0].runtime.ports[] | select ( any(.; .privatePort == 22)).publicPort' < /tmp/rp)

ssh -L 3000:localhost:3000 -y -p $PORT -i ~/.ssh/runpod.io root@$SERVER
