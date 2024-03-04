# Development

1. `git clone https://github.com/dimitristrechas/skateparks.git`
2. `cd skateparks`
3. `bundle install`
4. `npm install`
5. Copy .env.example to .env and fill variables, `RAILS_MASTER_KEY` value is filled with the `config/master.key` data. If no `master.key` present run `EDITOR="code --wait" credentials:edit` to generate new ones
6. `sh scripts.sh`, option 1 builds the docker image from scratch, option 2 runs existing image
7. Open another terminal and type `sh scripts.sh`, select option to build tailwind css
8. `localhost:3000`
