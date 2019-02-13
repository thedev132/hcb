# Bank

_It’s a bank, folks._

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

## Import database dump from Heroku

```
pg_restore --verbose --clean --no-acl --no-owner -h db -U postgres -d bank_development latest.dump
```

MIT License
