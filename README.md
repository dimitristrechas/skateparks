# skateparks.gr

### How to set up the development environment

1. `git clone https://github.com/dimitristrechas/skateparks.git`
2. `cd skateparks`
3. Get the key files from a team member (`config/credentials/development.key`, `config/credentials/production.key`, `config/credentials/test.key`)
4. Copy .env.example to .env and .env.test and fill variables, for RAILS_MASTER_KEY use `config/credentials/development.key` and `config/credentials/test.key` respectively
5. `bundle install`
6. `yarn`
7. `./scripts.sh`, select option "Fresh build & start development server" to build the docker containers from scratch
8. Open browser on `localhost:3000`
9. Optionally seed the database with "Seed the database" option in `./scripts.sh`

### How to run tests

1. `./scripts.sh`
2. Select option "Fresh build & start test server" to build the docker containers from scratch
3. Select option "Run RSpec tests" to run the specs
