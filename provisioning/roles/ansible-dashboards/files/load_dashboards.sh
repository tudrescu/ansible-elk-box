#!/bin/bash

# call with ./load_dashboard.sh /vagrant/kibana-dashboards/ladr http://localhost:9200

DEFAULT_ES_HOST="http://localhost:29200"

ROOT_DIR=/vagrant/kibana-dashboards
DASH_ID=mydash

DIR="${ROOT_DIR}/${DASH_ID}"

if [ ! -z "$1" ]; then
  DIR=$1
fi

if [ -z "$2" ]; then
    ELASTICSEARCH="${DEFAULT_ES_HOST}"
else
    ELASTICSEARCH=$2
fi

CURL=curl
# if [ -z "$2" ]; then
#     CURL=curl
# else
#     CURL="curl --user $2"
# fi

# echo $CURL



for file in $DIR/search/*.json
do
    name=`basename $file .json`
    echo "Loading search $name:"
    $CURL -XPUT $ELASTICSEARCH/.kibana/search/$name \
        -d @$file || exit 1
    echo
done

for file in $DIR/visualization/*.json
do
    name=`basename $file .json`
    echo "Loading visualization $name:"
    $CURL -XPUT $ELASTICSEARCH/.kibana/visualization/$name \
        -d @$file || exit 1
    echo
done

for file in $DIR/dashboard/*.json
do
    name=`basename $file .json`
    echo "Loading dashboard $name:"
    $CURL -XPUT $ELASTICSEARCH/.kibana/dashboard/$name \
        -d @$file || exit 1
    echo
done

for file in $DIR/index-pattern/*.json
do
    name=`basename $file .json`
    printf -v escape "%q" $name
    echo "Loading index pattern $escape:"

    $CURL -XPUT $ELASTICSEARCH/.kibana/index-pattern/$escape \
        -d @$file || exit 1
    echo
done
