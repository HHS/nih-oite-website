#!/usr/bin/env bash

set -euo pipefail

MARIADB_DOCKER_IMAGE=mariadb:10.7.3
SQL_DIR=sql
DATABASE=oite-nih
CONTAINER_NAME=oite-nih

USAGE="
${0} <path to .tar.gz file> [--leave-running]
Loads the specified NIH OITE website database dump and exports relevant data.
"

TARFILE=
LEAVE_RUNNING=0

for a in "$@"
do
  case "$a" in
    --leave-running)
    LEAVE_RUNNING=1
    ;;
    *)
    if [ "$TARFILE" != "" ]; then
      echo $USAGE
      exit 1
    fi
    TARFILE="$a"
    ;;
  esac
done

if [ "$TARFILE" == "" ] || [ ! -f ${TARFILE} ]; then
  echo $USAGE
  exit 1
fi

if ! which docker > /dev/null 2>&1; then
  echo "This script requires Docker to run."
  exit 1
fi

echo "Extracting ${TARFILE}..."
mkdir -p "$SQL_DIR" || true
tar --cd "$SQL_DIR" -xzf "$TARFILE"

echo "Removing extraneous tables..."
rm "$SQL_DIR"/oite-nih-schema-create* 2> /dev/null || true
rm "$SQL_DIR"/oite-nih._eventlog* 2> /dev/null || true
rm "$SQL_DIR"/oite-nih.event_[0123456789abcdef]* 2> /dev/null || true
rm "$SQL_DIR"/oite-nih.survey_[0123456789abcdef]* 2> /dev/null || true
rm "$SQL_DIR"/oite-nih.picklist_event_[0123456789abcdef]* 2> /dev/null || true
rm "$SQL_DIR"/oite-nih.picklist_survey_[0123456789abcdef]* 2> /dev/null || true
rm "$SQL_DIR"/oite-nih.page_index* 2> /dev/null || true
rm "$SQL_DIR"/oite-nih.report_result* 2> /dev/null || true

echo "Unzipping .sql files..."
for f in $SQL_DIR/*.gz
do
  if [ -f "$f" ]; then
    gunzip -f "$f"
  fi
done

# In production, Mysql/Mariadb was configured to use the latin1 charset + latin1_swedish_ci collation.
# User-entered data seems to have typically been encoded as UTF8, and stored as such.
# Here we update the schema scripts to:
#    1. Create tables with utf8mb4 charset from the start
#    2. Interpret the data in these .sql files as UTF-8 when slurping it in.
echo "Resetting to utf8mb4 charset..."
for f in $SQL_DIR/*.sql
do
  if [ -f "$f" ]; then
    sed -i.bak \
      -e 's/CHARSET=latin1/CHARSET=utf8mb4/g' \
      -e 's/40101 SET NAMES binary/40101 SET NAMES utf8mb4/g' \
      "$f" 2> /dev/null || echo "File contains binary data: '$f'. This data _might_ not be imported correctly (you should investigate)."
  fi
done
rm $SQL_DIR/*.bak 2> /dev/null || true

# Several columns have `enum(0,1)` as the datatype, but then include data that includes empty strings.
# To work around this, we just expand the enum to also allow empty strings.
echo "Correcting enum(0,1) usage..."
for f in $SQL_DIR/*.sql
do
  if [ -f "$f" ]; then
    sed -i.bak -e "s/enum('0','1')/enum('0','1','')/g" "$f" 2> /dev/null || echo "File contains binary data: $f"
  fi
done
rm $SQL_DIR/*.bak 2> /dev/null || true

echo "Starting Mariadb server..."

CONTAINER_ID=$(docker run \
  --name ${CONTAINER_NAME} \
  -d \
  -v "$(pwd)/data:/var/lib/mysql" \
  -v "$(pwd)/${SQL_DIR}:/docker-entrypoint-initdb.d" \
  -e MARIADB_DATABASE=${DATABASE} \
  -e MARIADB_ALLOW_EMPTY_ROOT_PASSWORD=1 \
  ${MARIADB_DOCKER_IMAGE} \
  --innodb_strict_mode=OFF \
)

while true
do
  if docker exec $CONTAINER_ID /usr/local/bin/healthcheck.sh --connect
  then
    break
  fi
  sleep 1
done

echo "Mariadb started as ${CONTAINER_ID}"

echo "Exporting event data to 'events.csv'..."

echo "
SELECT
    site_event.*,
    picklist_event_type.value AS type_name,
    picklist_event_topic.value AS topic,
    picklist_trainee_type.value AS audience
FROM
    site_event
    LEFT JOIN picklist_event_type ON picklist_event_type.id = site_event.type
    LEFT JOIN _ObjectPicks _TopicsPick ON (_TopicsPick.object_id = site_event.id AND _TopicsPick.field_name = 'topics')
    LEFT JOIN picklist_event_topic ON picklist_event_topic.id = _TopicsPick.field_value
    LEFT JOIN _ObjectPicks _AudiencePick ON (_AudiencePick.object_id = site_event.id AND _AudiencePick.field_name = 'audience')
    LEFT JOIN picklist_trainee_type ON picklist_trainee_type.id = _AudiencePick.field_value
ORDER BY site_event.id;
" | \
  docker exec -i ${CONTAINER_ID} mysql -D ${DATABASE} --default-character-set=utf8mb4 | \
    LC_ALL=C sed \
    -e 's/\r//g' \
    -e 's/"/""/g' \
    -e 's/^/"/g' \
    -e 's/$/"/g' \
    -e 's/\t/","/g' \
    -e 's/\\t/\t/g' \
    -e 's/\\n/\n/g' \
    -e 's/\\\\/\\/g' \
    > events.csv

# NOTE: All that sed above is to convert tab-delimited mysql output to CSV

# TODO: Export any more useful data

if [ "$LEAVE_RUNNING" == "0" ]; then
  docker rm --force ${CONTAINER_NAME}
else
  echo "
Export complete.

You can access the running Mariadb server with the following command line:

  docker exec -i ${CONTAINER_NAME} mysql -D ${DATABASE} --default-character-set=utf8mb4

When you're done, clean up using the following command:

  docker rm --force ${CONTAINER_NAME}
"
fi
