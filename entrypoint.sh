#!/bin/bash
#
# Copyright 2023 Naive Systems Ltd.
#
# This software contains information and intellectual property that is
# confidential and proprietary to Naive Systems Ltd. and its affiliates.

set -o errexit
set -o nounset
set -o pipefail

entrypoint() {
  cp -r /github/workspace /src
  if [[ -d /github/workspace/.naivesystems ]]; then
    cp -r /github/workspace/.naivesystems /config
  else
    mkdir /config
  fi
  if [[ ! -f /config/check_rules ]]; then
    cp /opt/naivesystems/google_cpp.check_rules.txt /config/check_rules
  fi
  mkdir -p /output
  cd /src
  /opt/naivesystems/misra_analyzer -show_results
  echo
  cat /github/workflow/event.json
  echo
  cp /opt/naivesystems/matcher.json /github/home/matcher.json
  echo "::add-matcher::/github/home/matcher.json"
  /opt/naivesystems/github_printer --results_path /output/results.nsa_results --github_commenter_scope hunk
}

entrypoint "$@"
