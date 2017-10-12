#!/usr/bin/env python3
from subprocess import run, PIPE
from time import sleep
CMD = "xrandr"


def is_display_connected():
  r = run("xrandr", check=True, stdout=PIPE)
  for line in r.stdout.decode().splitlines():
    if line.find('HDMI-1') >= 0 and line.find('disconnected') >= 0:
      return False
  return True


def poll():
  prev_state = None
  while True:
    cur_state = is_display_connected()
    if cur_state != prev_state:
      print(f"status changed: {prev_state} => {cur_state}")
      if cur_state == True:
        run("xrandr --output HDMI-1 --auto", check=True, shell=True)
      else:
        run("xrandr --output HDMI-1 --off", check=True, shell=True)
    prev_state = cur_state
    sleep(2)

if __name__ == '__main__':
  poll()
