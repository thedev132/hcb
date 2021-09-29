# Hack Club Bank install on Codespaces

# Steps

## Prerequisites
GitHub Codebases come preinstalled with rbenv, rvm, and other packages. Ensure you have the below packages if you're not using GitHub Codebases.

## Checking

1. `ruby -v`
2. `bundle -v`

## Correct Version Installations

3. `rbenv install 2.7.3`
4. `gem install bundler:1.17.3`


## Packages

6. `bundle install`
7. `yarn install`


## Heroku

9. `curl https://cli-assets.heroku.com/install-ubuntu.sh | sh`
10. `heroku git:remote -a bank-hackclub` # if your repo isn't attached to the heroku app
11. `heroku pg:backups:capture`
12. `heroku pg:backups:download` # will save as latest.dump, double check to make sure that file is created
13. `pg_restore --verbose --clean --no-acl --no-owner -d bank_development latest.dump`

15. `cp .env.docker.example .env.docker`

need to add & do
* key
* db; might need to ask max for the command
* make into an executable file
*   maybe ask for for all the needed inputs at the beginning so it can run through without interuption

* a single run command vs run command + codespace config?
