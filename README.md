# Development

1. `git clone https://github.com/dimitristrechas/skateparks.git`
2. `cd skateparks`
3. `bundle install`
4. Copy .env.example to .env and fill variables, `RAILS_MASTER_KEY` value is filled with the `config/master.key` data.
5. `sh scripts.sh`, option 1 builds the docker image from scratch, option 2 runs existing
6. Open another terminal and run `rails tailwindcss:watch` to build tailwind css
7. `localhost:3000`
