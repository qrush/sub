#!/usr/bin/env bash
set -e

NAME="$1"
if [ -z "$NAME" ]; then
  echo "usage: prepare.sh NAME_OF_YOUR_SUB" >&2
  exit 1
fi

SUBNAME=$(echo $NAME | tr '[A-Z]' '[a-z]')
ENVNAME="$(echo $NAME | tr '[a-z]' '[A-Z]')_ROOT"

echo "Preparing your $SUBNAME sub!"

rm bin/sub
mv share/sub share/$SUBNAME

for file in **/sub*; do
  SUBFILE=$(echo $file | sed "s/sub/$SUBNAME/")
  sed "s/sub/$SUBNAME/g" $file | sed "s/SUB_ROOT/$ENVNAME/g" > $SUBFILE
  rm $file
done

for file in libexec/*; do
  chmod a+x $file
done

ln -s ../libexec/$SUBNAME bin/$SUBNAME

rm LICENSE
rm README.md
rm prepare.sh

echo "Done! Enjoy your new sub! If you're happy with your sub, run:"
echo
echo "    rm -rf .git"
echo "    git init"
echo "    git add ."
echo "    git commit -m 'Starting off $SUBNAME'"
echo
echo "You might want to rename this directory too after that."
echo "Made a mistake? Want to make a different sub? Run:"
echo
echo "    git add ."
echo "    git checkout -f"
echo
echo "Thanks for making a sub!"
