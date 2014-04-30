cd ~ 
#sudo apt-get update

# Download java jdk
sudo apt-get install openjdk-7-jdk
cd /usr/lib/jvm
sudo ln -s java-7-openjdk-amd64 jdk

# Uncommment to install ssh 
sudo apt-get install openssh-server

# Add hadoop user
sudo addgroup hadoop
sudo adduser --ingroup hadoop hadoop
sudo adduser hadoop sudo

# Generate keys
sudo -u hadoop ssh-keygen -t rsa -P ''
sudo sh -c 'cat /home/hadoop/.ssh/id_rsa.pub >> /home/hadoop/.ssh/authorized_keys'
#ssh localhost
ssh-keygen -t rsa -P ''
sh -c 'cat /home/vagrant/.ssh/id_rsa.pub >> /home/vagrant/.ssh/authorized_keys'

sudo pkill -9 java
hadoop_site="http://mirrors.cnnic.cn/"
hadoop_version="2.4.0"

# Download Hadoop and set permissons
cd ~
if [ ! -f "hadoop-$hadoop_version.tar.gz" ]; then
	wget $hadoop_site/apache/hadoop/common/hadoop-$hadoop_version/hadoop-$hadoop_version.tar.gz
fi
sudo tar vxzf hadoop-$hadoop_version.tar.gz -C /usr/local
cd /usr/local
if [ -d "hadoop" ]; then
    echo "backup hadoop directory"
    sudo mkdir -p hadoop.baks
    sudo mv -i hadoop hadoop.baks/
fi
sudo mv hadoop-$hadoop_version hadoop
sudo chown -R hadoop:hadoop hadoop

# Hadoop variables
sudo sh -c 'echo export JAVA_HOME=/usr/lib/jvm/jdk/ >> /home/hadoop/.bashrc'
sudo sh -c 'echo export HADOOP_INSTALL=/usr/local/hadoop >> /home/hadoop/.bashrc'
sudo sh -c 'echo export PATH=\$PATH:\$HADOOP_INSTALL/bin >> /home/hadoop/.bashrc'
sudo sh -c 'echo export PATH=\$PATH:\$HADOOP_INSTALL/sbin >> /home/hadoop/.bashrc'
sudo sh -c 'echo export HADOOP_MAPRED_HOME=\$HADOOP_INSTALL >> /home/hadoop/.bashrc'
sudo sh -c 'echo export HADOOP_COMMON_HOME=\$HADOOP_INSTALL >> /home/hadoop/.bashrc'
sudo sh -c 'echo export HADOOP_HDFS_HOME=\$HADOOP_INSTALL >> /home/hadoop/.bashrc'
sudo sh -c 'echo export YARN_HOME=\$HADOOP_INSTALL >> /home/hadoop/.bashrc'
sudo sh -c 'echo export HADOOP_COMMON_LIB_NATIVE_DIR=\$\{HADOOP_INSTALL\}/lib/native >> /home/hadoop/.bashrc'
sudo sh -c 'echo export HADOOP_OPTS=\"-Djava.library.path=\$HADOOP_INSTALL/lib\" >> /home/hadoop/.bashrc'

# Modify JAVA_HOME 
cd /usr/local/hadoop/etc/hadoop
sudo -u hadoop sed -i.bak s=\${JAVA_HOME}=/usr/lib/jvm/jdk/=g hadoop-env.sh
pwd

# Check that Hadoop is installed
/usr/local/hadoop/bin/hadoop version

# Edit configuration files
sudo -u hadoop sed -i.bak 's=<configuration>=<configuration>\<property>\<name>fs\.default\.name\</name>\<value>hdfs://0.0.0.0:8020\</value>\</property>=g' core-site.xml 
sudo -u hadoop sed -i.bak 's=<configuration>=<configuration>\<property>\<name>yarn\.nodemanager\.aux-services</name>\<value>mapreduce_shuffle</value>\</property>\<property>\<name>yarn.nodemanager.aux-services.mapreduce.shuffle.class</name>\<value>org\.apache\.hadoop\.mapred\.ShuffleHandler</value>\</property>=g' yarn-site.xml
  
sudo -u hadoop cp mapred-site.xml.template mapred-site.xml
sudo -u hadoop sed -i.bak 's=<configuration>=<configuration>\<property>\<name>mapreduce\.framework\.name</name>\<value>yarn</value>\</property>=g' mapred-site.xml
 
sudo -u hadoop mkdir -p /home/hadoop/data/hdfs/namenode
sudo -u hadoop mkdir -p /home/hadoop/data/hdfs/datanode

cd /usr/local/hadoop/etc/hadoop
sudo -u hadoop sed -i.bak 's=<configuration>=<configuration>\<property>\<name>dfs\.replication</name>\<value>1\</value>\</property>\<property>\<name>dfs\.namenode\.name\.dir</name>\<value>file:/home/hadoop/data/hdfs/namenode</value>\</property>\<property>\<name>dfs\.datanode\.data\.dir</name>\<value>file:/home/hadoop/data/hdfs/datanode</value>\</property>=g' hdfs-site.xml

# Format Namenode
sudo -u hadoop sh -c '/usr/local/hadoop/bin/hdfs namenode -format'

# Start Hadoop Service
sudo -u hadoop '/usr/local/hadoop/sbin/start-dfs.sh'
sudo -u hadoop '/usr/local/hadoop/sbin/start-yarn.sh'

# Check status
sudo -u hadoop jps

# Example
# sudo su hadoop 
# cd /usr/local/hadoop
# hadoop jar ./share/hadoop/mapreduce/hadoop-mapreduce-examples-2.4.0.jar pi 2 5
# sudo -u hadoop hadoop jar ./share/hadoop/mapreduce/hadoop-mapreduce-examples-2.2.0.jar pi 2 5

