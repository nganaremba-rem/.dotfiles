#!/bin/bash

swayidle -w \
  timeout 10 'dpms off' \
  timeout 16 'swaylock -f' \
  resume 'dpms on' \
  before-sleep 'swaylock -f'
