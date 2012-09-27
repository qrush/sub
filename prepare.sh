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

echo "Done! Enjoy your new sub!"
echo "Want to make a different sub? Run 'git add .; git checkout -f' and prepare again."
