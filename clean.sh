#!/bin/bash
for i in */
do
  cd $i
  git clean -xfd
  git checkout PKGBUILD
  rm -rf src
  cd -
done
