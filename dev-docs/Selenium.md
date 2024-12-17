## Running Selenium Tests

This assumes the following:

- HCB is running within Docker
- Your host machine has Google Chrome installed
- Your host machine has chromedriver installed. It can be installed with `brew install chromedriver`

With the assumptions above, run the following on your host machine's terminal:

```
# Start chromedriver
chromedriver --whitelisted-ips --allowed-origins="*"
# the `--whitelisted-ips` flag allows all ip addresses
# the `--allowed-origins="*"` flag allows all origins
```

Refer to this [guide](https://avdi.codes/run-rails-6-system-tests-in-docker-using-a-host-browser/) for more information.
