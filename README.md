<div align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://cloud-djxhgxve6-hack-club-bot.vercel.app/0hcb-icon-icon-dark_1_.png">
    <img src="https://cloud-5yru8jas0-hack-club-bot.vercel.app/0logo-512.png" width="126" alt="HCB logo">
  </picture>
  <h1>HCB</h1>
  <strong>A powerful, safe, and easy-to-use fiscal sponsorship platform for hackathons, Hack Clubs, robotic teams and more.</strong>
</div>
<br>

Welcome to the [HCB](https://hackclub.com/fiscal-sponsorship/) codebase. We are so excited to have you. With your help, we can make HCB the best platform to run a nonprofit.

## What is HCB?

HCB is a platform for managing your nonprofit’s finances. Through HCB, you can get a 501(c)(3) status-backed restricted fund for your organization and manage your finances through an intuitive web interface.

## Table of Contents

- [What is HCB?](#what-is-hcb)
- [Table of Contents](#table-of-contents)
- [Contributing](#contributing)
- [Quick Start](#quick-start)
  - [Github Codespaces](#github-codespaces)
  - [Docker](#docker)
- [Deployment](#deployment)
- [Wiki](https://github.com/hackclub/hcb/wiki)

## Contributing

We are so excited for you to join the codebase! We have a [Quick Start](#quick-start) guide, or you can go to the [wiki](https://github.com/hackclub/hcb/wiki) for more information on how to get started.

All contributors are expected to follow the Hack Club [Code of Conduct](https://hackclub.com/conduct).

## Quick Start

### GitHub Codespaces

[GitHub Codespaces](https://docs.github.com/en/codespaces) allows you to run a development environment without installing anything on your computer, allows for multiple instances, creates an overall streamlined and reproducible environment, and enables anyone with browser or VS Code access to contribute.

To get started, [whip up a codespace](https://docs.github.com/en/codespaces/getting-started/quickstart) and follow the steps in the [Automated Setup with Docker](#automated-setup-with-docker) section.

See the [Codespaces](./Codespaces.md) page for more information on developing in a GitHub Codespaces environment.

### Docker

If you are running macOS or Ubuntu, you can clone the repository and run the [docker_dev_setup.sh](./docker_dev_setup.sh) script to automatically set up a development environment with Docker. Append `--with-solargraph` to the command to also setup [Solargraph](https://solargraph.org), a language server for Ruby. You may also need to install the [Solargraph extension](https://github.com/castwide/solargraph#using-solargraph) for your editor. This script should also work for Windows; although it's recommended that Window users run it (docker) within [WSL](https://learn.microsoft.com/en-us/windows/wsl/install)

```bash
./docker_dev_setup.sh
# or with Solargraph
./docker_dev_setup.sh --with-solargraph
```

Then, to start the development server:

```bash
./docker_start.sh
# or with Solargraph
./docker_start.sh --with-solargraph
```

If you have more questions about development check out our [wiki](https://github.com/hackclub/hcb/wiki)

### Production Access

Please see this part of the [wiki](https://github.com/hackclub/hcb/wiki/Development/#production-access) for more information on Production Access

## Deployment

All pushes to the `main` branch are automatically deployed by Heroku.

---

<div align="center">
<img src="./hcb_laser.gif" alt="Laser engraving of the HCB logo" width="500">
<br>
<p><strong>Happy hacking. ❤️</strong></p>
</div>

🔼 [Back to Top](#readme)
