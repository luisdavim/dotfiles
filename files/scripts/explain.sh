#!/bin/bash

set -euo pipefail

response=$(w3m -dump "http://explainshell.com/explain?cmd=$(echo "$*" | tr ' ' '+')")
cat -s <(grep -v -e explainshell -e • -e □ -e "source manpages" <<< "$response")
