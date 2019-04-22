#!/bin/bash

sleep 1
chown www-data:www-data $1
chmod u+w,u+r,g+w,g+r,o+w,o+r $1

