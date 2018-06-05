MyBatis JPetStore
=================

![mybatis-jpetstore](http://mybatis.github.io/images/mybatis-logo.png)

JPetStore 6 is a full web application built on top of MyBatis 3, Spring 4 and Stripes.

Essentials
----------

* [See the docs](http://www.mybatis.org/jpetstore-6)

## Other versions that you may want to know about

- JPetstore on top of Spring, Spring MVC, MyBatis 3, and Spring Security https://github.com/making/spring-jpetstore
- JPetstore with Vaadin and Spring Boot with Java Config https://github.com/igor-baiborodine/jpetstore-6-vaadin-spring-boot
- JPetstore on MyBatis Spring Boot Starter https://github.com/kazuki43zoo/mybatis-spring-boot-jpetstore

## Run on Application Server
Running JPetStore sample under Tomcat (using the [cargo-maven2-plugin](https://codehaus-cargo.github.io/cargo/Maven2+plugin.html)).

- Clone this repository

  ```
  $ git clone https://github.com/mybatis/jpetstore-6.git
  ```

- Build war file

  ```
  $ cd jpetstore-6
  $ gradle war
  ```

## Use with Docker

The Docker file is based on the `tomcat:8.0.20-jre8` image and takes one argument to identify which intermediate war file to bring into the container post build.

    gradle war
    version=`cat gradle.properties |grep version|awk {'print $3'}`
    echo "Building version $version"

    docker build -t sgwilbur/jpetstore:$version --build-arg version=$version .

    docker run -d -p 8080:8080 sgwilbur/jpetstore:$version


## Deploy to local minikube Kubernetes

Build this and deploy container to local or remote registry, then connect

    minikube start
    eval $( minikube docker-env)
    export version=6.0.4

    kubectl config use-context minikube
    docker build -t sgwilbur/jpetstore:$version --build-arg version=$version .
    kubectl run jpetstore --image=sgwilbur/jpetstore:$version --port 8080
    kubectl expose deployment jpetstore --type=LoadBalancer
    minikube service jpetstore

To cleanup

    kubectl delete service jpetstore
    kubectl delete deployment jpetstore

    #docker rmi jpetstore -f

Or use the kubectl apply command

    kubectl apply -f deployment.yaml
    kubectl expose deployment jpetstore --type=LoadBalancer --name=jpetstore-service
    minikube service jpetstore-service

cleanup from here

    kubectl delete services jpetstore-service
    kubectl delete deployment jpetstore
