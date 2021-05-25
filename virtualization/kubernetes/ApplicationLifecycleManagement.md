# Application Lifecycle Management
## Rolling updates and Rollbacks

###### Inspect the deployment and identify the current strategy
```bash
# kubectl describe deploy frontend
...
StrategyType:           RollingUpdate
...
```

- PODs are upgraded few at a time

當變換 Image 時，有時會訪問到舊的 POD
```
Hello, Application Version: v2 ; Color: green OK

Hello, Application Version: v1 ; Color: blue OK

Hello, Application Version: v1 ; Color: blue OK

Hello, Application Version: v2 ; Color: green OK

Hello, Application Version: v1 ; Color: blue OK

Hello, Application Version: v2 ; Color: green OK

Hello, Application Version: v2 ; Color: green OK

Hello, Application Version: v2 ; Color: green O
```

##### Up to how many PODs can be down for upgrade at a time
Consider the current strategy settings and number of PODs - 4

- 1


##### Change the deployment strategy to `Recreate`
Do not delete and re-create the deployment. Only update the strategy type for the existing deployment.

```yml
...
strategy:
    type: Recreate
...
```

一次刪除所有 POD，再建立新的 POD