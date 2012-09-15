#!/bin/bash
export EC2_HOME=/opt/ec2-api-tools-1.5.6.0
export JAVA_HOME=/System/Library/Frameworks/JavaVM.framework/Versions/1.6/Home

export EC2_PRIVATE_KEY=/opt/amazon/X.509/pk-<code>.pem
export EC2_CERT=/opt/amazon/X.509/cert-<code>.pem

export EC2_URL=https://ec2.eu-west-1.amazonaws.com

PATH=$PATH:$EC2_HOME/bin
export PATH

INSTANCE=i-<id>

echo "starting $INSTANCE ..."
ec2-start-instances $INSTANCE

while (true)
do
  INSTANCE_HOSTNAME=`ec2-describe-instances $INSTANCE | grep -o "[a-z0-9\.\-]*.amazonaws.com"`
  if (test -z $INSTANCE_HOSTNAME) then
    echo "waiting for instance to start"
    sleep 5
  else
    break
  fi
done

echo "instance given $INSTANCE_HOSTNAME"

while (true)
do
  INSTANCE_STARTED=`ec2-describe-instance-status $INSTANCE | grep -c "INSTANCESTATUS.*passed"`
  if (test $INSTANCE_STARTED = "0") then
    echo "waiting for system to boot"
    sleep 10
  else
    break
  fi
done

sleep 5

echo "system started"

echo "mvn -Ddb.host=$INSTANCE_HOSTNAME"

sleep 20

echo "stopping $INSTANCE ..."
ec2-stop-instances $INSTANCE
