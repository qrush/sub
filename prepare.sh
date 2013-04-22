#!/usr/bin/env bash
set -e

create_sub() {
  file="$1"
  SUBNAME="$2"
  ENVNAME="$3"
  sed "s/sub/$SUBNAME/g;s/SUB_ROOT/$ENVNAME/g" "$file" > $(echo $file | sed "s/sub/$SUBNAME/g")
  rm $file
}

chmod_files() {
  for file in $1/*; do
    chmod a+x $file
  done
}

prepare_sub() {
  SUBNAME="$2"
  mkdir -p $(echo $1 | sed "s/sub/$SUBNAME/g")

  for file in $1/sub*; do
    if [ -d "$file" ]; then
      prepare_sub $file $SUBNAME
    elif [ -f "$file" ]; then
      create_sub $file $SUBNAME $ENVNAME
    fi
  done

  chmod_files $(echo $1 | sed "s/sub/$SUBNAME/g")
  rm -rf $1
}

NAME="$1"
if [ -z "$NAME" ]; then
  echo "usage: prepare.sh NAME_OF_YOUR_SUB" >&2
  exit 1
fi

SUBNAME=$(echo $NAME | tr '[A-Z]' '[a-z]')
ENVNAME="$(echo $NAME | tr '[a-z-]' '[A-Z_]')_ROOT"

echo "Preparing your '$SUBNAME' sub!"

if [ "$NAME" != "sub" ]; then
  rm bin/sub
  mv share/sub share/$SUBNAME

  for file in **/sub*; do
    if [ -d "$file" ]; then
      prepare_sub $file $SUBNAME
    elif [ -f "$file" ]; then
      create_sub $file $SUBNAME $ENVNAME
    fi
  done

  chmod_files "libexec"

  ln -s ../libexec/$SUBNAME bin/$SUBNAME
fi

rm README.md
rm prepare.sh

echo "Done! Enjoy your new sub! If you're happy with your sub, run:"
echo
echo "    rm -rf .git"
echo "    git init"
echo "    git add ."
echo "    git commit -m 'Starting off $SUBNAME'"
echo "    ./bin/$SUBNAME init"
echo
echo "Made a mistake? Want to make a different sub? Run:"
echo
echo "    git add ."
echo "    git checkout -f"
echo
echo "Thanks for making a sub!"

