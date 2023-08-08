## Networking
- [ENI, ENA & EFA](https://medium.com/nerd-for-tech/aws-networking-eni-ena-efa-2db316fdbf85)

## [Placement groups](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/placement-groups.html)
- Cluster
  - HPC
  - low-latency group in a *single Availability Zone*
  - high network throughput
  - If the rack fails, all instances fails at the same time
  - same hardware
  - ![](https://docs.aws.amazon.com/images/AWSEC2/latest/UserGuide/images/placement-group-cluster.png)
- Partition
  - across multiple AZs in the same region
  - Up to 100s of EC2 instances
  - A partition failure can affect many EC2 but won’t affect other partitions
  - used by large distributed and replicated workloads, such as Hadoop, Cassandra, and Kafka.
  - ![](https://docs.aws.amazon.com/images/AWSEC2/latest/UserGuide/images/placement-group-partition.png)
- Spread
  - different hardware
  - *across Availability Zone*
  - Reduced risk
  - *max 7 instances per group per AZ*
  - ![](https://docs.aws.amazon.com/images/AWSEC2/latest/UserGuide/images/placement-group-spread.png)
 
## Shutdown Behavior
- Stop (default)
- Terminate(刪除 instance)
  - Enable termination protection
    - To protect against accidental termination in AWS Console or CLI

## [EC2 Instances Purchasing Options](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instance-purchasing-options.html)

- [On-Demand Instances](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-capacity-reservations.html)
  - Pay, by the second, for the instances that you launch.
  - short workload, predictable pricing
  - Recommended for *short-term* and *un-interrupted workloads*, where you can't predict how the application will behave
- Savings Plans
  - Reduce your Amazon EC2 costs by making a *commitment to a consistent amount of usage*, in USD per hour, for a term of 1 or 3 years.
  - long workload
  - Locked to a specific instance family & AWS region
- [Reserved Instances](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-reserved-instances.html)
  - Reduce your Amazon EC2 costs by making a commitment to a consistent instance configuration, including instance *type* and *Region*, for a term of 1 or 3 years.
  - long workloads
  - Recommended for steady-state usage applications (think database)
- [Spot Instances](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-spot-instances.html)
  - Request unused EC2 instances, which can reduce your Amazon EC2 costs significantly.
  - short workloads, cheap, can lose instances (less reliable)
  - *Not suitable for critical jobs or databases*
  - Recommended for Batch jobs, Data analysis, Image processing and Workloads with a flexible start and end time etc.
- [Dedicated Hosts](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/dedicated-hosts-overview.html)
  - Pay for a physical host that is fully dedicated to running your instances, and bring your existing per-socket, per-core, or per-VM software licenses to reduce costs.
  - book an entire physical server, control instance placement
- [Dedicated Instances](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/dedicated-instance.html)
  - Pay, by the hour, for instances that run on single-tenant hardware.
  - no other customers will share your hardware
- Capacity Reservations
  - *Reserve capacity for your EC2 instances in a specific Availability Zone for any duration.*
  - No time commitment (create/cancel anytime), no billing discounts
  - Suitable for short-term, uninterrupted workloads that needs to be in a specific AZ
 

## [Spot Instances](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-spot-instances.html)

A Spot Instance is an instance that uses spare EC2 capacity that is available for less than the On-Demand price. Because Spot Instances enable you to request unused EC2 instances at steep discounts, *you can lower your Amazon EC2 costs significantly*. *The hourly price for a Spot Instance is called a Spot price*. The Spot price of each instance type in each Availability Zone is set by Amazon EC2, and is adjusted gradually based on the long-term supply of and demand for Spot Instances. Your Spot Instance runs whenever capacity is available.

- *Used for batch jobs, data analysis, or workloads that are resilient to failures.*

**Concepts**
- Spot capacity pool
  - 一組具有相同執行個體類型 (例如 m5.large) 和可用區域的未使用 EC2 執行個體。
- Spot price
  - Spot 執行個體目前的每小時價格。
- Spot Instance request
  - 請求 Spot 執行個體。當容量可用時，Amazon EC2 會履行您的請求。Spot 執行個體請求為一次性或持久性。與請求相關聯的 Spot 執行個體中斷之後，Amazon EC2 會自動重新提交持續的 Spot 執行個體請求。
  - 定義 *max spot price*，如果 *current spot price < max* 並獲取一個執行個體
  - 每小時  spot 價格根據報價和容量而變化
  - 當前 spot 價格 > 最高價格，可以選擇停止或終止執行個體，並有 2 分鐘的寬限期
- EC2 instance rebalance recommendation
  - Amazon EC2 發出執行個體重新平衡建議訊號，以通知您 Spot 執行個體的中斷風險升高。此訊號讓您有機會在現有或新的 Spot 執行個體上主動重新平衡工作負載，而無需等待兩分鐘的 Spot 執行個體中斷通知。
- Spot Instance interruption
  - 當 Amazon EC2 需要取回容量，Amazon EC2 會終止、停止 Spot 執行個體或將其休眠。Amazon EC2 會提供 Spot 執行個體中斷通知，在執行個體中斷前會向執行個體發出兩分鐘的警告。
 
- [Key differences between Spot Instances and On-Demand Instances](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-spot-instances.html#Key%20differences%20between%20Spot%20Instances%20and%20On-Demand%20Instances)

**[Terminate Spot Instances](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/spot-requests.html)**

![](https://docs.aws.amazon.com/images/AWSEC2/latest/UserGuide/images/spot_lifecycle.png)


- open
  - 請求正等待完成
- active
  - 請求已完成，並具有關聯的 Spot 執行個體
- failed
  - 請求具有一個或多個無效的參數
- closed
  - Spot 執行個體已中斷或終止
- disabled
  - 已停止 Spot 執行個體
- cancelled
  - 已取消請求，或請求已過期

![](https://docs.aws.amazon.com/images/AWSEC2/latest/UserGuide/images/spot_request_states.png)

- You can only cancel Spot Instance requests that are open, active, or disabled.
- Cancelling a Spot Request does not terminate instances
- You must first cancel a Spot Request, and then terminate the associated Spot Instances

## [Spot Fleets](https://docs.aws.amazon.com/zh_tw/AWSEC2/latest/UserGuide/work-with-spot-fleets.html)

- Spot Fleets allow us to automatically request Spot Instances with the lowest price

## [Elastic IP]()
- When you stop and then start an EC2 instance, it changes its public IP
- With an Elastic IP address, you can mask the failure of an instance or software by rapidly remapping the address to another instance in your account.
- You don’t pay for the Elastic IP if it’s attached to a server
- You pay for the Elastic IP if it’s not attached to a server
- You can only have 5 Elastic IP in your account (you can ask AWS to increase that).

How you can avoid using Elastic IP:
- Always think if other alternatives are available to you
- You could use a random public IP and register a DNS name to it
- Or use a Load Balancer with a static hostname

## [CloudWatch Metrics for EC2](https://docs.aws.amazon.com/zh_tw/AmazonCloudWatch/latest/logs/WhatIsCloudWatchLogs.html)
- AWS Provided metrics 
  - Basic Monitoring (default): metrics are collected at a 5 minute internal
  - Detailed Monitoring (paid): metrics are collected at a 1 minute interval
  - Includes CPU, Network, Disk and Status Check Metrics
- Custom metric (self to push)
  -  RAM, application level metrics
  -  EC2 實例 role 中的 IAM 權限正確
### EC2 included metrics
- CPU: CPU Utilization + Credit Usage / Balance
- Network: Network In / Out
- Status Check:
  - Instance status = check the EC2 VM
  - System status = check the underlying hardware
- Disk: Read / Write for Ops / Bytes (only for instance store)
- *RAM is NOT included in the AWS EC2 metrics*
 
### [Unified CloudWatch Agent](https://docs.aws.amazon.com/zh_tw/AmazonCloudWatch/latest/monitoring/Install-CloudWatch-Agent.html)
- For virtual servers(EC2 instances, on-premises servers...)
- 蒐集而外系統層級的度量像是 RAM、processes、disk space etc.
- 蒐集 Log 到 CloudWatch Logs，需使用 CloudWatch Agent
- 使用 SSM Parameter Store 集中配置
- IAM 權限正確設置
- 由 CloudWatch 代理程式收集指標的預設命名空間是 `CWAgent`，不過您可以在設定代理程式時指定不同的命名空間

### [Unified CloudWatch Agent – procstat Plugin](https://docs.aws.amazon.com/zh_tw/AmazonCloudWatch/latest/monitoring/CloudWatch-Agent-procstat-process-metrics.html)
## Status Checks
- 自動檢查識別硬體和軟體問題
- **System Status Checks**
  - 監控 AWS 系統問題(軟體/硬體/系統電力)
  - 
- **Instance Status Checks**
