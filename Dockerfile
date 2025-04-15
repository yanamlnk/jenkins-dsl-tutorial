FROM jenkins/jenkins:lts

USER root
RUN apt-get update && apt-get install -y make build-essential

COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt

ENV CASC_JENKINS_CONFIG=/var/jenkins_home/my_marvin.yml

USER jenkins
