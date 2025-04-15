FROM jenkins/jenkins:lts

USER root
RUN apt-get update && apt-get install -y make build-essential

COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt

COPY my_marvin.yml /var/jenkins_home/my_marvin.yml
COPY job_dsl.groovy /var/jenkins_home/job_dsl.groovy

ENV CASC_JENKINS_CONFIG=/var/jenkins_home/my_marvin.yml
