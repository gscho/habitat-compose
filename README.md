# habitat-compose

Habitat compose is a tool for defining, installing and managing applications using habitat. It provides the ability to define a set of habitat packages and their configuration using a single YAML file and load them on a local or remote host.

## Installation

Habitat compose is distributed as a habitat package and requires habitat in order to install and use.

### Install habitat

```bash
curl https://raw.githubusercontent.com/habitat-sh/habitat/main/components/hab/install.sh | sudo bash
hab license accept
```
### Install and binlink habitat-compose

```bash
hab pkg install gscho/habitat-compose -bf
````

## Basic Usage

To use habitat compose, you first need to create a habitat plan for your application.

Example:

```bash
pkg_name=simple-go-app
pkg_origin=gscho
pkg_version="0.1.0"
pkg_scaffolding=core/scaffolding-go
pkg_deps=(core/glibc)
scaffolding_go_module=on
pkg_bin_dirs=(bin)
```

Then you define a list of services in a `habitat-compose.yml` file:

```yaml
services:
  webapp:
    build: .
    depends_on:
    - db
    load_args:
    - "--bind=db:postgresql.default"
    config_toml: |
      port = 8082
  db:
    pkg: core/postgresql
```

Lastly, run `habitat-compose up` and habitat compose will build, load, and configure the services on the local host.

## Targeting a remote habitat supervisor

Habitat compose can be used on remote servers by communicating with the habitat supervisor on port `:9632` and by passing a `CTL_SECRET` with each request.

### Setting up the server

The remote server which will be the target of our commands will need to have:

* habitat installed
* habitat supervisor running
* port 9632 open to the host running `habitat-compose` commands

### Setting up the habitat-compose CLI

The host running `habitat-compose` commands will need to:

* copy the contents of `/hab/sup/default/CTL_SECRET` from the remote server
* create a `HAB_CTL_SECRET` environment variable with the contents of the `CTL_SECRET`
* pass the `--remote-sup=<ipaddress>:9632` flag to each command with the remote server's ip

## Testing locally

To test your `habitat-compose.yml` files locally, first set a `ctl_secret` value in your `~/.hab/etc/cli.toml` file.

Eg:

```toml
ctl_secret = "vVPdzDERsnXf77W2s1H3udtYoSZMTqLh7NfIX0U1rQPlD5V3mgL8XCF/zH80MTxcuLAHl2EXJYE/HeIXgqU1+Q=="
````

If you're using a mac, run `./studio.sh` which brings up a habitat studio using docker, otherwise use `hab studio enter`.

## Full schema

```yaml
services:
  <service_1>:
    build: # cannot be used if pkg is defined
      plan_context: "<path to plan file>"
    pkg: core/redis # cannot be used if build is defined
    depends:
    - <service_2> # will automatically load service_2 before service_1
    load_args:
    - "arg1=foo" # any option that can be passed to hab svc load
    config_toml: |
    [table]
    string = "value"

```