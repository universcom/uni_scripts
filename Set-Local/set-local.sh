#!/bin/bash
#set locale on server. sometimes the server locale is misconfigured and this is needed.

export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
locale-gen en_US.UTF-8
sudo dpkg-reconfigure locales