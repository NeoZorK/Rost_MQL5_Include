#!/bin/sh
# Script Modified by Shcherbyna Rostyslav 24.09.2024
# Rename Autor and Email to Corrected One in ALL GIT Repositry History
# it searche for not corrected email and fix it to corrected
#
# using:
# 1. Copy this file to GIT Repository folder
# 2. run it from terminal : bash grn.sh
#
# Use this if backup cannot rewrite self :
# bash git for-each-ref --format="%(refname)" refs/original/ | xargs -n 1 git update-ref -d

#git filter-branch --env-filter '
#CORRECT_NAME="Ростислав Щербина"
#CORRECT_EMAIL="neozork@protonmail.com"
#if [ "$GIT_COMMITTER_EMAIL" != "$CORRECT_EMAIL" ]
#then
#    export GIT_COMMITTER_NAME="$CORRECT_NAME"
#    export GIT_COMMITTER_EMAIL="$CORRECT_EMAIL"
#fi
#if [ "$GIT_AUTHOR_EMAIL" != "$CORRECT_EMAIL" ]
#then
#    export GIT_AUTHOR_NAME="$CORRECT_NAME"
#    export GIT_AUTHOR_EMAIL="$CORRECT_EMAIL"
#fi
#' --tag-name-filter cat -- --branches --tags

# After this Clear Backup
#w


# Change Name to Correct One
git filter-branch --env-filter '
CORRECT_NAME="Ростислав Щербина"
CORRECT_EMAIL="neozork@protonmail.com"
if [ "$GIT_AUTHOR_NAME" != "$CORRECT_NAME" ]
then
    export GIT_COMMITTER_NAME="$CORRECT_NAME"
    export GIT_COMMITTER_EMAIL="$CORRECT_EMAIL"
    export GIT_AUTHOR_NAME="$CORRECT_NAME"
    export GIT_AUTHOR_EMAIL="$CORRECT_EMAIL"
fi
' --tag-name-filter cat -- --branches --tags
