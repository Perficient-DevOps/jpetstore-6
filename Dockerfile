FROM tomcat:8.0.20-jre8

ARG version=6.0.x

COPY /build/libs/jpetstore-$version.war /usr/local/tomcat/webapps/jpetstore.war
