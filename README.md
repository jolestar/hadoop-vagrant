hadoop-vagrant
==============

hadoop vagrant single node deploy script.
origin script come from https://github.com/ericduq/hadoop-scripts

### Prerequisites
* [vagrant](http://www.vagrantup.com/) 
* vagrant ubuntu iamge (vagrant box add ubuntu) 

### Usage

		vagrant up
		vagrant ssh
		cd hadoop-vagrant/
		sh make-single-node.sh
		# vagrant user password is vagrant
		sudo su hadoop
		cd /usr/local/hadoop
		/usr/local/hadoop/sbin/start-dfs.sh
		/usr/local/hadoop/sbin/start-yarn.sh
		hadoop jar ./share/hadoop/mapreduce/hadoop-mapreduce-examples-2.4.0.jar pi 2 5

## Usage on Host Machine
vagrant vm ip is 192.168.33.14
	
	./hdfs dfs -ls  hdfs://192.168.33.14:8020/
	
	# spring yarm example (https://github.com/spring-projects/spring-hadoop-samples/)
	
	./gradlew -q run-yarn-examples-simple-command -Dhd.fs=hdfs://192.168.33.14:8020 -Dhd.rm=192.168.33.14:8032 -Dlocalresources.remote=hdfs://192.168.33.14:8020
	./gradlew -q run-yarn-examples-list-applications -Dhd.fs=hdfs://192.168.33.14:8020 -Dhd.rm=192.168.33.14:8032 -Dlocalresources.remote=hdfs://192.168.33.14:8020
