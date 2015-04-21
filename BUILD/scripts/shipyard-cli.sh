#!/bin/bash

# use the local/shipyard-cli image (customized with pre-authentication)
docker run --rm local/shipyard-cli "$@"

