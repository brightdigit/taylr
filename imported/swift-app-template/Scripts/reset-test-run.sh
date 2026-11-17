#!/bin/bash
# Resets a test copy of the repo for end-to-end setup.sh testing.
# Usage: bash Scripts/reset-test-run.sh [destination]
# Defaults to _test-run/ in the repo root if no destination is given.

set -e

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
REPO_ROOT="$SCRIPT_DIR/.."
TEST_DIR="${1:-$REPO_ROOT/_test-run}"

echo "Resetting $TEST_DIR/..."
rm -rf "$TEST_DIR"
rsync -a \
  --exclude='.git' \
  --exclude='_test-run' \
  --exclude='.build' \
  "$REPO_ROOT/" "$TEST_DIR/"

echo "Done. Run setup.sh from _test-run/:"
echo ""
echo '  cd _test-run'
echo '  bash Scripts/setup.sh \'
echo '    --app-name WeatherBar \'
echo '    --team-id ABCDE12345 \'
echo '    --apple-id dev@example.com \'
echo '    --itc-team-id 123456789 \'
echo '    --org-name "Acme Corp" \'
echo '    --github-org acmecorp \'
echo '    --certs-repo "git@github.com:acmecorp/AppCerts.git" \'
echo '    --year 2026 \'
echo '    --marketing-url "https://example.com/" \'
echo '    --privacy-url "https://example.com/privacy-policy.html" \'
echo '    --support-url "https://example.com/support"'
