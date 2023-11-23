#! /bin/bash

FILES=$1

git add --intent-to-add $FILES
git update-index --assume-unchanged $FILES
