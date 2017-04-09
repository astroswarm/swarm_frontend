#!/usr/bin/env sh

elm-make Main.elm --output main.js --warn --yes

cp index.html build/
cp main.js build/