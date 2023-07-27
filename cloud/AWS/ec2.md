## EC2 
### Networking
- [ENI, ENA & EFA](https://medium.com/nerd-for-tech/aws-networking-eni-ena-efa-2db316fdbf85)

### [Placement groups](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/placement-groups.html)
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
 
### Shutdown Behavior
- Stop (default)
- Terminate(刪除 instance)
  - Enable termination protection
    - To protect against accidental termination in AWS Console or CLI

### [EC2 Instances Purchasing Options](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instance-purchasing-options.html)

- On-Demand Instances
  - Pay, by the second, for the instances that you launch.
  - short workload, predictable pricing
  - Recommended for *short-term* and *un-interrupted workloads*, where you can't predict how the application will behave
- Savings Plans
  - Reduce your Amazon EC2 costs by making a *commitment to a consistent amount of usage*, in USD per hour, for a term of 1 or 3 years.
  - long workload
  - Locked to a specific instance family & AWS region
- Reserved Instances
  - Reduce your Amazon EC2 costs by making a commitment to a consistent instance configuration, including instance *type* and *Region*, for a term of 1 or 3 years.
  - long workloads
  - Recommended for steady-state usage applications (think database)
- Spot Instances
  - Request unused EC2 instances, which can reduce your Amazon EC2 costs significantly.
  - short workloads, cheap, can lose instances (less reliable)
  - *Not suitable for critical jobs or databases*
  - Recommended for Batch jobs, Data analysis, Image processing and Workloads with a flexible start and end time etc.
- Dedicated Hosts
  - Pay for a physical host that is fully dedicated to running your instances, and bring your existing per-socket, per-core, or per-VM software licenses to reduce costs.
  - book an entire physical server, control instance placement
- Dedicated Instances
  - Pay, by the hour, for instances that run on single-tenant hardware.
  - no other customers will share your hardware
- Capacity Reservations
  - *Reserve capacity for your EC2 instances in a specific Availability Zone for any duration.*
  - No time commitment (create/cancel anytime), no billing discounts
  - Suitable for short-term, uninterrupted workloads that needs to be in a specific AZ
