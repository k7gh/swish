**Creating a Kubernetes Cluster**

1. Create the cluster using eksctl
```
eksctl create cluster -f ops-001.yaml
```
Make sure node count is set 0 and add-ons are not specified

2. Delete aws-node ds
``` 
kubectl -n kube-system delete ds aws-node
```
3. Install CalicoCNI
```
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.24.6/manifests/calico-vxlan.yaml
kubectl -n kube-system set env daemonset/calico-node FELIX_AWSSRCDSTCHECK=Disable
```
5.  Scale Cluster Nodes
 ```
 eksctl scale nodegroup \
 --cluster ops-001\
 --name ops-001-ng-01\
 --nodes 2 \
 --nodes-min 2 \
 --nodes-max 3
```
6. Add the ebs-csi addon and run the following command
```
eksctl create addon -f ops-001.yaml
```
7. Adding the cluster to argocd
```
CURRENT_CONTEXT=$(kubectl config view --minify -o jsonpath='{.contexts[0].name}')
argocd cluster add ${CURRENT_CONTEXT} --name ${CLUSTER_NAME}
```

**Upgrading a Kubernetes Cluster**

Upgrading an EKS cluster is straightforward but it should be monitored very closely. Sometimes manula intervention is required to rebalance workloads.

*Pre-requisites*
1. Ensure CNI Plugins is upto date
2. Ensure cluster addons are compatible with the new version

*Upgrading*

1. Update `apiVersion.metadata.version` to the desired version and run the following command:
```
eksctl upgrade cluster --config-file <config-file> --approve
```
2. Update the `nodeGroups[*].name` and add a v2 to the end of the name. Then run the following command:
```
eksctl create nodegroup --config-file <config-file> --approve
```
3. As soon as the new node group is created, run the following command:
```
eksctl delete nodegroup --config-file <config-file> --only-missing --approve
```
4. Wait for old node group to be drained and deleted.

Post upgrade all systems should be verified including aggregation of logs and metrics.
