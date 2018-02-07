#!/bin/sh
# 
# Download hadoop and config system variables for hadoop
# Required: *nix system, JDK1.7+, Git, wget
# Note: Run this script with sudo
# Author: Ninechapter
# 

HADOOP_VERSION='3.0.0'
DOWNLOAD_URL="http://mirrors.tuna.tsinghua.edu.cn/apache/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz"
user=`whoami`

if [ $user != 'root' ]
then
    echo 'Please run this script with root permission'
    exit 1
fi

system=`uname`
JAVA_HOME=$JAVA_HOME

if [ -z $JAVA_HOME ]
then
    if [ $system = 'Darwin' ]
    then
        JAVA_HOME=`/usr/libexec/java_home`
    else
        JAVA_HOME=`dirname $(dirname $(readlink -f $(which javac))))`
    fi
fi

cd ~
if [ ! -e "hadoop-${HADOOP_VERSION}.tar.gz" ]
then
    wget $DOWNLOAD_URL
    echo 'Now extract files...'
    tar xzf hadoop-${HADOOP_VERSION}.tar.gz > /dev/null
    chmod 777 "hadoop-${HADOOP_VERSION}.tar.gz"
    chmod -R 777 "hadoop-${HADOOP_VERSION}"
fi
cd "hadoop-${HADOOP_VERSION}"
HADOOP_HOME=`pwd`
HADOOP_HDFS_HOME="`pwd`/share/hadoop/hdfs"
HADOOP_YARN_HOME="`pwd`/share/hadoop/yarn"
echo "export HADOOP_HOME=${HADOOP_HOME}" >> /etc/profile
echo "export HADOOP_HDFS_HOME=${HADOOP_HDFS_HOME}" >> /etc/profile
echo "export HADOOP_YARN_HOME=${HADOOP_YARN_HOME}">> /etc/profile
echo "export JAVA_HOME=${JAVA_HOME}" >> /etc/profile
echo "export PATH=$PATH:${JAVA_HOME}/bin:${HADOOP_HOME}/bin" >> /etc/profile
echo "Set HADOOP_HOME to ${HADOOP_HOME}"
echo "Set HADOOP_HDFS_HOME to ${HADOOP_HDFS_HOME}"
echo "Set HADOOP_YARN_HOME to ${HADOOP_YARN_HOME}"
echo "Set JAVA_HOME to ${JAVA_HOME}"
