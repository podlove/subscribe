#!/usr/bin/env bash

set -e # exit on error

mix edeliver build release production
mix edeliver deploy release to production --version=0.0.2
mix edeliver restart production
