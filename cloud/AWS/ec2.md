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
