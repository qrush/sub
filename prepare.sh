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
  test -d bin || mkdir bin
  test -d share/sub && mv share/sub share/$SUBNAME

  for file in libexec/sub*; do
    sed "s/sub/$SUBNAME/g;s/SUB_ROOT/$ENVNAME/g" "$file" > $(echo $file | sed "s/sub/$SUBNAME/")
    rm $file
  done

  for file in libexec/*; do
    chmod a+x $file
  done

  mkdir libexec/tmp
  mv libexec/$SUBNAME*  libexec/tmp && mv libexec/tmp libexec/$SUBNAME
  #ln -s $(pwd)/libexec/$SUBNAME/main bin/$SUBNAME".in"
  
#  sed "s/sub/$SUBNAME/g;s/SUB_ROOT/$ENVNAME/g" "libexec/main" > /tmp/libexecmain \
#	&& cp /tmp/libexecmain libexec/$SUBNAME/main \
#	&&  chmod a+x libexec/$SUBNAME/main\
#	&& rm libexec/main
  sed "s/sub/$SUBNAME/g;s/SUB_ROOT/$ENVNAME/g" "libexec/main" > /tmp/libexecmain \
	&& cp /tmp/libexecmain bin/$SUBNAME".in" \
	&& cp /tmp/libexecmain libexec/$SUBNAME/main 
#	&& rm libexec/main
  #ln -s bin/$SUBNAME".in" $(pwd)/libexec/$SUBNAME/main 
fi

cat << __EOF__ > configure.ac
AC_INIT([$SUBNAME], [0.1], [paolo@lulli.net], [$SUBNAME])
AC_CONFIG_FILES([Makefile bin/Makefile etc/Makefile libexec/Makefile bin/$SUBNAME ])
AM_INIT_AUTOMAKE(foreign)
#AC_PROG_CC
AC_PROG_INSTALL
AC_OUTPUT
__EOF__

cat << __EOF__ > Makefile.am
SUBDIRS = bin libexec etc
__EOF__

cat << __EOF__ > libexec/Makefile.am
#dist_libexec_SCRIPTS =  # to omit subdir
nobase_dist_libexec_SCRIPTS = $SUBNAME\\
	$SUBNAME/main\\
	$SUBNAME/$SUBNAME-commands\\
	$SUBNAME/$SUBNAME-completions\\
	$SUBNAME/$SUBNAME-help\\
	$SUBNAME/$SUBNAME-init\\
	$SUBNAME/$SUBNAME-sh-shell
__EOF__

cat << __EOF__ > bin/Makefile.am
dist_bin_SCRIPTS = $SUBNAME
__EOF__

test -d ./etc || mkdir ./etc
test -d ./etc/$SUBNAME || mkdir ./etc/$SUBNAME

cat << __EOF__ > etc/Makefile.am
#dist_sysconf_DATA = $SUBNAME/$SUBNAME.conf # to omit subdir
nobase_dist_sysconf_DATA = $SUBNAME/$SUBNAME.conf
__EOF__

test -f  etc/$SUBNAME/$SUBNAME.conf || cat << __EOF__ > etc/$SUBNAME/$SUBNAME.conf
#Here your configuration
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
TARGET_DIR=../target
cd \$(dirname \$0);
CURRDIR=\$(pwd)

workdir=\$(mktemp -d /tmp/mkdebian_XXXXXXXX)
mkdir -p \${workdir}/DEBIAN
cp -r ./debian/* \${workdir}/DEBIAN
#./configure "\$@"
./configure --prefix=/
make install DESTDIR=\${workdir}
test -d \$TARGET_DIR || mkdir -p \$TARGET_DIR
dpkg-deb --build \${workdir} \$TARGET_DIR/$SUBNAME-\$VERS.deb

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
