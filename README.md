<div align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://cloud-djxhgxve6-hack-club-bot.vercel.app/0hcb-icon-icon-dark_1_.png">
    <img src="https://cloud-5yru8jas0-hack-club-bot.vercel.app/0logo-512.png" width="126" alt="HCB logo">
  </picture>
  <h1>HCB</h1>
  <strong>A powerful, safe, and easy-to-use fiscal sponsorship platform for Hack Clubs, hackathons, and nonprofits.</strong>
</div>
<br>

Welcome to the [HCB](https://hackclub.com/hcb/) codebase. We are so excited to have you. With your help, we can make HCB the best platform to run a nonprofit.

## What is HCB?

HCB is a platform for managing your nonprofit's finances. Through HCB, you can get a 501(c)(3) status-backed restricted fund for your project and manage your finances through an intuitive web interface.

## Table of Contents

- [What is HCB?](#what-is-hcb)
- [Table of Contents](#table-of-contents)
- [Contributing](#contributing)
- [Quick Start](#quick-start)
  - [Production Access](#production-access)
- [Deployment](#deployment)
- [Developer Documentation](#developer-documentation)

## Contributing

We encourage you to contribute to HCB! Please see the [wiki](https://github.com/hackclub/hcb/wiki) for more information on how to get started.

All contributors are expected to follow the Hack Club [Code of Conduct](https://hackclub.com/conduct).

## Quick Start

This section provides a high-level quick start guide for running HCB with Docker or GitHub Codespaces. <!--For more information, please see the [wiki page](https://github.com/hackclub/hcb/wiki/Development).-->

Clone the repository or create a new Codespaces instance.

```bash
# skip this step if you're using Codespaces
git clone https://github.com/hackclub/hcb.git && cd hcb
```

Install and run [Docker](https://docs.docker.com/get-docker/).

Run the [docker_dev_setup.sh](./docker_dev_setup.sh) script to install dependencies and set up a local environment with Docker.

```bash
./docker_dev_setup.sh
```

Start the development server with `./docker_start.sh`

Visit [localhost:3000](http://localhost:3000) to see the result.

<!--**What's Solargraph?** [Solargraph](https://solargraph.org/) is a Ruby language server that provides better Intellisense and code completion. It's completely optional to use Solargraph but highly recommended. You may also need to install the [Solargraph extension](https://github.com/castwide/solargraph#using-solargraph) for your IDE.-->

### Production Access

We've transitioned to using development keys and tokens in development, but historically have used production data on dev machines. It is recommended to not roll back to using production data & keys in development, but if absolutely neccessary the following steps can be taken:

- Set environment variable `USE_PROD_CREDENTIALS=true` in your docker container
- Temporarily remove `config/credentials/development.yml.enc`
- Put the production key in `master.key`

Developing with production keys & data has risk and should only be used if you know what you are doing.

## Deployment

Pushes to the `main` branch are automatically deployed by Heroku.

## Developer Documentation

Please see the [wiki](https://github.com/hackclub/hcb/wiki) for technical documentation on HCB.

---

<div align="center">
<img src="./hcb_laser.gif" alt="Laser engraving the HCB logo" width="500">
<br>
<p><strong>Happy hacking. ❤️</strong></p>
</div>

🔼 [Back to Top](#readme)
