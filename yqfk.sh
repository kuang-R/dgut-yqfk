#!/usr/env bash

ACCOUNT="$1"
PASSWORD="$2"

LOGIN_URL="https://cas.dgut.edu.cn/home/Oauth/getToken/appid/yqfkdaka/state/home.html"
AUTH_URL="https://yqfk-daka-api.dgut.edu.cn/auth"
YQFK_URL="https://yqfk-daka-api.dgut.edu.cn/record"

COOKIE_FILE=cookie.txt

response=$(curl -c $COOKIE_FILE $LOGIN_URL)
# echo "RESPONSE: " $response
token=$(echo $response \
	|egrep 'var token = "[^"]+"' -o \
	|egrep '".+"' -o)
token_len=$(expr ${#token} - 2)
token=${token:1:${token_len}}
# echo "TOKEN: " $token
token=$(curl -X POST -b $COOKIE_FILE -c $COOKIE_FILE ${LOGIN_URL}\
	-d "username=${ACCOUNT}&password=${PASSWORD}&__token__=${token}&wechat_verify=" \
	-H "X-Requested-With: XMLHttpRequest")
echo $token
(echo $token |grep -q '验证通过') || rm $COOKIE_FILE && exit 1

token=$(echo $token |egrep 'token=[^&]+' -o)
token=${token:6}
# echo "TOKEN" $token
access_token=$(curl -X POST -b $COOKIE_FILE -c $COOKIE_FILE $AUTH_URL\
	-d '{"token":"'$token'","state":"home"}')
access_token=$(echo $access_token |egrep 'token":"[^"]+' -o)
access_token=${access_token:8}
# echo "ACCESS_TOKEN" $access_token
form=$(curl -b $COOKIE_FILE -c $COOKIE_FILE $YQFK_URL \
	-H "Authorization: Bearer "$access_token)
form=$(echo $form |egrep '"user_data":.+' -o)
form='{"'${form:6}
# echo $form
result=$(curl -X POST -b $COOKIE_FILE -c $COOKIE_FILE $YQFK_URL \
	-H "Authorization: Bearer "$access_token \
	-d "$form")

rm $COOKIE_FILE
echo $result
(echo $result |grep -q '\\u60a8\\u4eca\\u5929\\u5df2\\u6253') && exit 0
(echo $result |grep -q '\\u60a8\\u4eca\\u5929\\u5df2\\u7ecf\\u63d0\\u4ea4\\u8fc7') && exit 0
exit 1

