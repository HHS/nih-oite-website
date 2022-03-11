#!/usr/bin/env bash

read -p "Are you sure you want to import terraform state (y/n)? " verify

if [[ $verify == "y" ]]; then
  echo "Importing bootstrap state"
  ./run.sh import module.s3.cloudfoundry_service_instance.bucket c239b06e-b226-4f92-a84e-83e0b393bd27
  ./run.sh import cloudfoundry_service_key.bucket_creds 8e397b4d-6a63-4ba0-964c-abed06538f8e
  ./run.sh plan
else
  echo "Not importing bootstrap state"
fi
