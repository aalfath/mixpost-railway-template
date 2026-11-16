# Mixpost Lite, official image pinned by version and digest.
FROM inovector/mixpost:v2.6.0@sha256:89d02f4e3d27a2e1a93a108e391883afacbe81596a5d4bddcb309bc04650b22e

COPY railway-start.sh /usr/local/bin/railway-start.sh
COPY create-admin.php /var/www/railway/create-admin.php
RUN chmod +x /usr/local/bin/railway-start.sh

EXPOSE 80
ENTRYPOINT ["/usr/local/bin/railway-start.sh"]
