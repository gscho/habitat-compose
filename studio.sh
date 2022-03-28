#!/bin/bash

HAB_DOCKER_OPTS="-p 9632:9632 -v $(pwd)/default:/hab/sup/default" hab studio enter