# skateparks.gr

### How to set up the development environment

1. `git clone https://github.com/dimitristrechas/skateparks.git`
`cd skateparks`
2. Get the key files from a team member (`config/credentials/development.key`, `config/credentials/production.key`, `config/credentials/test.key`)
3. Copy .env.example to .env and .env.test and fill variables, for RAILS_MASTER_KEY use `config/credentials/development.key` and `config/credentials/test.key` respectively
4. `bundle install`
5. `npm install`
6. `sh scripts.sh`, option 3 builds the docker image from scratch, option 1 runs existing image
7. Open browser on `localhost:3000`
8. Optionally seed the database, use option 6 to connect to the docker console and run `rake db:seed`

### How to run tests

1. Copy .env.example to .env.test and fill the env variables
2. `sh scripts.sh`
3. Select option 9 `test docker console` option
4. Run `bundle exec rake spec`

