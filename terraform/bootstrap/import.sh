#!/usr/bin/env bash

read -p "Are you sure you want to import terraform state (y/n)? " verify

if [[ $verify == "y" ]]; then
  echo "Importing bootstrap state"
  ./run.sh import module.s3.cloudfoundry_service_instance.bucket 2ce7759b-fe6f-488a-a96e-ccda30424ab9
  ./run.sh import cloudfoundry_service_key.bucket_creds b817fc39-d16c-4c11-9cdb-5295683bd33e
  ./run.sh plan
else
  echo "Not importing bootstrap state"
fi
