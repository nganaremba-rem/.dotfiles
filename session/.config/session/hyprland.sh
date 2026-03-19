#!/bin/bash

swayidle -w \
  timeout 300 "hyprctl dispatch dpms off" resume "hyprctl dispatch dpms off" \
  timeout 306 "hyprlock" \
  resume "hyprctl dispatch dpms on" \
  before-sleep "hyprlock"
