
# Distibution traffic Assessment-CD

This Document is 2 part :

 - Provisioning infrastructure 
 -  Continues Delivery  
### Provisioning infrastructure
In this repository we are going to automate infrastructure for Trivago assessment:
This section includes two parts 

 - provisioning vitrual machin on providers such as **KVM**, **OpenNebula**, **Proxmox**, ...
 one of the best tools for provisioning on the provider for infrastructure automation is Terraform, it supports lots of providers to do provisioning 
 - Automate Kubernetes cluster with **[kubespray](https://github.com/kubernetes-sigs/kubespray)** 
 
 ## How to setup infrastructure:
 To make a pipeline for provisioning and Kubernetes deployment, we use a bash script to handle it,  run setup.sh file in the provisioning folder.

    git clone https://github.com/Manouchehrsoleymani/k8s-assessment-cd.git
    cd k8s-assessment-cd/provision
  
based on you environment:

    cd <your_environment>
    ./setup.sh
in this assessment the environment is proxmox, so if there is another environment, you can run the script in it for that environment.
To customize the Kubernetes cluster or a number of VMs and credentials, modify the variables in *kubespray/inventory/mycluster* or variable.tf in terraform folder, if you don't change anything it provisioned 3 VMs on proxmox and setup Kubernetes cluster on 3 VMs(just for test,  it doesn't pass the best practice for production, because of Qourom and master election, and control plan nodes, ... ) 
After running kubesplay it takes a long time based on the number of your VMs and your internet connection to download the dependency and install them.

## How to setup continues deployment:
In this assessment  there is an application with tow versions, and we have to try distribute incomming traffic to these versions.
as you can see below: 
Two containers have different contents for the index.html file as listed below:
### Container - nginx-v1

    index.html
    I'm version v1!

### Container - nginx-v2

    index.html
    I'm version v2!
another constraint in the assessment is use **nginx:1.24.0** for base Image.

This project uses **helm** to deploy the application. to simplify we use **appv1** for the application's names. after continuous integration pipeline is completed and application Docker images registered into the Docker hub, it's time to deploy.

    git clone https://github.com/Manouchehrsoleymani/k8s-assessment-cd.git
    cd k8s-assessment-cd
there are 2 way to deploy aaplication.

 - helm repository management
 - argocd web UI

### deploy application with helm 
Ensure helm is installed on your system:  to [install helm.](https://helm.sh/docs/intro/install/)
Helm is the package manager for Kubernetes, and you can read detailed background information in the [CNCF Helm Project Journey report](https://www.cncf.io/cncf-helm-project-journey/) 
please use the below commands if you like to run each version of application manually

    helm install appv1 appv1/

### deploy application with argocd (with kubectl)
we use **Argo cd** for Continuous delivery in this project, so you can just run this command to tell the argo cd to track your repository and run both of your app versions.
To know more information about [Argocd](https://argo-cd.readthedocs.io/en/stable/):

    kubectl apply -f application.yaml
### deploy application with argocd (web UI)

 - open the Argocd URL
 - Click on **create app**
 - Enter the necessary information about project
 - Click on Save
After some minutes it with deploy all of your application component in the kubernetes
To detail information:
after running these commands, it create **2 pods** , **2 services** , **2 deployments** and **an** **ingress** .
please update your application images tag into the argorollout.yaml file and argocd try to discover changes into CD repository and sync the application. you can do sync manually to in web Ui.

![image](https://github.com/Manouchehrsoleymani/k8s-assessment-cd/assets/8476658/8655c515-6041-4117-9fc4-a369a3049254)
To distribute between two application versions I use canary deployment in nginx ingress controller.
### Solution:
create 2 ingress files for each of the 2 targets, **with the same hostname**, the only difference is that one of them will carry the following **ingress annotations**
  

 
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/canary: "true" #--> tell the controller to not create a new vhost
    
    nginx.ingress.kubernetes.io/canary-weight: "70" #--> route here 70% of the traffic from the existing vhost 


Make sure you’re using ingress-nginx not older than version [`0.22.0`](https://github.com/kubernetes/ingress-nginx/releases/tag/nginx-0.22.0). The initial implementation of canary feature had serious flaws that got fixed in [`0.22.0`](https://github.com/kubernetes/ingress-nginx/releases/tag/nginx-0.22.0).

-------
#### The best practices for this usecase:
There are some solution to configure and use, but some of them use more resource and you have to look at your project and choose the best solution that fit your problem. environment, knowledge, resources, maintaining, scalability, ... 
 these solutions include:
  -  [Ambassador](https://argo-rollouts.readthedocs.io/en/stable/features/traffic-management/ambassador/)
-   [APISIX](https://argo-rollouts.readthedocs.io/en/stable/features/traffic-management/apisix/)
-   [AWS ALB](https://argo-rollouts.readthedocs.io/en/stable/features/traffic-management/alb/)
-   [Istio](https://argo-rollouts.readthedocs.io/en/stable/features/traffic-management/istio/)
-   [NGINX](https://argo-rollouts.readthedocs.io/en/stable/features/traffic-management/nginx/)
-   [Plugins](https://argo-rollouts.readthedocs.io/en/stable/features/traffic-management/plugins/)
-   [SMI](https://argo-rollouts.readthedocs.io/en/stable/features/traffic-management/smi/)
-   [Traefik](https://argo-rollouts.readthedocs.io/en/stable/features/traffic-management/traefik/)

in this project we use **Nginx** ingress controller, because of 
- compatibility with GitOps tools(argocd rollout)
-  it's simple, it doesn't need more resources 
-  has a good community for it 



The structure is like this, we develop the first version of the application( **app:v1**) so we route all traffic to the first version, in some next days we will develop a new version of the application and push it into CI repository, then CI Pipeline make a new version like **app:v2** so at this time you have to make a new deployment and distribute traffic between both versions of the application,  
For GitOps and for this usecase we use **[Argocd Rollout](https://argo-rollouts.readthedocs.io/en/stable/)** with ***canary strategy*** 

You can config your policy for managing traffic and develop some measures for deciding whether rollout the new version of the application instead of the old one or not.
![image](https://github.com/Manouchehrsoleymani/k8s-assessment-cd/assets/8476658/88543bb9-05a9-4fa8-bf78-c339c38d8321)


At the end of the trigger, CD pipeline after completing CI pipeline we use [Argo CD Image Updater](https://argocd-image-updater.readthedocs.io/en/stable/)

![image](https://github.com/Manouchehrsoleymani/k8s-assessment-cd/assets/8476658/df7cae14-93d5-455d-ae16-7a8648a54948)
