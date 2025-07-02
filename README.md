# skateparks.gr

### How to set up the development environment

1. `git clone https://github.com/dimitristrechas/skateparks.git`
2. `cd skateparks`
3. `bundle install`
4. `npm install`
5. Copy .env.example to .env and fill variables
6. `sh scripts.sh`, option 4 builds the docker image from scratch, option 1 runs existing image
7. Open browser on `localhost:3000`

### How to run tests

1. Copy .env.example to .env.test and fill the env variables
2. `sh scripts.sh`
3. Select option 9 ` test docker console` option
4. Run `bundle exec rake spec`

