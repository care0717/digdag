#!/bin/bash -xe

GH_PAGES_GIT_URL="https://github.com/treasure-data/digdag-docs.git"
GH_PAGES_BRANCH="gh-pages"
CNAME="www.digdag.io"
DOCS_DIR="digdag-docs/build/html"
REVISION="$(git rev-parse HEAD)"
GIT_USER_NAME="Circle CI"
GIT_USER_EMAIL="circleci@digdag.io"

# build the docs
./gradlew site --info --no-daemon

# clone complete repository to gh_pages directory
rm -rf gh_pages
git clone -b "$GH_PAGES_BRANCH" "$GH_PAGES_GIT_URL" gh_pages

# copy the built pages to gh_pages
rm -rf gh_pages/*
cp -a "$DOCS_DIR"/* gh_pages/
cd gh_pages

# some top-level static files
touch ".nojekyll"
if [ -n "$CNAME" ];then
    echo $CNAME > "CNAME"
fi

# push pages to the remote git repo
git add --all .
git config user.name "$GIT_USER_NAME"
git config user.email "$GIT_USER_EMAIL"
git commit -m "Updated document $REVISION" || echo "Nothing to update"

if ! git show | grep -E '^[+-] ' | grep -Eqv 'Generated by|Generated on|Search.setIndex|meta name="date" content='; then
    echo "No document changes."
    exit 0
fi

git config credential.helper "store --file=$HOME/.git_credentials"

echo "https://$GITHUB_TOKEN:@github.com" > "$HOME/.git_credentials"
trap "rm -rf $HOME/.git_credentials" EXIT

git push -f origin "$GH_PAGES_BRANCH"
