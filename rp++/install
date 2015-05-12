#!/bin/bash -e 


# 64bit test
if [[ $(uname -m) == 'x86_64' ]];
then
  BIN="rp-lin-x64" 
else
  BIN="rp-lin-x86" 
fi

wget https://github.com/downloads/0vercl0k/rp/$BIN
mv $BIN rp++
mkdir bin
chmod 755 rp++
mv rp++ bin
