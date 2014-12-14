FROM ubuntu:12.10
MAINTAINER dakuton

## Set locale
RUN locale-gen en_US.UTF-8
RUN update-locale LANG=en_US.UTF-8
ENV LC_ALL C
ENV LC_ALL en_US.UTF-8

## Set install mode
ENV DEBIAN_FRONTEND noninteractive

## Add Ubuntu mirror(JP)
RUN echo "deb http://jp.archive.ubuntu.com/ubuntu/ saucy main restricted\n\
deb-src http://jp.archive.ubuntu.com/ubuntu/ saucy main restricted\n\
deb http://jp.archive.ubuntu.com/ubuntu/ saucy-updates main restricted\n\
deb-src http://jp.archive.ubuntu.com/ubuntu/ saucy-updates main restricted\n\
deb http://jp.archive.ubuntu.com/ubuntu/ saucy universe\n\
deb-src http://jp.archive.ubuntu.com/ubuntu/ saucy universe\n\
deb http://jp.archive.ubuntu.com/ubuntu/ saucy-updates universe\n\
deb-src http://jp.archive.ubuntu.com/ubuntu/ saucy-updates universe\n\
deb http://jp.archive.ubuntu.com/ubuntu/ saucy multiverse\n\
deb-src http://jp.archive.ubuntu.com/ubuntu/ saucy multiverse\n\
deb http://jp.archive.ubuntu.com/ubuntu/ saucy-updates multiverse\n\
deb-src http://jp.archive.ubuntu.com/ubuntu/ saucy-updates multiverse\n\
deb http://jp.archive.ubuntu.com/ubuntu/ saucy-backports main restricted universe multiverse\n\
deb-src http://jp.archive.ubuntu.com/ubuntu/ saucy-backports main restricted universe multiverse\n\
deb http://security.ubuntu.com/ubuntu saucy-security main restricted\n\
deb-src http://security.ubuntu.com/ubuntu saucy-security main restricted\n\
deb http://security.ubuntu.com/ubuntu saucy-security universe\n\
deb-src http://security.ubuntu.com/ubuntu saucy-security universe\n\
deb http://security.ubuntu.com/ubuntu saucy-security multiverse\n\
deb-src http://security.ubuntu.com/ubuntu saucy-security multiverse\n"> /etc/apt/sources.list

## Update apt-get sources
RUN sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list
RUN apt-get update
RUN apt-get -y upgrade

## Prepare Tools
RUN apt-get install -y curl git htop man wget unzip aptitude dpkg debconf
## Required python3 < 3.4
RUN apt-get remove -y python3
RUN apt-get install -y zlib1g-dev libssl-dev libreadline-dev libsqlite3-dev tk-dev libbz2-dev libgdbm-dev tcl-dev
RUN apt-get install -y python3.3 python3.3-dev
RUN apt-get install -y python3-gi python3-dbus python3-apt unattended-upgrades python3-software-properties
## Ubuntu <= 12.04
#RUN apt-get install  python-software-properties
## Ubuntu >= 12.10
RUN apt-get install -y software-properties-common

## Java
## Add Java repository
RUN add-apt-repository -y ppa:webupd8team/java
RUN apt-get -y update
## Accept Oracle license
RUN echo "oracle-java7-installer shared/accepted-oracle-license-v1-1 boolean true" | debconf-set-selections
## Install Java
RUN apt-get install -y oracle-java7-installer
## Set Environment
ENV JAVA_HOME /usr/lib/jvm/java-7-oracle

## Android
## Install Android SDK
RUN cd /opt && wget -q http://dl.google.com/android/android-sdk_r24.0.1-linux.tgz
RUN cd /opt && tar xzf android-sdk_r24.0.1-linux.tgz
RUN cd /opt && rm -f android-sdk_r24.0.1-linux.tgz
## Install AAPT dependencies
RUN apt-get install -y lib32stdc++6 lib32z1
## Set environment
ENV ANDROID_HOME /opt/android-sdk-linux
ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools
## Update Android SDK
RUN echo y | android update sdk --filter platform-tools,build-tools-21.1.2,android-19,extra-android-support --no-ui --force

## Gradle
## Install Gradle
RUN cd /opt && wget -q http://services.gradle.org/distributions/gradle-2.1-all.zip
RUN cd /opt && unzip -o gradle-2.1-all.zip
RUN cd /opt && rm -f gradle-2.1-all.zip
## Set environment
ENV GRADLE_HOME /opt/gradle-2.1
ENV PATH ${PATH}:${GRADLE_HOME}/bin

## Set timezone(JP)
RUN echo "Asia/Tokyo" > /etc/timezone
RUN /usr/sbin/dpkg-reconfigure -f noninteractive tzdata

## Cleaning
RUN apt-get clean
