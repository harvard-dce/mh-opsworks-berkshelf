#!/usr/bin/env bats

@test "utility packages are installed" {
  for package in htop nmap traceroute silversearcher-ag tmux iotop mytop pv; do\
    run dpkg -l "$package"
      [ "$status" -eq 0 ]
  done;
}
