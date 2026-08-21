#!/bin/bash -xeu

S3_BUCKET="delete-codedeploy-1977"
WEB_ROOT="/var/www/html"

rm -rf "${WEB_ROOT}"/*

aws s3 sync "${S3_BUCKET}" "${WEB_ROOT}"

chown -R www-data:www-data "${WEB_ROOT}"
find "${WEB_ROOT}" -type d -exec chmod 755 {} \;
find "${WEB_ROOT}" -type f -exec chmod 644 {} \;

nginx -t
systemctl reload nginx
