#!/bin/bash

_clipcopy()
{
  local cur prev opts
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev=()
  opts=""
  if [ $cur -eq "xc*" ];then
	echo $COMP_LINE |xclip -i
	COMPREPLY="sdf"
	return 0
  fi
}

complete -F _clipcopy *
