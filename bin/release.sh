#!/usr/bin/env bash

set -e # exit on error

mix edeliver build release production
mix edeliver deploy release to production --version=0.1.0
mix edeliver restart production
