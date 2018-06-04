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
