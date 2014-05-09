= Overview

This project provides a mock server for the Binary.com Partner API.

= Installation

== Requirements:

1. nodejs
2. curl
3. bash

== Installation steps:

1. Install npm dependencies via: `npm install`
2. Download fixtures data (for this, you will need the access token):

    `./bootstrap.sh TOKEN`

3. Run the mock server `./node_modules/.bin/mock-api-server --port 7000`
4. Enjoy :-)
