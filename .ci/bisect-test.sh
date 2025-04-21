#!/usr/bin/env bash
# bisect-test.sh: invoked by `git bisect run` to test whether the current
# commit passes the stable‑macos workflow logic.
# The script is intentionally simple: it uses `act` to run the `build` job of
# .github/workflows/stable-macos.yml and propagates the exit status so that
# git‑bisect can mark the commit good (0) or bad (non‑zero).

set -euo pipefail

WORKFLOW_FILE=".github/workflows/stable-macos.yml"
JOB_NAME="build"

# Some workflows reference secrets or GitHub-specific env vars.  Provide safe
# defaults so that the steps don’t fail immediately during local evaluation.
export GITHUB_TOKEN="dummy-token"
export STRONGER_GITHUB_TOKEN="dummy-strong-token"
export GITHUB_BRANCH="$(git rev-parse --abbrev-ref HEAD)"

# Certificate variables expected by "Prepare assets" step
export CERTIFICATE_OSX_NEW_APP_PASSWORD="x"
export CERTIFICATE_OSX_NEW_ID="x"
export CERTIFICATE_OSX_NEW_P12_DATA="x"
export CERTIFICATE_OSX_NEW_P12_PASSWORD="x"
export CERTIFICATE_OSX_NEW_TEAM_ID="x"

# Inputs (act passes them via env vars) – set to benign defaults
ACT_INPUT_FORCE_VERSION="false"
ACT_INPUT_GENERATE_ASSETS="false"
ACT_INPUT_CHECKOUT_PR=""
ACT_INPUT_VOID_COMMIT=""

# Run the job with act.  Use --reuse to speed up repeated runs during bisect.
act \
  --workflows "${WORKFLOW_FILE}" \
  --job "${JOB_NAME}" \
  --event "workflow_dispatch" \
  --input force_version=${ACT_INPUT_FORCE_VERSION} \
  --input generate_assets=${ACT_INPUT_GENERATE_ASSETS} \
  --input checkout_pr="${ACT_INPUT_CHECKOUT_PR}" \
  --input void_commit="${ACT_INPUT_VOID_COMMIT}" \
  --reuse