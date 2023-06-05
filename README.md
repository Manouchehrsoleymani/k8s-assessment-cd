
# Provisioning infrastructure and Continues Delivery  
In this repository we are going to automate infrastructure for Trivago assessment:
This section includes two parts 

 - provisioning vitrual machin on providers such as **KVM**, **OpenNebula**, **Proxmox**, ...
 one of the best tools for provisioning on the provider for infrastructure automation is Terraform, it supports lots of providers to do provisioning 
 - Automate Kubernetes cluster with **kubespray** 
 one of the best tools for configuration management is Ansible. and because some official ansible playbooks for setting up Kubernetes is kubespray, because it is regularly developed for each version of Kubernetes and stable for implementing Kubernetes cluster.
 kubespray Can be deployed on  **[AWS](https://github.com/kubernetes-sigs/kubespray/blob/master/docs/aws.md), GCE,  [Azure](https://github.com/kubernetes-sigs/kubespray/blob/master/docs/azure.md),  [OpenStack](https://github.com/kubernetes-sigs/kubespray/blob/master/docs/openstack.md),  [vSphere](https://github.com/kubernetes-sigs/kubespray/blob/master/docs/vsphere.md),  [Equinix Metal](https://github.com/kubernetes-sigs/kubespray/blob/master/docs/equinix-metal.md)  (bare metal), Oracle Cloud Infrastructure (Experimental), or Baremetal**
 

 To make a pipeline for provisioning and Kubernetes deployment, we use a bash script to handle it, so to conclude you just need to run setup.sh file in the provisioning folder.
 ## How to setup infrastructure:
 

    git clone https://github.com/Manouchehrsoleymani/k8s-assessment-cd.git
    cd k8s-assessment-cd/provision
  
based on you environment:

    cd <your_environment>
    ./setup.sh
in this assessment the environment is proxmox, so if there is another environment, you can run the script in it for that environment.
To customize the Kubernetes cluster or a number of VMs and credentials, modify the variables in kubespray/inventory/mycluster or variable.tf in terraform folder, if you don't change anything it provisioned 3 VMs on proxmox and setup Kubernetes cluster on 3 VMs(just for test,  it doesn't pass the best practice for production, because of Qourom and master election, and control plan nodes, ... ) 
It takes a long time based on the number of your VMs and your internet connection to download the dependency and install them.

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
another constraint is use **nginx:1.24.0** for base Image.

This project uses **helm** to deploy each version of the application. to simplify we use **appv1** and **appv2** for the applications' names. and there are 2 folders with these names too.
after continuous integration pipeline and registring Docker images into the Docker hub. it's so easy to deploy.

    git clone https://github.com/Manouchehrsoleymani/k8s-assessment-cd.git
    cd k8s-assessment-cd
Ensure helm is installed on your system:  to [install helm.](https://helm.sh/docs/intro/install/)
Helm is the package manager for Kubernetes, and you can read detailed background information in the [CNCF Helm Project Journey report](https://www.cncf.io/cncf-helm-project-journey/) 
please use the below commands if you like to run each version of application manually

    helm install appv1 appv1/
    helm install appv2 appv2/
I use **Argo cd** for Continuous delivery in this project, so you can just run this command to tell the argo cd to track your repository and run both of your app versions.
To know more information about [Argocd](https://argo-cd.readthedocs.io/en/stable/):

    kubectl apply -f application.yaml


To detail information:
after running these commands, it create **2 pods** , **a service** , **a deployment** and **an** **ingress** for each version of app 

![image](https://github.com/Manouchehrsoleymani/k8s-assessment-cd/assets/8476658/850b27ab-3491-4bb9-81ff-55e3d331e8b3)

To distribute between two application versions I use canary deployment in nginx ingress controller.
### Solution:
create 2 ingress files for each of the 2 targets, **with the same hostname**, the only difference is that one of them will carry the following **ingress annotations**
  

    nginx.ingress.kubernetes.io/canary: "true" #--> tell the controller to not create a new vhost
    
    nginx.ingress.kubernetes.io/canary-weight: "70" #--> route here 70% of the traffic from the existing vhost 


Make sure you’re using ingress-nginx not older than version [`0.22.0`](https://github.com/kubernetes/ingress-nginx/releases/tag/nginx-0.22.0). The initial implementation of canary feature had serious flaws that got fixed in [`0.22.0`](https://github.com/kubernetes/ingress-nginx/releases/tag/nginx-0.22.0).
## How to contribute
I tried to explain all the information about this project here and it's an open-source and free project for fun.
if you are ready to make a product,  just fork the project and start developing it.
we can contribute as a team and do big jobs. 
