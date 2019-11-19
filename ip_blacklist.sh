#!/bin/sh

set -ex
FILE="${IP_BLACKLIST_PATH:-/etc/nginx/conf.d/blacklisted.conf}"

if [ -f ${FILE} ];
then
    NOW=$(date +"%m-%d-%Y_%H-%M-%S.%N")
    cp ${FILE} ${FILE}.${NOW}.bkp
fi

curl -o ${FILE}  http://iplists.firehol.org/files/firehol_level1.netset
if [ "${ALLOW_LOCAL_CONNECTIONS}" = 1 ];
then
    sed -i '/^172\./d' ${FILE}
fi
sed -i '/^#/!s/^/    /g; /^#/!s/$/ 1\;/g' ${FILE}
# sed -i "1s/^/    include \/etc\/nginx\/blacklist\/\*\.conf\;\n/" ${FILE}
sed -i "1s/^/    default 0\;\n/" ${FILE}
sed -i "1s/^/geo \$blacklisted {\n/" ${FILE}
sed -i "1s/^/\# https\:\/\/serverfault.com\/a\/869795\/195894\n/" ${FILE}
echo "}" >> ${FILE}
nginx -s reload
