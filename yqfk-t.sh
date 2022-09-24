#!/usr/bin/env bash

access_token="$1"

YQFK_URL="https://yqfk-daka-api.dgut.edu.cn/record"

form=$(curl -s $YQFK_URL \
	-H "Authorization: Bearer "$access_token)
form=$(echo $form |jq '.data.data=.user_data |.data')
echo $form
result=$(curl -s -X POST -b $COOKIE_FILE -c $COOKIE_FILE $YQFK_URL \
	-H "Authorization: Bearer "$access_token \
	-d "$form")

echo $result
# (echo $result |grep -q '\\u60a8\\u4eca\\u5929\\u5df2\\u6253') && exit 0
# (echo $result |grep -q '\\u60a8\\u4eca\\u5929\\u5df2\\u7ecf') && exit 0
# exit 1

