#!/bin/bash

swayidle -w \
  timeout 300 'brightnessctl set 20%' \
  timeout 306 'swaylock -f' \
  resume 'brightnessctl set 40%' \
  before-sleep 'swaylock -f'
