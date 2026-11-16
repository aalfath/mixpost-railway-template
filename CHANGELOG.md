# Changelog

## 2.6.0-railway.2 (2026-11-16)

- README: Deploy on Railway button for the published template (`mixpost-1`). No change to the app or its settings, so applying this update changes nothing in your deployment.

## 2.6.0-railway.1 (2026-11-16)

- First release: Mixpost Lite 2.6.0 (`inovector/mixpost:v2.6.0@sha256:89d02f4e3d27a2e1a93a108e391883afacbe81596a5d4bddcb309bc04650b22e`) with Railway MySQL and Redis.
- The first admin is created with a generated password (`MIXPOST_ADMIN_PASSWORD`) instead of the image's default `changeme`.
- nginx listens on `$PORT`; uploaded media are kept on a volume at `/var/www/html/storage/app`.
