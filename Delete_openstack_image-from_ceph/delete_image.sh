#!/bin/bash

rbd --pool glance-images snap unprotect --image $1 --snap snap
rbd --pool glance-images snap purge $1