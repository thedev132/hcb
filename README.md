# Bank

_It’s a bank, folks._

![](hack_club_bank_laser.gif)

## Getting Started

1. Install Docker.
2. Clone this repo.
3. ```sh
    docker-compose build
    docker-compose run web bundle
    docker-compose run web bundle exec rails db:create db:migrate
    docker-compose up
   ```
4. Open [localhost:3000](http://localhost:3000)

Alternatively, you can run `docker-compose run --service-ports web /bin/bash` to open a shell into the container with the right ports bound, and then manually start the Rails app.

## Import database dump from Heroku

    $ heroku pg:backups:capture
    $ heroku pg:backups:download # will save as latest.dump, double check to make sure that file is created
    $ pg_restore --verbose --clean --no-acl --no-owner -h db -U postgres -d bank_development latest.dump
