## 參數
- variables 定義環境變數
```bash
variables:
  API_HOME: "code/backend/API_Server"
  FRONT_HOME: "code/frontend"
```
- stages 流水線順序
```bash
stages:
  - rd:docker-build-fe
  - test
  - visualize
  - rd:docker-build-be
  - rd:deploy-fe
  - rd:deploy-be

```
- stage 流水線順序的哪個階段
- before_script
```bash
before_script: # 全域
- export GRADLE_USER_HOME=`pwd`/$API_HOME/.gradle
before_script: # 某個流水線下
    - mkdir -p ~/.ssh
    - chmod 700 ~/.ssh
    - echo -e "Host *\n\tStrictHostKeyChecking no\n\n" > ~/.ssh/config
    - echo "$DEV_SSH_PRIVATE_KEY" > ~/.ssh/id_rsa
    - chmod 600 ~/.ssh/id_rsa
```
- image 使用的 Image
- services 使用的 docker service 鏡像
```bash
image: docker:latest
  services:
    - docker:dind
  variables:
    DOCKER_DRIVER: overlay2
```
- script 要執行的流程（建置 Image -> 推 Image）
- rules 觸發的條件
- artifacts 歸檔檔案，指定成功應該附加置 job 檔案或是目錄
```bash
unitTest:
  stage: test
  image: gradle:7.3.1-jdk11
  script:
    - cd $API_HOME
    - gradle test jacocoTestReport -DskipsIT=true
  artifacts:
    when: always # 無論成功失敗都執行
    reports:
      junit: ${API_HOME}/build/test-results/test/**/TEST-*.xml
    paths: 
      - ${API_HOME}/build/reports/jacoco/test/jacocoTestReport.xml
  rules:
    - if: $CI_PIPELINE_SOURCE == 'merge_request_event' # MR 事件觸發此流水線
      changes:
        - "code/backend/**/*"
  <<: *tag_runner_dev
```
- only 什麼條件下觸發
- except 	什麼條件下不觸發
```bash
only:
    refs:
      - dev # 分支
    changes: # 只訂哪個目錄下變動才執行
      - "code/frontend/**/*" 
  except: # 以下變動不需執行
    changes:
      - "code/frontend/**/*.md"
      - "code/frontend/.vscode"

```
- tags 透過標籤來決定用什麼 Runner
```bash
tags:
    - aws
    - m4-large
```
- when 什麼時候作業
- dependencies 依賴那些流水線的流程
