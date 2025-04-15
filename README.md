# Project
⚙️ The project to practice configuring Jenkins with `.yml` file, and also to create jobs with `Job DSL`. 

# Launch the project
1. Create `.env` file with the following values:
```
USER_CHOCOLATEEN_PASSWORD=
USER_VAUGIE_G_PASSWORD=
USER_I_DONT_KNOW_PASSWORD=
USER_NASSO_PASSWORD=
```
Don't put values of passwords you have set in `""`. Just write it as plain text.
2. In Terminal, launch the project:

```shell
docker-compose build
docker-compose up
```

In case of changes made to the original files: 
```shell
docker-compose down --volumes
docker-compose build
docker-compose up
```

🎉 Project accessible on http://localhost:8080

# File Structure 
- `Dockerfile`, `docker-compose.yml`, and `plugins.txt` - files used by Docker to launch the project
- `my_marvin.yml` - file to configure Jenkins (roles, users)
- `job_dsl.groovy` - file describing jobs
- 'Makefile' - for tests

# Docker files
## Plugins
`plugins.txt` contains all plugins used for this application.

## Dockerfile
In `Dockerfile` there are several steps taken:
1. Current LTS version of Jenkins is taken for a build
```
FROM jenkins/jenkins:lts
```
2. As root user, `make` and `build-essential` are installed (the tests of the project take repo with `Makefile` for a test)
```
USER root
RUN apt-get update && apt-get install -y make build-essential
```
3.  Afterwards, the plugins are copied from `plugins.txt` and installed
```
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt
```
4. Enviroment value is declared for Jenkins Configuration as Code, telling Jenkins where to find your JCasC YAML file
```
ENV CASC_JENKINS_CONFIG=/var/jenkins_home/my_marvin.yml
```
5. Return to user jenkins
```
USER jenkins
```

## Docker Compose
In `docker-compose.yml` file we 
- declare `service` named `jenkins`
- say Docker Compose to search for Dockerfile in the same folder and build it
- choose port 8080 for localhost application
```
services:
  jenkins:
    build: .
    ports:
      - "8080:8080"
```
- next, we declare environment variables (from `.env` file)
```
    environment:
      - USER_CHOCOLATEEN_PASSWORD=${USER_CHOCOLATEEN_PASSWORD}
      - USER_VAUGIE_G_PASSWORD=${USER_VAUGIE_G_PASSWORD}
      - USER_I_DONT_KNOW_PASSWORD=${USER_I_DONT_KNOW_PASSWORD}
      - USER_NASSO_PASSWORD=${USER_NASSO_PASSWORD}
```
- for volumes:
  - mount a file from local machine (`my_marvin.yml`) into the container at `/var/jenkins_home/my_marvin.yml`. `:ro` means it's read-only
  - mount another file from local machine (`job_dsl.groovy`) into Jenkins' home directory.
```
    volumes:
      - ./my_marvin.yml:/var/jenkins_home/my_marvin.yml:ro
      - ./job_dsl.groovy:/var/jenkins_home/job_dsl.groovy:ro
```

# YAML file

# Groovy file
