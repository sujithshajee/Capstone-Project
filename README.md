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

- eks-cls-config
    - addons
    - cluster.yml -  eks configuration
    - nodegroup.yml - eks nodegroup configuration

- screenshots -  screenshots for different tasks and subtasks

- scripts -  Set up ec2 instance with required tools

- upg-loadme-app -  node js app files with Dockerfile

- deployment files 
    - upg-loadme
    - redis-server
    - redis-cli



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
* Edit cluster.yaml and nodegroup.yaml and update below lines with output from terraform script
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
    Review nodegroup.yaml and ensure below lines are updated with output from terraform script
        Line 10: VPC ID
        Line 14: public subnet 1 ID
        Line 17: public subnet 2 ID
        Line 21: private subnet 1 ID
        Line 24: private subnet 2 ID
    Run command ' eksctl create nodegroup --config-file=nodegroup.yaml' and wait for the node group creation to be complete
* Create demo namespace by using command 'kubectl create ns demo'
* Navigate to deployment-files/upg-loadme folder from project root and update upg-loadme.yaml line 23 with <<repo ID>>
* Run command to deploy the application
    kubectl apply -f . 
* Run command to check status of deployment
    kubectl get all -n demo && kubectl get ingress -n demo
* Once all pods are running, run below command to check if application is up and running 
    curl $(kubectl get ingress -n demo --no-headers | awk "{print \$4}") 
```    

## Task 3: Deploy Redis server on Kubernetes
```  
* Navigate to deployment-files/redis-server folder from project root 
* Run command to deploy the redis-server
    kubectl apply -f . 
* Run command to check status of deployment
    kubectl get all -n demo 
* Navigate to deployment-files/redis-cli folder from project root 
* Run command to deploy the redis-cli
    kubectl apply -f . 
* Run command to check status of deployment
    kubectl get all -n demo 
* Run command to get redis-cli pod name  -- kubectl get pods -n demo | grep redis-cli | awk '{print$1}'   
* Run command to exec into redis-cli after replacing redis-cli pod name --  kubectl exec -it -n demo <<redis-cli-pod-name>> -- sh
* Run below commands in the pod to set the key value pair
    redis-cli -h redis -p 6379 SET foo 1
    redis-cli -h redis -p 6379 GET foo
* Run command to delete redis-server pod   -- kubectl delete pods -n demo redis-0 --force
* Run command to check if redis-server pod is back up  -- kubectl get pods -n demo
* Run command to exec into redis-cli after replacing redis-cli pod name --  kubectl exec -it -n demo <<redis-cli-pod-name>> -- sh
* Run below commands in the pod to set the key value pair
    redis-cli -h redis -p 6379 GET foo
```  

## Task 4: Test auto scaling of the application
```  
* Run command to check HPA - kubectl get hpa -n demo
* Install prometheus
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    helm repo update
    helm install prometheus prometheus-community/prometheus
* Check if all pods and services are up
    kubectl get pods && kubectl get svc 
* Port forward and access the promethues UI
    kubectl port-forward service/prometheus-server 8088:80
    Open browser and browse url http://localhost:8088
* Run below commands to initiate load test
    kubectl get ingress -n demo
    ab -n1000 -c10 'http://<INSERT-LB-DNS>/load?scale=100'
* Run below commands to monitor hpa during test
    kubectl get hpa -n demo
```  

## To destroy the setup run below commands
```  
    eksctl delete cluster eks-cluster-capstone
    terraform destroy && rm -rf terraform-key.pem
```  
