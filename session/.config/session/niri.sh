#!/bin/bash

swayidle -w \
  timeout 300 "niri msg action power-off-monitors" \
  timeout 310 "hyprlock" \
  resume "niri msg action power-on-monitors" \
  before-sleep "hyprlock"
