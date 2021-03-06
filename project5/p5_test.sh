#!/bin/bash
GRADING_DIR=$HOME/grading
TMP_DIR=/tmp/p5-grading/
REQUIRED_FILES="team.txt topUsers.scala"
MAIN_CODE="topUsers.scala"

# usage
if [ $# -ne 1 ]
then
     echo "Usage: $0 project5.zip" 1>&2
     exit 1
fi

# make sure that the script runs on VM
if [ `hostname` != "cs144" ]; then
     echo "ERROR: You need to run this script within the class virtual machine" 1>&2
     exit 1
fi

ZIP_FILE=$1

# clean any existing files
rm -rf ${TMP_DIR}

# create temporary directory used for grading
mkdir ${TMP_DIR}

# unzip the zip file
if [ ! -f ${ZIP_FILE} ]; then
    echo "ERROR: Cannot find $ZIP_FILE" 1>&2
    rm -rf ${TMP_DIR}
    exit 1
fi
unzip -q -d ${TMP_DIR} ${ZIP_FILE}
if [ "$?" -ne "0" ]; then 
    echo "ERROR: Cannot unzip ${ZIP_FILE} to ${TMP_DIR}"
    rm -rf ${TMP_DIR}
    exit 1
fi

# change directory to the partc folder
cd ${TMP_DIR}

# check the existence of the required files
for FILE in ${REQUIRED_FILES}
do
    if [ ! -f ${FILE} ]; then
    echo "ERROR: Cannot find ${FILE} in the root folder of ${ZIP_FILE}" 1>&2
    rm -rf ${TMP_DIR}
    exit 1
    fi
done

# create test twitter.edges file
for i in {1..1010}
do
    echo "$i: 10,20,99" >> twitter.edges
done

# append System.exit(0) call at the end of the code to ensure exiting from the shell
echo "" >> ${MAIN_CODE}
echo "System.exit(0)" >> ${MAIN_CODE}

# run the student code
echo "Executing your Spark code....." 1>&2
spark-shell -i ${MAIN_CODE}

# check if the expected output directory and files have been generated
if [ ! -d output ]; then
    echo "ERROR: Output directory "output" was not created by your Spark code" 1>&2
    rm -rf ${TMP_DIR}
    exit 1
fi
if [ ! -f 'output/part-00000' ]; then
    echo "ERROR: Cannot find the output file output/part-00000 after your code is run" 1>&2
    rm -rf ${TMP_DIR}
    exit 1
fi
cat "output/part-00000" 1>&2

# clean up
rm -rf ${TMP_DIR}

echo
echo "SUCCESS! We finished testing your zip file integrity." 1>&2
exit 0