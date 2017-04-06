#!/bin/sh

REV=$((`git rev-list HEAD --count` + 2383))

echo "static const int SVN_REV = $REV;" > svnrev.h
echo "#include \"starcraftver.h\"" >> svnrev.h
