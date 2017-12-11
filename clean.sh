#!/bin/bash
for i in */
do
  cd $i
  git clean -xfd
  cd -
done
