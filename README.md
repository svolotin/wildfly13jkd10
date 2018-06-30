# wildfly13jkd10

Image uses JKD 10.0.1 installed on debian as a first layer. 
https://github.com/docker-library/openjdk/blob/59b305bb797b6cb60fa41e74448a68b4f0cdb813/10/jdk/Dockerfile

Next layer installs Wildfly 13, necessary drivers (postgres driver) and sets jboss as an user instead of root.

Recommended way to use this image is to build your application in to next layer using own docker image like this:

FROM dryseawind/wildfly13jkd10

ADD ./deployments /opt/jboss/wildfly-13.0.0.Final/standalone/deployments (for deploying your war)

CMD ["/opt/jboss/wildfly-13.0.0.Final/bin/standalone.sh", "-c", "standalone-ee8.xml", "-b", "0.0.0.0", "-bmanagement", "0.0.0.0" , "--debug"]
