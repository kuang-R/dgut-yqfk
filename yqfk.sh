#!/usr/bin/env bash

ACCOUNT="$1"
PASSWORD="$2"

LOGIN_URL="https://cas.dgut.edu.cn/home/Oauth/getToken/appid/yqfkdaka/state/home.html"
AUTH_URL="https://yqfk-daka-api.dgut.edu.cn/auth"
YQFK_URL="https://yqfk-daka-api.dgut.edu.cn/record"

COOKIE_FILE=/tmp/cookie.txt

response=$(curl -s -c $COOKIE_FILE $LOGIN_URL)
# echo "RESPONSE: " $response
token=$(echo $response \
	|egrep 'var token = "[^"]+"' -o \
	|egrep '".+"' -o)
token_len=$(expr ${#token} - 2)
token=${token:1:${token_len}}
echo "登陆凭证TOKEN: " $token
token=$(curl -s -X POST -b $COOKIE_FILE -c $COOKIE_FILE ${LOGIN_URL}\
	-d "username=${ACCOUNT}&password=${PASSWORD}&__token__=${token}&wechat_verify=" \
	-H "X-Requested-With: XMLHttpRequest")
# echo $token
if ! grep -q 'info' <<<"$token"; then
	rm $COOKIE_FILE
	exit 1
fi

token=$(echo $token |egrep 'token=[^&]+' -o)
token=${token:6}
echo "登陆TOKEN: " $token
access_token=$(curl -s -X POST -b $COOKIE_FILE -c $COOKIE_FILE $AUTH_URL\
	-d '{"token":"'$token'","state":"yqfk"}')
access_token=$(echo $access_token |egrep 'token":"[^"]+' -o)
access_token=${access_token:8}
echo "表单ACCESS_TOKEN: " $access_token
form=$(curl -s -b $COOKIE_FILE -c $COOKIE_FILE $YQFK_URL \
	-H "Authorization: Bearer "$access_token)
form=$(echo $form |egrep '"user_data":.+' -o)
form='{"'${form:6}
echo $form
result=$(curl -s -X POST -b $COOKIE_FILE -c $COOKIE_FILE $YQFK_URL \
	-H "Authorization: Bearer "$access_token \
	-d "$form")

rm $COOKIE_FILE
echo $result
(echo $result |grep -q '\\u60a8\\u4eca\\u5929\\u5df2\\u6253') && exit 0
(echo $result |grep -q '\\u60a8\\u4eca\\u5929\\u5df2\\u7ecf') && exit 0
exit 1

