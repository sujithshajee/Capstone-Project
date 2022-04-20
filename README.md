## Introduction
- The Tasks and corresponding subtasks have been completed with the combination of Terraform and Anisble. 
    
## Scripts and folders
- Terraform Scripts
    ec2-instance.tf
    ecr.tf
    keypair.tf
    output.tf
    provider.tf
    s3.tf
    security-group.tf
    vars.tf
    vpc.tf

- addons

- screenshots

- scripts

- upg-loadme-app

- upg-loadme-manifests



## Task 0: Environment Setup &  Task 1: Setup EKS Cluster 
```
* Ensure you have the vars.tf file updated with required variables
* Ensure you have AWS_ACCESS_KEY and AWS_SECRET_KEY updated in the default values or be ready to provide them when you run the script

* Run below commands to setup required resources for EKS
    terraform init
    terraform plan 
    terraform apply

Note the output variables at the end of the script execution
```

```
* Login to bastion instance and configure AWS using below command
    ssh -i terraform-key.pem ubuntu@<<public ip>>
    run 'aws configure' and follow prompts to complete configuration
    Clone git repo
        git clone https://github.com/sujithshajee/Capstone-Project.git
```

```
* Navigate to eksctl-config folder (cd eksctl-config)
* Edit cluster.yaml and cluster-new-node-group.yaml and update below lines with output from terraform script
    Line 10: VPC ID
    Line 14: public subnet 1 ID
    Line 17: public subnet 2 ID
    Line 21: private subnet 1 ID
    Line 24: private subnet 2 ID

* Run command 'eksctl create cluster -f cluster.yaml' and wait for the cluster creation to be complete

* Once eksctl command is completed successfully, execute the below commands to install the addons
    * Metrics Server
        kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

    * AWS Load Balancer Controller
        helm repo add eks https://aws.github.io/eks-charts
        helm repo update
        helm install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system  --set clusterName=eks-cluster-capstone  --set serviceAccount.create=false --set serviceAccount.name=aws-load-balancer-controller 

    * Cluster-Autoscaler
        kubectl apply -f addons/cluster-autoscaler-autodiscover.yaml 
```

## Task 2: Deployment of sample application
```
* Login to ECR repository
    aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <<repo ID>>.dkr.ecr.us-east-1.amazonaws.com
    <<repo ID>> can be noted from terraform outputs
* Build upg-loadme-app
    From git repo root directory navigate to upg-loadme-app (cd upg-loadme-app)
    docker build -t app .
    docker tag app:latest <<repo ID>>.dkr.ecr.us-east-1.amazonaws.com/app:latest
    docker push <<repo ID>>.dkr.ecr.us-east-1.amazonaws.com/app:latest
* Add Create a new nodegroup using eksctl
    Navigate to eksctl-config folder (cd eksctl-config)
    Review cluster-new-node-group.yaml and ensure below lines are updated with output from terraform script
        Line 10: VPC ID
        Line 14: public subnet 1 ID
        Line 17: public subnet 2 ID
        Line 21: private subnet 1 ID
        Line 24: private subnet 2 ID
    Run command 'eksctl create cluster -f cluster-new-node-group.yaml' and wait for the node group creation to be complete
* Create demo namespace by using command 'kubectl create ns demo'
```    


## To destroy the setup run below commands
```  
    eksctl delete cluster eks-cluster-capstone
    terraform destroy && rm -rf terraform-key.pem
```  
