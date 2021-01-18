#!/bin/bash

file="/tmp/module_check"
module --version 2>&1 > /dev/null
if [ $? -ne 0 ]
  then
  echo "100" > $file
else
   module --version 2>&1 | grep -i 'lua' > /dev/null
   if [ $? -eq 0 ]
    then
    echo "101" > $file
  else
    echo "102" > $file
  fi
fi
