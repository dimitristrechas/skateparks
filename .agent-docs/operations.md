# Operations & Troubleshooting

## Production credentials

Edit production secrets (requires `config/credentials/production.key` to exist):

```bash
VISUAL="code --wait" bin/rails credentials:edit --environment production
```

## Database version

Canonical dev/test database is **PostgreSQL 17** (see `postgres:17-alpine` in `docker-compose.development.yml` and `docker-compose.test.yml`).

Inspect the running development instance:

```bash
docker compose -f docker-compose.development.yml exec db psql -U postgres -c "SELECT version();"
```

## WSL `scripts.sh` encoding

CRLF line endings can break `scripts.sh` on WSL. Fix:

```bash
sudo apt-get install dos2unix
dos2unix scripts.sh
```
