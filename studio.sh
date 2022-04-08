#!/bin/bash
HAB_CTL_SECRET=$(cat ~/.hab/etc/cli.toml | grep "ctl_secret" | cut -f2 -d '"') HAB_DOCKER_OPTS="-p 9632:9632 -v $(pwd)/default:/hab/sup/default" hab studio enter