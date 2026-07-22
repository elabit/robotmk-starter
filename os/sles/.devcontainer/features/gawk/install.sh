#!/usr/bin/env bash
set -euo pipefail

zypper --non-interactive refresh
zypper --non-interactive install gawk
