#!/bin/bash

#  ____  ____
# |  _ \/ ___|
# | |_) \___ \
# |  _ < ___) |
# |_| \_\____/
# 
#----Change Values Below accoding to your aws account----
#AWS_accountID
acid=11233445343
#regionCode
region=ap-south-1
#ClusterName_Below
clustername=eks-cluseter

#---------Change Above-------------

#curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.4.7/docs/install/iam_policy_us-gov.json

curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.4.7/docs/install/iam_policy.json

aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam_policy.json

echo "Press Enter to Proceed..."

oidc_id=$(aws eks describe-cluster --name $clustername --query "cluster.identity.oidc.issuer" --output text | cut -d '/' -f 5)

oid=$(aws iam list-open-id-connect-providers | grep "$oidc_id" | cut -d "/" -f4 | sed 's/"//')

cat >load-balancer-role-trust-policy.json <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::$acid:oidc-provider/oidc.eks.$region.amazonaws.com/id/$oid"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "oidc.eks.$region.amazonaws.com/id/$oid:aud": "sts.amazonaws.com",
                    "oidc.eks.$region.amazonaws.com/id/$oid:sub": "system:serviceaccount:kube-system:aws-load-balancer-controller"
                }
            }
        }
    ]
}
EOF

echo "Press Enter to Proceed..."
aws iam create-role \
    --role-name AmazonEKSLoadBalancerControllerRole \
    --assume-role-policy-document file://"load-balancer-role-trust-policy.json"

aws iam attach-role-policy \
    --policy-arn arn:aws:iam::$acid:policy/AWSLoadBalancerControllerIAMPolicy \
    --role-name AmazonEKSLoadBalancerControllerRole

cat >aws-load-balancer-controller-service-account.yaml <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    app.kubernetes.io/component: controller
    app.kubernetes.io/name: aws-load-balancer-controller
  name: aws-load-balancer-controller
  namespace: kube-system
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::$acid:role/AmazonEKSLoadBalancerControllerRole
EOF

echo "Press Enter to Proceed..."
kubectl apply -f aws-load-balancer-controller-service-account.yaml

echo "Press Enter to Proceed..."
kubectl apply \
    --validate=false \
    -f https://github.com/jetstack/cert-manager/releases/download/v1.5.4/cert-manager.yaml

echo "Press Enter to Proceed..."
curl -Lo v2_4_7_full.yaml https://github.com/kubernetes-sigs/aws-load-balancer-controller/releases/download/v2.4.7/v2_4_7_full.yaml

sed -i.bak -e '561,569d' ./v2_4_7_full.yaml

sed -i.bak -e "s|your-cluster-name|$clustername|" ./v2_4_7_full.yaml

kubectl apply -f v2_4_7_full.yaml

echo "Press Enter to Proceed..."
curl -Lo v2_4_7_ingclass.yaml https://github.com/kubernetes-sigs/aws-load-balancer-controller/releases/download/v2.4.7/v2_4_7_ingclass.yaml

kubectl apply -f v2_4_7_ingclass.yaml

kubectl get deployment -n kube-system aws-load-balancer-controller
