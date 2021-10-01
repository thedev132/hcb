# Hack Club Bank install on Codespaces

## Prerequisites

GitHub Codebases come preinstalled with docker, so the following should work as long as you spin up a new codespace.

## Steps

1. Fill in the `config/master.key` file. If you don't have one, reach out to a bank dev team member who can give you one.
2. Run `codespace-config.sh`
3. Login with heroku username & password when prompted
4. Go cook some pasta or something, this will load for a long time
5. ???
6. Profit
7. Your codespace should be all configured to run a dev environment.

## Developing on codespaces

```sh
# You can now spin up the server with this command:
env $(cat .env.docker) docker-compose run --service-ports web bundle exec rails s -b 0.0.0.0 -p 3000
# Or, enter an interactive shell in the docker container:
env $(cat .env.docker) docker-compose run --service-ports web /bin/bash
```

When you run the server, codespaces should automatically notify you that port 3000 has been bridged and give you a preview link. If it doesn't, you can add a port link in the codespace settings.