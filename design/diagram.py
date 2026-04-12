#!/usr/bin/env python3
"""
Architecture diagram for the EKS-based microservice with DevOps Agent integration.

Requirements:
    pip install diagrams

Usage:
    python diagram.py
"""

from diagrams import Cluster, Diagram, Edge
from diagrams.aws.compute import EKS, ECR, Lambda
from diagrams.aws.management import Cloudwatch
from diagrams.aws.network import ELB
from diagrams.aws.integration import SNS
from diagrams.aws.general import General
from diagrams.onprem.vcs import Github
from diagrams.onprem.ci import GithubActions
from diagrams.k8s.compute import Deployment, Pod
from diagrams.k8s.network import Service


graph_attr = {
    "bgcolor": "transparent",
}

with Diagram(
    "EKS Microservice with DevOps Agent",
    filename="architecture",
    outformat="png",
    show=False,
    direction="LR",
    graph_attr=graph_attr,
):
    # External: GitHub
    github = Github("GitHub\nRepository")
    gh_actions = GithubActions("GitHub\nActions")

    # AWS Cloud
    with Cluster("AWS Cloud"):
        # ECR Repository
        ecr = ECR("ECR\nContainer Registry")

        # DevOps Agent Space
        devops_agent = General("DevOps Agent\nSpace")

        # CloudWatch Monitoring & Alert Pipeline
        with Cluster("Monitoring & Alerting"):
            cloudwatch = Cloudwatch("CloudWatch\nAlarm")
            sns = SNS("SNS Topic")
            trigger_lambda = Lambda("Webhook\nTrigger")

        # VPC with EKS
        with Cluster("VPC"):
            alb = ELB("Application\nLoad Balancer")

            # EKS Cluster
            with Cluster("EKS Cluster"):
                eks = EKS("EKS\nControl Plane")

                # Kubernetes Resources
                with Cluster("Kubernetes Workloads"):
                    k8s_svc = Service("Service")
                    k8s_deploy = Deployment("Deployment")
                    pods = [
                        Pod("Pod 1"),
                        Pod("Pod 2"),
                    ]

    # CI/CD Flow
    github >> Edge(label="trigger") >> gh_actions
    gh_actions >> Edge(label="push image") >> ecr
    gh_actions >> Edge(label="deploy") >> eks

    # Container image flow
    ecr >> Edge(label="pull image", style="dashed") >> pods

    # Load balancer to service
    alb >> k8s_svc
    k8s_svc >> k8s_deploy
    k8s_deploy >> pods

    # Monitoring & DevOps Agent Alert Flow
    alb >> Edge(label="5XX metrics", style="dotted") >> cloudwatch
    cloudwatch >> Edge(label="alarm") >> sns
    sns >> Edge(label="invoke") >> trigger_lambda
    trigger_lambda >> Edge(label="webhook", color="red") >> devops_agent

    # DevOps Agent investigates
    devops_agent >> Edge(label="investigate", style="dashed", color="red") >> eks
    devops_agent >> Edge(label="analyze code", style="dashed", color="red") >> github
