# skateparks.gr

### How to set up the development environment

1. `git clone https://github.com/dimitristrechas/skateparks.git`
2. `cd skateparks`
3. Get the key files from a team member (`config/credentials/development.key`, `config/credentials/production.key`, `config/credentials/test.key`)
4. Copy .env.example to .env and .env.test and fill variables, for RAILS_MASTER_KEY use `config/credentials/development.key` and `config/credentials/test.key` respectively
5. `bundle install`
6. `yarn`
7. `sh scripts.sh`, option 3 builds the docker image from scratch, option 1 runs existing image
8. Open browser on `localhost:3000`
9. Optionally seed the database using option 19, or use option 6 to connect to the docker console and run `rake db:seed`

### How to run tests

1. Copy .env.example to .env.test and fill the env variables
2. `sh scripts.sh`
3. Select option 10 to build test server, or option 11 to connect to test docker console
4. Run `bundle exec rake spec`, or use option 13 to run tests directly
