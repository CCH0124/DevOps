# gitlab CI/CD to EC2

```bash=
ssh-keygen -m PEM -t rsa -b 4096 -C "some info"
```
將 `.pub` 檔附加至 `.ssh/authorized_keys` 檔案中

再 `setting -> CI/CD -> Variables` 設置 `SSH private key`、和 `IP`，這樣本地端可使用 Key 方式登入 AWS 上 EC2。

CI/CD yml 檔如下

```yaml=
variables:
  API_HOME: "code/backend/API_Server"
  FRONT_HOME: "code/frontend"
  PROJECT_NAME: "XXX"
  WISTRON_DOCKER_REGISTRY: URL
  DOCKER_WEB_SERVER_BE: "be"
  DOCKER_WEB_SERVER_FE: "fe"
  
.only_fe_rd_template: &only_fe_rd
  only:
    refs:
      - deploy
    changes:
      - "code/frontend/**/*"
  except:
    changes:
      - "code/frontend/**/*.md"
      - "code/frontend/.vscode"

.only_be_rd_template: &only_be_rd
  only:
    refs:
      - deploy
    changes:
      - "code/backend/**/*"

.docker_build_template: &docker_build_rd
  image: docker:latest
  services:
    - docker:dind
  variables:
    DOCKER_DRIVER: overlay2

.docker_deploy_template: &docker_deploy_rd
  image: kroniak/ssh-client
  services:
    - docker:dind
  before_script:
    - mkdir -p ~/.ssh
    - chmod 700 ~/.ssh
    - echo -e "Host *\n\tStrictHostKeyChecking no\n\n" > ~/.ssh/config
    - echo "$DEV_SSH_PRIVATE_KEY" > ~/.ssh/id_rsa
    - chmod 600 ~/.ssh/id_rsa  
  
stages:
# rd site stages 
  - rd:docker-build-fe
  - rd:docker-build-be
  - rd:deploy-fe
  - rd:deploy-be

before_script:
- export GRADLE_USER_HOME=`pwd`/$API_HOME/.gradle

# Docker build
front-end-docker-build-rd:
  stage: rd:docker-build-fe
  <<: *docker_build_rd
  script:
    - echo "build fe"
  <<: *only_fe_rd
  tags:
    - m4-large

back-end-docker-build-rd:
  stage: rd:docker-build-be
  <<: *docker_build_rd
  script:
    - echo "build be"
  <<: *only_be_rd
  tags:
    - m4-large
 
## Deploy
ap1-deploy-fe-rd:
  stage: rd:deploy-fe
  dependencies:
    - front-end-docker-build-rd
  <<: *docker_deploy_rd
  script:
    - touch fe.md
  tags:
    - m4-large
  <<: *only_fe_rd

ap1-deploy-be-rd:
  stage: rd:deploy-be
  <<: *docker_deploy_rd
  dependencies:
    - back-end-docker-build-rd
  script:
    - ssh $DEV_AWS_USER@$DEV_SERVER_IP "docker login -u $WISTRON_REPOSITORY_ACCOUNT -p $WISTRON_REPOSITORY_PASSWORD $WISTRON_DOCKER_REGISTRY"
    - ssh $DEV_AWS_USER@$DEV_SERVER_IP "touch be.md"
  <<: *only_be_rd
  tags:
    - m4-large
  # when: manual
```


## Create Runner

```bash=
~$ mkdir -p gitlab-runner/config
~$ docker run -d --name aiot-runner --restart always -v $(pwd)/gitlab-runner/config:/etc/gitlab-runner -v /var/run/docker.sock:/var/run/docker.sock gitlab/gitlab-runner:latest
~$ docker run --rm -it -v $(pwd)/gitlab-runner/config:/etc/gitlab-runner gitlab/gitlab-runner register
```

- [1986 issues - Docker 與 runner 問題](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/1986)
- [架設 runner](https://sean22492249.medium.com/gitlab-ci-cd-%E4%BB%8B%E7%B4%B9%E8%88%87-runner-%E7%9A%84%E6%9E%B6%E8%A8%AD-afdbde9f22aa)