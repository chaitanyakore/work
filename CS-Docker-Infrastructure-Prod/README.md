###Steps to create Docker Images for DEMO/PROD Environment (Development is in Progress of Docker Files)


####Repo
1. Clone the Repo (Docker Files)
Link to the [Repo](https://user.name@git.contentserv.com/DevOps/Deployment/CS-Docker-Infrastructure-Prod)
2. Switch to *dev* branch
3. Go to *CS18.0*
 
Note: 
1. Have a copy of *admin* and *admin.local* at Ubuntu-Apache-PHP/ . These folders will get copied while image is being created (Remove *.svn* folder from both the directories)
~~Skip step 2 as we have provided a variable in '.env' file  where zabbix server's IP can be defined (In Docker Compose)~~
~~2. Add Zabbix Server's IP in config/zabbix_agentd.conf before you build any image. (e.g ServerActive=172.17.0.5:10051)~~
3. Define Password for MySql root user in "Ubuntu-MariaDB/config/setpass.sh". (e.g MYSQL_ROOT_PASSWORD=abcd1234) 
4. Define Username/Password for ActiveMQ in "Ubuntu-ActiveMQ/conf/credentials.properties" 

####Command to Build Docker Images
1. Go to Context Directory, i.e. base directory of Dockerfile
2. Execute-> docker build --no-cache  -t ImageName:csversion . 
	(
	e.g. 
	cd Ubuntu-ActiveMQ
	docker build --no-cache  -t activemqprod:cs18 .	
	)


####Zabbix Server
Use the follwing command if you want to setup a Zabbix Server
Command: docker run --network cs --name zabbix-server  -p 80:80 -p 10051:10051 -d zabbix/zabbix-appliance
Here, the network should be same as that of other containers in the stack

