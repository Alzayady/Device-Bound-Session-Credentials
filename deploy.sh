#!/usr/bin/env bash
# Deploy the DBSC demo to a Meta devserver and run it behind Secure Web Apps (HTTPS 442xx).
# Run this from your LAPTOP (it uses your interactive SSH, so 2FA prompts work). See README §10.
#
#   ./deploy.sh devvm59361.lla0.facebook.com
#
set -euo pipefail
DEV="${1:?usage: ./deploy.sh <devserver-host>   e.g. ./deploy.sh devvm1234.abc0.facebook.com}"

echo ">> Syncing source to ${DEV}:~/dbsc_hello …"
rsync -az --delete \
  --exclude target --exclude .git --exclude 'localhost+2*.pem' \
  ./ "${DEV}:~/dbsc_hello/"

echo ">> Building & running on ${DEV} (first build is slow; Ctrl-C to stop) …"
exec ssh -t "${DEV}" 'bash ~/dbsc_hello/run-devserver.sh'
