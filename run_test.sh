#!/bin/bash -x

docker ps | grep emodis > /dev/null
if [ $? == 0 ]; then
  echo "docker running an emodis already - that might not make sense - already running a test?"
  exit 1
fi

if [ ! -d ./test/2016-test ]; then
  echo 'extracting test/2016-test.tar to test/input'
  tar xf ./test/2016-test.tar -C ./test/
else
  echo 'detected test data available in test/2016-input - skipping extraction'
fi

if [ ! -d ./test/output ]; then
  echo 'creating output directory';
  mkdir ./test/output
else
  echo 'detected existing output directory ... should we clean it up????'
fi

if [ ! -d ../emodis_ndvi_python ]; then
  echo "missing ../emodis_ndvi_python - please checkout latest verison of code"
  echo "cd ..; git clone git@github.com:gina-alaska/emodis_ndvi_python.git"
  echo "then re-run test.sh"
  exit 1
fi

CODE_DIR=`realpath ../emodis_ndvi_python`
INPUT_DIR=`realpath ./test/2016-test`
OUTPUT_DIR=`realpath ./test/output`
RUN_SCRIPT='scripts/ver-for-docker/run_test_data.bash'
LAUNCH_USER=`whoami`
USER_UID=`id -u $LAUNCH_USER`
USER_GID=`id -g $LAUNCH_USER`

echo MODEL_DIR=$MODEL_DIR
echo INPUT_DIR=$INPUT_DIR
echo OUTPUT_DIR=$OUTPUT_DIR
echo RUN_SCRIPT=$RUN_SCRIPT

if [ ! -f $CODE_DIR/$RUN_SCRIPT ]; then
  "run script missing: $RUN_SCRIPT from $CODE_DIR"
  exit 1
fi

echo "#### Launching Docker #####"

docker run emodis_ndvi_python:latest \
  -it \
  -e UID=$USER_UID \
  -e GID=$USER_GID \
  -e HOME_EXC='/test/code/' \
  -e HOME_DATA='/test/input' \
  -v ${INPUT_DIR}:'/test/input' \
  -v ${OUTPUT_DIR}:'/test/output' \
  -v ${CODE_DIR}:'/test/code' \
  bash

$CMD

#  /test/code/$RUN_SCRIPT 
