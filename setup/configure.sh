#!/usr/bin/bash

homeDir=/home/pi
SOFTWARE_HOME=/home/pi/Software
SCALA_HOME=${SOFTWARE_HOME}/Scala/scala-2.13.8
SPARK_HOME=${SOFTWARE_HOME}/Spark/spark-3.2.1
HADOOP_HOME=${SOFTWARE_HOME}/Hadoop/hadoop-3.3.1
HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop


function _setupSoftware {

  apt-get install vim
  apt-get install default-jdk

  if test -e $homeDir/Software
  then
    rm -R $SOFTWARE_HOME
  fi

  mkdir $SOFTWARE_HOME
  mkdir $SOFTWARE/Software/Scala
  mkdir $SOFTWARE/Software/Spark
  mkdir $SOFTWARE/Software/Hadoop

  tar -xvf scala-2.13.8.tgz -C $homeDir/Software/Scala
  tar -xvf spark-3.2.1.tgz -C $homeDir/Software/Spark; mv $homeDir/Software/Spark/spark-3.2.1-bin-hadoop3.2-scala2.13 $homeDir/Software/Spark/spark-3.2.1
  tar -xvf hadoop-3.3.1.tar.gz -C $homeDir/Software/Hadoop

  cat bashrc > $homeDir/.bashrc

  echo 'export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-armhf' >> ${HADOOP_CONF_DIR}/hadoop-env.sh

  cat core-site.xml > $HADOOP_CONF_DIR/core-site.xml
  cat hdfs-site.xml > $HADOOP_CONF_DIR/hdfs-site.xml
  cat mapred-site.xml > $HADOOP_CONF_DIR/mapred-site.xml
  cat yarn-site.xml > $HADOOP_CONF_DIR/yarn-site.xml

  mkdir -p /home/pi/Software/Hadoop/hdfs/namenode
  mkdir -p /home/pi/Software/Hadoop/hdfs/datanode

  mv ${SPARK_HOME}/conf/spark-defaults.conf.template ${SPARK_HOME}/conf/spark-defaults.conf
  cat spark-conf > spark-defaults.conf

  chown -R pi:pi ${SOFTWARE_HOME}

}

function _setDhcp {
  cat dhcpcd-conf > /etc/dhcpcd.conf
  echo "static ip_address=192.168.1.10$1/24" >> /etc/dhcpcd.conf
}

function _setHosts {
  echo "" > /etc/hosts
  for i in 1 2 3 4
  do
      echo "192.168.1.10$i raspberrypi$i" >> /etc/hosts
  done


  echo "raspberrypi${1}" > /etc/hostname
}

function _setSsh {

  sshDir="$homeDir/.ssh"
  if ! test -e $sshDir
  then
  	mkdir $sshDir

  	touch $sshDir/config
	touch $sshDir/authorized_keys
  else
	   echo "" > $sshDir/config
	   echo "" > $sshDir/authorized_keys
  fi

  for i in 1 2 3 4
  do
    if [[ $i -ne $1 ]]
    then
      echo "
      Host raspberrypi$i
      User pi
      Hostname 192.168.1.10$i" >> $sshDir/config
    fi
  done

}

if [[ $# -eq 1 ]]
then
  _setupSoftware
  _setDhcpcd $1
  _setHosts $1
  _setSsh $1
  if [[ $1 -eq 1 ]]; then
    mkdir homeDir/SSH
    mkdir homeDir/SSH/tmp
  fi
  echo "OK"
elif [[ $# -eq 2 ]]
then
  $1 $2
  echo "OK"
else
  echo "error: not enough arguments"
  exit 1
fi
