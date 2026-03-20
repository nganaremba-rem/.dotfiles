#!/bin/bash

swayidle -w \
  timeout 300 "niri msg output * dpms off" \
  timeout 306 "hyprlock" \
  resume "niri msg output * dpms on" \
  before-sleep "hyprlock"
