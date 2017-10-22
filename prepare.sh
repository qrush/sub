#!/usr/bin/env bash
set -e

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
    sed "s/sub/$SUBNAME/g;s/SUB_ROOT/$ENVNAME/g" "$file" > $(echo $file | sed "s/sub/$SUBNAME/")
    rm $file
  done

  for file in libexec/*; do
    chmod a+x $file
  done

  ln -s ../libexec/$SUBNAME bin/$SUBNAME".in"
fi

cat << __EOF__ > configure.ac
AC_INIT([$SUBNAME], [0.1], [paolo@lulli.net], [$SUBNAME])
AC_CONFIG_FILES([Makefile bin/Makefile libexec/Makefile bin/$SUBNAME])
AM_INIT_AUTOMAKE(foreign)
#AC_PROG_CC
AC_PROG_INSTALL
AC_OUTPUT
__EOF__

cat << __EOF__ > Makefile.am
SUBDIRS = bin libexec
__EOF__

cat << __EOF__ > libexec/Makefile.am
dist_libexec_SCRIPTS = $SUBNAME\
	$SUBNAME-commands\
	$SUBNAME-completions\
	$SUBNAME-help\
	$SUBNAME-init\
	$SUBNAME-sh-shell
__EOF__

cat << __EOF__ > bin/Makefile.am
dist_bin_SCRIPTS = $SUBNAME
__EOF__

rm README.md
rm prepare.sh

echo "#! /bin/sh" > automake.sh 
echo "aclocal && automake -a -c && autoconf" >> automake.sh 
chmod 755 automake.sh
./automake.sh

cat << EOF > makedeb.sh
#!/usr/bin/env bash

VERS=1.0.0
cd \$(dirname \$0);
CURRDIR=\$(pwd)

workdir=\$(mktemp -d /tmp/mkdebian_XXXXXXXX)
mkdir -p \${workdir}/DEBIAN
cp -r ./debian/* \${workdir}/DEBIAN
./configure "\$@"
make install DESTDIR=\${workdir}
dpkg-deb --build \${workdir} ../$SUBNAME-$VERS.deb

EOF
chmod 755 makedeb.sh

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
