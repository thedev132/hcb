# Hack Club Bank Install on Codespaces

GitHub Codespaces comes preinstalled with Docker, so the following steps should work as long as you spin up a new codespace. These instructions may also work on a local machine but will need the prerequisite dependencies and may run into some errors.

After a bit of testing, I haven't seen a big difference between the different codespace options (2 cores vs 16 cores), so I recommend starting with the cheapest option and upgrading it if your instance is feeling slow.

## Prerequisites

A modern browser + internet & a good attitude.

## Steps

1. Fill in the `config/master.key` file. If you don't have one, reach out to a Bank dev team member who can give you one.
2. Run `codespace-config.sh`
3. Login with Heroku username & password when prompted
4. Go cook some pasta or something, this will load for a long time
5. Enjoy my beautiful eye candy -kunal
6. Profit
7. Your codespace should be all configured to run a dev environment.

## Developing on Codespaces


```sh
# You can now spin up the server by running `codespace-start.sh` or with this command:
env $(cat .env.docker) docker-compose run --service-ports web bundle exec rails s -b 0.0.0.0 -p 3000
# Or, enter an interactive shell in the docker container:
env $(cat .env.docker) docker-compose run --service-ports web /bin/bash
```

When you run the server, Codespaces should automatically notify you that port 3000 has been forwarded and give you a preview link. If it doesn't, you can forward a port in the codespace settings.

Give any feedback, suggestions, improvements, or issues you have about this to Kunal (@kunal on Slack / kunal@hackclub.com).