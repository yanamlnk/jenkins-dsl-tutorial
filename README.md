
# Project
⚙️ The project to practice configuring Jenkins with `.yml` file, and also to create jobs with `Job DSL`. 

- [Launch the project](#launch-the-project)
- [File Structure](#file-structure)
- [Docker files](#docker-files)
  - [Plugins](#plugins)
  - [Dockerfile](#dockerfile)
  - [Docker Compose](#docker-compose)
- [YAML file](#yaml-file)
  - [JCasC](#jcasc)
  - [Useful links](#useful-links)
  - [Elements of YAML](#elements-of-yaml)
- [Groovy file](#groovy-file)
  - [Job DSL](#job-dsl)
  - [DSL Components](#dsl-components)

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
- `Makefile` - for tests

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

## JCasC
Jenkins Configuration as Code (or JCasC) lets you configure Jenkins using a YAML file, instead of clicking through the web UI.
You can define things like:

- Users & passwords
- Roles and permissions
- System settings (welcome message, etc.)
- Predefined jobs or pipelines

## Useful links
1. [Example of yaml](https://github.com/jenkinsci/configuration-as-code-plugin/tree/7c3138e7575e425610317c76f502534cfe3804be/demos) with different configuration
2. Once the Jenkins is accessible in localhost, you can use endpoint `http://localhost:8080/manage/configuration-as-code/reference` to access all possible configurations
3. [Permissions](https://www.jenkins.io/doc/book/security/access-control/permissions/)

## Elements of YAML
- `jenkins: systemMessage:` - shows system message
- `jenkins: securityRealm:` - manages Users and Logins
  - Disables public sign-up (`allowsSignup: false`)
  - Defines four users with their names and passwords provided via environment variables. This way, passwords aren't hardcoded
  - `chocolateen`, `vaugie_g`, etc. are the login usernames
```
  securityRealm:
    local:
      allowsSignup: false
      users:
        - id: "chocolateen"
          name: "Hugo"
          password: "${USER_CHOCOLATEEN_PASSWORD}"
```
- `jenkins: authorizationStrategy:`
  - Uses a Role-Based Authorization Strategy plugin
  - Defines 4 roles: `admin`: full control, assigned to `chocolateen`, `ape`: can view and build jobs, assigned to `i_dont_know`, `gorilla`: power users, can manage jobs, assigned to `vaugie_g`, `assist`: limited access, mostly viewing, assigned to `nasso`
  - each role: has a name, a description, lists permissions and which users get that role (`entries`)
```
  authorizationStrategy: 
    roleBased:
      roles:
        global:
          - name: "admin"
            permissions:
              - "Overall/Administer"
            entries:
              - user: "chocolateen"
```              
- `jobs:` 
  - loads a Groovy file that defines Jenkins jobs using Job DSL plugin
  - creates any jobs described in it automatically

```
jobs:
  - file: /var/jenkins_home/job_dsl.groovy
```

# Groovy file
## Job DSL
Job DSL (Domain-Specific Language) is a Jenkins plugin that lets you create and manage Jenkins jobs using code — specifically, Groovy scripts.

Instead of manually creating jobs in the Jenkins UI, you can define them as code, store them in git, and automatically generate them when Jenkins starts.

📌 [Docs](https://jenkinsci.github.io/job-dsl-plugin/)

## DSL Components
- `folder('path/name'){...}` - to create a folder
- `description()` - to give a description for the element

```
folder('Tools') {
    description('Folder for miscellaneous tools.')
}
```

- `job('path/name'){...}` to declare a job
- `parameters{...}` - defines input parameters for a job
- `stringParam(name, default_value, description)` - string parameter 
- `steps{...}` - the commands or actions Jenkins will run when executing the job
- `shell('command')` - runs a shell command in the build environment
- `wrappers { ... }` - adds optional "extras" around your job
- `preBuildCleanup()` - deletes the workspace before the job starts. Prevents leftover files from previous runs

```
job('Tools/clone-repository') {
    parameters {
        stringParam('GIT_REPOSITORY_URL', '',  'Git URL of the repository to clone')
    }

    steps {
        shell('git clone "$GIT_REPOSITORY_URL"')
    }

    wrappers {
        preBuildCleanup() 
    }
}
```
> [!TIP]
> Where can you find cloned files? Jenkins creates a folder `workspace` in home directory (in this case, `/var/jenkins_home`, and then creates a folder with a name of a job. So full name in this case is `/var/jenkins_home/workspace/Tools/clone-repository/`

> [!TIP]
> In UI, you can also find copied files. In you Job, go to `Workspaces`, and there you will find all files

- `dsl {...}` - tells Jenkins this job will use Job DSL to define and create another job.
- `text(''' ''')` - allows writing raw Groovy code inside a multi-line string
- `scm {...}` - defines the source control (also called Version Control, it’s a system that tracks changes to your code over time. Most popular - git). In example below: connects to a GitHub repo, check out the main branch, and use that source code in the job.
- `github(name, branch)` - clones the GitHub repo specified by the name, checks out the specified branch
- `triggers {...}` - adds build triggers to the job.
- `scm('* * * * *')` - sets up SCM polling, which checks for changes in the repo every minute `(* * * * *)` and triggers the job if anything has changed.
```
job('Tools/SEED') {
    parameters {
        stringParam('GITHUB_NAME', '', 'GitHub repository owner/repo_name (e.g.: "EpitechIT31000/chocolatine")')
        stringParam('DISPLAY_NAME', '', 'Display name for the job')
    }

    steps {
        dsl {
            text('''
                job(DISPLAY_NAME) {
                    scm {
                        github(GITHUB_NAME, '*/main')
                    }
                    triggers {
                        scm('* * * * *')
                    }
                    steps {
                        shell('make fclean')
                        shell('make')
                        shell('make tests_run')
                        shell('make clean')
                    }
                    wrappers {
                        preBuildCleanup()
                    }
                }
            ''')
        }
    }
}
```

> [!TIP]
> P.S. For SEED job to work, you need either to approve the created dsl script as admin, or you can deactivate this verification: `Dashboard` -> `Manage Jenkins` -> `Security` -> `Enable script security for Job DSL scripts`

> [!TIP]
> P.S.S. `(* * * * *)` means `MINUTE HOUR DAY MONTH DAY_OF_WEEK`

> [!TIP]
> The syntax `*/main` in Jenkins refers to a branch pattern used by Jenkins' GitHub plugin.
> - `*`: This is a wildcard character used to match any remote reference (i.e., any branch, tag, etc.) in your repository. It tells Jenkins to look for the main branch in any remote repository (whether it's origin, or any other configured remotes).
> - `main`: This is the actual name of the branch you want Jenkins to track, in this case, the main branch.
