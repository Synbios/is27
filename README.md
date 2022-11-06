# IS27 Application Test Solutions
## Mike Zhou, youz@ualberta.ca


Here are the solutions for the three challenges received on Nov 3, 2022. While the related files of the solutions are stored in the three folders (solution_1, solution_2, and solution_3), I will put the answers in this file for better readability.

### Challenges 1
.
> GeoServer (https://geoserver.org/) is open-source software for sharing geospatial data via web services. Create an automated solution, using the technology of your choice, to perform an installation of GeoServer and all dependencies in a reproducible manner.  Some independent research may be required to support your solution approach.
Take notes of your decisions, observations, and assumptions and include them in the submission. If you move on to the interview stage of the competition, you will be asked to deliver a short presentation describing your decisions and thought process for designing the solution.

###### Required Deliverable (20 marks):
- A link to a publicly accessible source control repository containing your attempted solution & documentation.
- A method of verifying your solution such as installer log output (either in repo or in a reporting interface).
###### Optional/Recommended Deliverables (30 marks):
- Geoserver is deployed in a containerized (e.g. docker or k8s) environment.
- A CI/CD deployment pipeline deploying containerized GeoServer to a publicly accessible (cloud or otherwise) hosted environment of your choosing.
- A method of verifying your solutions such as login credentials for publicly available UI.

##### MY ANSWER:

###### 1. Docker Installation:
My solution is to install GeoServer in a Docker container and deploy it on AWS Elastic Container Service (i.e. ECS). The Dockerfile can be found in the solution 1 folder ([Dockerfile](solution_1/Dockerfile)). Here are the instructions to build and test the docker solution:

1. Install Docker (https://docs.docker.com/get-docker/). It's recommended to test this solution on Mac or Linux.
2. Download the Dockerfile and save it to your work directory.
```sh
mkdir solution1
cd solution1
curl dillinger
```
3. You can now build the docker container with the **docker build** command.
```sh
docker build . -f Dockerfile -t test:latest
```
4. You can see the built image
```
docker image ls
REPOSITORY          TAG       IMAGE ID       CREATED        SIZE
test                latest    272a848cf53f   9 hours ago    727MB
```
5. Run the docker container on **localhost:3000**. Please note that GeoServer runs on port 8080 in the container.
```sh
docker run -p 3000:8080 test:latest
```
6. Open your browser and visit http://0.0.0.0:3000/geoserver/index.html. You should see the welcome page of the Wicket server.
7. You can curl the status API to verify if the REST API works (which is the main GeoServer package). It should return a valid response.
```
curl -u admin:geoserver -XGET http://localhost:3000/geoserver/rest/about/version.xml
<about>
  <resource name="GeoServer">
    <Build-Timestamp>23-Oct-2022 05:18</Build-Timestamp>
    <Version>2.21.2</Version>
    <Git-Revision>ae56ccb68616bcfcc98bd21a6dd21023207bbdb8</Git-Revision>
  </resource>
  <resource name="GeoTools">
    <Build-Timestamp>23-Oct-2022 04:36</Build-Timestamp>
    <Version>27.2</Version>
    <Git-Revision>0578a5b83add97046cb064997acf6f17d5ae331d</Git-Revision>
  </resource>
  <resource name="GeoWebCache">
    <Version>1.21.2</Version>
    <Git-Revision>1.21.x/d3c396779c7906f99347c3ca6b9bd52f2ab4063c</Git-Revision>
  </resource>
</about>
```
8. To verify if the MySQL plugin is installed: 1) log in to the admin panel using The default login username **admin** and password **geoserver**. 2) On the left menu click **store** then on the top of the right panel **add new store**. You should see MySQL as a store option (it will not appear if the MySQL plugin is not installed)

[![MySQL plugin is installed](https://geoserver-demo.s3.us-west-2.amazonaws.com/mysql-installed.png)](https://geoserver-demo.s3.us-west-2.amazonaws.com/mysql-installed.png)

Here is the docker build log file, as required [local_docker_build.log](solution_1/local_docker_build.log)

###### 2. Automated Deployment:
The docker container is deployed in AWS Elastic Container Cluster (ECS). A CI/CD pipeline is built to automate the deployment as required. I will first discuss the architecture of the GeoServer ECS and then I will explain how to use the CI/CD pipeline.

**GeoServer on AWS ECS**

First, below is a figure of the overall architectural design. A Virtual Private Cloud (VPC) is created for this deployment demonstration. The VPC is used to group docker containers and internal file systems so they are both well organized and well protected from outside networks. On the VPC, ECS manages a cluster of GeoServer containers. They are replicates of the docker image created in the previous step, and each of them is assigned to a private ip on the VPC. A load balancer (LB) is added to allow public access to the containers. The LB will evenly distribute inbound requests to all available target containers. It also checks the containers for connectivity and response time.

Unhealthy containers will be removed from the target list and tagged for recycling. The ECS has configurable values for the min and the max number of containers in the cluster, and a policy to change them based on the number of requests. (I set it to just 1 for this demonstration but I can show you how to change them).  On the other end, the containers are mounted on an Elastic File System (EFS) to store data. The EFS is required because the docker virtual disk is not persistent and all changes will be wiped when the container stops. I set the mounting point to be **/mnt/efs_data** thus all writable data need to go there. Also, an external data disk means we can host a large amount of data without worry the docker image grows too big. An alternative way for EFS is to use an external database or even S3 to store the data. It is illustrated in the figure but I did not create either the DB or S3 bucket.

[![Figure 1: Architecture of GeoServer Clutser Installation](https://geoserver-demo.s3.us-west-2.amazonaws.com/geoserver-fig1.jpg)](https://geoserver-demo.s3.us-west-2.amazonaws.com/geoserver-fig1.jpg)

#### DELIVERABLE URL
**The public DNS of the load balancer is:** http://demolb2-1655074011.us-west-2.elb.amazonaws.com/geoserver/index.html

To verify if the EFS is installed, log in using the default username and password (**admin** and **geoserver**) and try to create a new store using GeoPackage. You should be able to install a package from **/mnt/efs_data/geodata/data_on_shared_disk.gpkg**. This file is stored in EFS.

[![EFS installed screenshot](https://geoserver-demo.s3.us-west-2.amazonaws.com/efs-installed.png)](https://geoserver-demo.s3.us-west-2.amazonaws.com/efs-installed.png)


**CI/CD pipeline**
For the CI/CD pipeline I used AWS Codepiple (https://aws.amazon.com/codepipeline/). The pipeline file **buildspec.yml** can be found in the solution1 folder. The pipeline listens to a Codecommit repository on my AWS account (which containers only the Dockerfile and the buildspec.yml file). Once I push a new commit to the **master** branch of the repository, the pipeline will be triggered and it will automatically build a new docker image and deploy it to the ECS platform. As there is no log, I put a few screenshots in the solution1/CI_CD folder that can prove the CI/CD pipeline works. I can also give you a live demo if I move to the next round.


###### Additional information:
Here are some of my assumptions. They are not required as of now but I found they are useful and may help you ask me more questions if it can happen.
1. **Dependencies**: According to GeoServer's official document (https://docs.geoserver.org/latest/en/user/). GeoServer is a compiled Java package. It consists of the main executable plus a number of optional plugins that are also compiled in java packages. Thus, I assume that in general GeoServer does not make system calls or call third-party services unless specifically requested. The only necessary dependence thus should be the java runtime environment.

2. **scalable installation**: The challenge mentioned the installation needs to be both **automated** and **reproducible**. Thus I assume it expects a solution that can support a very large amount of users with ease.

3. **Data source**: GeoServer is claimed not to be a database but a data processor. It can both read and write to the data source. Therefore all replicas of the GeoServer cluster must write to the same data source. In order to support this feature, I did: 1) mount contains on AWS elastic file system. 2) Installed the MySQL plugin to use a shared database. (Please note that I did not install a MySQL database on the AWS VPC because I don't have a MySQL database to test and I believe the file system is more efficient and not affected by connection/pool size issues).

4. **Exposed admin website**: A service like GeoServer usually should not expose its admin website to the public. It's purely for you to evaluate the site. Normally I will restrict the wicket admin site to internal IPs and add a https certificate to the load balancer and redirect all port 80 traffic to port 443.   


### Challenges 3
.
> Using one of the solutions found at https://rosettacode.org/wiki/Chinese_zodiac and technology of your choice, create an automated testing solution validating the Chinese Zodiac code.
###### What to submit (25 marks):
- A link to a publicly accessible source control repository containing your solution (including the provided Chinese Zodiac code), documentation, and automated testing log output.

##### MY ANSWER:

I choose to test the program in ruby. The original program is saved as [test_target_code.rb](solution_3/test_target_code.rb). The solution file is saved as [solution.rb](solution_3/solution.rb). There is also a makefile to run the test with default parameters. To run the test:

1. Make sure you have Ruby (version 2 or above) installed.
2. Download both test_target_code.rb, solution.rb and the makefile into your current directory and run:
```sh
make test
```
Alternatively, you can run the ruby command, where **test_target_code.rb** is the target ruby file's name and **200** is the number of years to test.
```sh
ruby solution.rb test_target_code.rb 200
```
The output will show if the test is successful. Please note the test can take a long time to run if set to test for a large period of years. Here is the output for 5000 years. [test_output.txt](solution_3/test_output.txt)

###### Discussion
The test uses the class definition to wrap the test code so it can be reused. The makefile makes it relatively easy to run.

Ideally, I'd like to run the test against some known data from a calendar. However, I cannot find them, so the data are generated from a known date. Another approach is to save the correct output once, so in the future, if we need to modify the code we can regenerate the data and compare it to the one we saved.

Also please note that the script does not test the years before A.D. 1. This is because the 4-digit
year is only used for years in A.D. When someone wants to calculate the result
for the year 2000 B.C. she should input -1999 (instead of -2000), thus I assume
B.C. years are out of the input domain, the earliest starting year is year 1.
