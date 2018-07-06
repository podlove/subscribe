#!/usr/bin/env bash

set -e # exit on error

mix edeliver build release production
mix edeliver deploy release to production
mix edeliver restart production
