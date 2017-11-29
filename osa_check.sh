#/usr/bin/env bash

set -e
if [ -d osa_dependencies ]; then
  rm -rf osa_dependencies
fi


echo "Downloading NPM libraries"
if npm install ; then
  ln -s node_modules osa_dependencies
else
  echo "Failed to install NPM libraries"
  exit 1
fi

echo "Downloading Python libraries"
pip_download() {
  pip download \
    -r requirements/deployment.txt \
    -d osa_dependencies
}

if pip_download ; then
  echo "Gathering open source libraries complete"
else
  echo "Failed to download Python libraries"
  exit 1
fi
