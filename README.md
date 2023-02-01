<div align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://cloud-djxhgxve6-hack-club-bot.vercel.app/0hcb-icon-icon-dark_1_.png">
    <img src="https://cloud-5yru8jas0-hack-club-bot.vercel.app/0logo-512.png" width="126" alt="Hack Club Bank logo">
  </picture>
  <h1>Hack Club Bank</h1>
  <strong>A powerful, safe, and easy-to-use fiscal sponsorship platform for Hack Clubs, hackathons, and nonprofits.</strong>
</div>
<br>

Welcome to the [Hack Club Bank](https://hackclub.com/bank/) codebase. We are so excited to have you. With your help, we can make Bank the best platform to run a nonprofit.

## What is Hack Club Bank?

Hack Club Bank is a platform for managing your nonprofit's finances. Through Bank, you can get a 501(c)(3) status-backed restricted fund for your project and manage your finances through an intuitive web interface.

## Table of Contents

- [What is Hack Club Bank?](#what-is-hack-club-bank)
- [Table of Contents](#table-of-contents)
- [Contributing](#contributing)
- [Quick Start](#quick-start)
  - [Production Access](#production-access)
- [Deployment](#deployment)
- [Developer Documentation](#developer-documentation)

## Contributing

We encourage you to contribute to Hack Club Bank! Please see the [wiki](https://github.com/hackclub/bank/wiki) for more information on how to get started.

All contributors are expected to follow the Hack Club [Code of Conduct](https://hackclub.com/conduct).

## Quick Start

This section provides a high-level quick start guide for running Bank with Docker or GitHub Codespaces. For more information, please see the [wiki page](https://github.com/hackclub/bank/wiki/Development).

Clone the repository or create a new Codespaces instance.

```bash
# skip this step if you're using Codespaces
git clone https://github.com/hackclub/bank.git && cd bank
```

Create a `config/master.key` file and ask a team member (ping `@creds` in Slack) for the contents.

```bash
touch config/master.key
# copy the key to your clipboard
pbpaste > config/master.key
```

Install and run [Docker](https://docs.docker.com/get-docker/).

Run the [docker_setup.sh](./docker_setup.sh) script to install dependencies and set up a local environment with Docker.

```bash
./docker_setup.sh
# optionally, append the --with-solargraph flag to enable Solargraph
./docker_setup.sh --with-solargraph
```

Start the development server with the [docker_start.sh](./docker_start.sh) script.

```bash
./docker_start.sh
# optionally, append the --with-solargraph flag to start Solargraph
./docker_start.sh --with-solargraph
```

Visit [localhost:3000](http://localhost:3000) to see the result.

**What's Solargraph?** [Solargraph](https://solargraph.org/) is a Ruby language server that provides better Intellisense and code completion. It's completely optional to use Solargraph but highly recommended. You may also need to install the [Solargraph extension](https://github.com/castwide/solargraph#using-solargraph) for your IDE.

### Production Access

We've transitioned to using development keys and tokens in development, but historically have used production data on dev machines. It is recommended to not roll back to using production data & keys in development, but if absolutely neccessary the following steps can be taken:

- Set environment variable `USE_PROD_CREDENTIALS=true` in your docker container
- Temporarily remove `config/credentials/development.yml.enc`
- Put the production key in `master.key`

Developing with production keys & data has risk and should only be used if you know what you are doing.

## Deployment

Pushes to the `main` branch are automatically deployed by Heroku.

## Developer Documentation

Please see the [wiki](https://github.com/hackclub/bank/wiki) for technical documentation on Hack Club Bank.

---

<div align="center">
<img src="./hack_club_bank_laser.gif" alt="Laser engraving the Hack Club Bank logo" width="500">
<br>
<p><strong>Happy hacking. ❤️</strong></p>
</div>

🔼 [Back to Top](#readme)
