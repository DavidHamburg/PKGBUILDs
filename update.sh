#!/bin/bash
for i in */
do
    if [ "$i" != "testing/" ] && [ "$i" != "patches/" ]
    then
        cd $i
        git checkout master
        git pull origin master
        cd -
    fi
done
#cd testing
#for i in */
#do
#    if [ "$i" != "patches/" ]
#    then
#        cd $i
#        git checkout master
#        git pull origin master
#        cd -
#    fi
#done
