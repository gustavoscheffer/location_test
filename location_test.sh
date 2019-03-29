#!/usr/bin/env bash

# location_test.sh NGINX_CONF

# Get conf
NGINX_CONF=$1

# Get server name
SERVER_NAME=`grep 'server_name' ${NGINX_CONF} | sed -s 's/\t//g' |  sed -s 's/\s//g' | sed -s 's/server_name//g' | tr -d ';' | sort | uniq`

# Get ssl port
SSL_SERVER_PORT=`grep 'listen' ${NGINX_CONF} | sed -s 's/\t//g' |  sed -s 's/\s//g' | sed -s 's/listen//g' | tr -d ';' | sort | uniq | grep -v 80`

# Get no ssl port
SERVER_PORT=`grep 'listen' ${NGINX_CONF} | sed -s 's/\t//g' |  sed -s 's/\s//g' | sed -s 's/listen//g' | tr -d ';' | sort | uniq | grep -o 80`

# Get location list (remove tab, {, space, = from string)
mapfile -t  LOCATION_LIST < <(cat ${NGINX_CONF} | tr -d '\t,{,[:blank:],=' | grep ^location | sed -s 's/location//g')

# Output file
OUTPUT_FILE=''

# Output dir
mkdir -p /tmp/test_locations/${SERVER_NAME}
OUTPUT_DIR="/tmp/test_locations/${SERVER_NAME}"



# iterate over locations
for LOCATION in "${LOCATION_LIST[@]}" ; do

  # remove  hiden '-r'
  LOCATION=${LOCATION%$'\r'}

  # substitute / for _ on filename
  LOCATION_FORMATED=${LOCATION//\//_}

  # format url
  URL=${SERVER_NAME}:${SSL_SERVER_PORT}${LOCATION}

  # format output filename
  OUTPUT_FILE="${SERVER_NAME}_${SSL_SERVER_PORT}_${LOCATION_FORMATED}.txt"

  # test url and save in /tmp/test_locations/
  curl -Ls $URL  &> "${OUTPUT_DIR}/${OUTPUT_FILE}"
 done
