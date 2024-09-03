#!/bin/bash

# 设置密码长度
PASSWORD_LENGTH=12

# 定义字符集
LOWERCASE="abcdefghijklmnopqrstuvwxyz"
UPPERCASE="ABCDEFGHIJKLMNOPQRSTUVWXYZ"
DIGITS="0123456789"
SPECIAL_CHARACTERS="!@#$%^&*()-_=+[]{}|;:,.<>?/~"
ALL_CHARACTERS="$LOWERCASE$UPPERCASE$DIGITS$SPECIAL_CHARACTERS"

# 生成符合要求的随机字符
# 也可用openssl生成 PASSWORD=$(openssl rand -base64 48 | tr -dc "$LOWERCASE" | head -c 1)
PASSWORD=$(< /dev/urandom tr -dc "$LOWERCASE" | head -c 1)
PASSWORD+=$(< /dev/urandom tr -dc "$UPPERCASE" | head -c 1)
PASSWORD+=$(< /dev/urandom tr -dc "$DIGITS" | head -c 1)
PASSWORD+=$(< /dev/urandom tr -dc "$SPECIAL_CHARACTERS" | head -c 1)

# 生成剩余字符
REMAINING_LENGTH=$((PASSWORD_LENGTH - ${#PASSWORD}))
PASSWORD+=$(< /dev/urandom tr -dc "$ALL_CHARACTERS" | head -c $REMAINING_LENGTH)

# 打乱字符顺序
PASSWORD=$(echo "$PASSWORD" | fold -w1 | shuf | tr -d '\n')

# 输出生成的密码
echo "$PASSWORD"
