# DevOps Engineer - technical pre-test
We think infrastructure is best represented as code, and provisioning of resources should be automated as much as possible.

Your task is to provision a load balancer and an Elasticsearch cluster with three nodes in it. You are free to use any provisioning tool and target of your choice. We tend to use Terraform and AWS.

* Your solution should install and configure Elasticsearch on three separate nodes. If you wish, you may use a configuration management tool
* The entry point to the cluster should be HTTP 9200/TCP
* The cluster should be adequately secured

## Context
We are testing your ability to implement modern automated infrastructure, as well as general knowledge of system administration. In your solution you should emphasize readability, maintainability and DevOps methodologies.

## Submit your solution
Create a public Github repository and push your solution in it. Commit often - we would rather see a history of trial and error than a single monolithic push. When you're finished, send us the URL to the repository.

## KR_Notes
I've used terraform to provision EC2 instances and ELB. Is still some improvement to do as such access policy for cluster instances (based on IAM for example), some variables are hardcoded and so on.
There is anoter approach as well, by using ElasticSearch from AWS. I have creted template for this schema, but haven't added it to the repo as a subject was three separate nodes.

Thanks 

Konrad  
