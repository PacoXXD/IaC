locals {
  env   = "paco"
  v_tag = "v1007"

  eks_b_name                           = format("%s-paco-core-b-%s", local.env, local.v_tag)
  eks_b_vpc_id                         = "vpc-0e69ca109fd8fd88b"
  eks_b_ingest_iam_role_name           = format("%s-ingest-node-%s-role", local.env, local.v_tag)
  eks_b_transcoder_iam_role_name       = format("%s-transcoder-node-%s-role", local.env, local.v_tag)
  eks_b_ingest_security_group_name     = format("%s-ingest-node-%s-sg", local.env, local.v_tag)
  eks_b_transcoder_security_group_name = format("%s-transcoder-node-%s-sg", local.env, local.v_tag)
  eks_b_keyname                        = format("%s-paco-core-b-%s", local.env, local.v_tag)
  eks_b_instance_type                  = "c5n.large"
  eks_b_default_ami                    = "ami-004e9394014c96cfc"
  eks_b_node_subnets = [
    "subnet-0feef7a097cd5c205",
    "subnet-0cbcba12e7e2f0b52",
    "subnet-0610011f42066577b"
  ]
  eks_b_policy_names = toset([for group in module.prd-paco-eks.eks_managed_node_groups : group.iam_role_name])


  tags = {
    Terraform : true,
    Environment : local.env,
    Version : local.v_tag,
  }

}

data "aws_eks_cluster" "cluster" {
  name = module.prd-paco-eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.prd-paco-eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}


module "prd-paco-eks" {
  source = "terraform-aws-modules/eks/aws"

  cluster_name                    = local.eks_b_name
  cluster_version                 = "1.23"
  subnet_ids                      = local.eks_b_node_subnets
  vpc_id                          = local.eks_b_vpc_id
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  # create_aws_auth_configmap = true
  manage_aws_auth_configmap = true

  cluster_addons = {
    coredns = {
      addon_version     = "v1.8.7-eksbuild.3"
      resolve_conflicts = "OVERWRITE"
      tags = {
        "eks_addon" = "prd-coredns"
      }
    }
    kube-proxy = {
      addon_version     = "v1.23.8-eksbuild.2"
      resolve_conflicts = "OVERWRITE"
      tags = {
        "eks_addon" = "prd-kube-proxy"
      }
    }
    vpc-cni = {
      addon_version     = "v1.11.4-eksbuild.1"
      resolve_conflicts = "OVERWRITE"
      tags = {
        "eks_addon" = "prd-vpc-cni"
      }
    }
    aws-ebs-csi-driver = {
      addon_version     = "v1.11.4-eksbuild.1"
      resolve_conflicts = "NONE"
      tags = {
        "eks_addon" = "prd-aws-ebs-csi-driver"
      }
    }
  }


  cluster_security_group_additional_rules = {
    egress_nodes_ephemeral_ports_tcp = {
      description                = "To node 1025-65535"
      protocol                   = "tcp"
      from_port                  = 1025
      to_port                    = 65535
      type                       = "egress"
      source_node_security_group = true
    }
  }

  # Extend node-to-node security group rules
  node_security_group_additional_rules = {
    ingress_allow_access_from_control_plane = {
      type                          = "ingress"
      protocol                      = "tcp"
      from_port                     = 9443
      to_port                       = 9443
      source_cluster_security_group = true
      description                   = "Allow access from control plane to webhook port of AWS load balancer controller"
    }

    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    egress_all = {
      description      = "Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
    # #For EFS Access
    ingress = {
      from_port = 2049
      to_port   = 2049
      protocol  = "tcp"
      type      = "ingress"

      cidr_blocks = [
        "10.0.0.0/8",
      ]
      description = "port for EFS"
    }
  }

  aws_auth_users = [
    {
      userarn  = "arn:aws:iam::XXX:user/Paco"
      username = "Paco"
      groups   = ["system:masters"]
    },
    {
      userarn  = "arn:aws:iam::XXX:user/Deploy"
      username = "deploy"
      groups   = ["system:masters"]
    }
  ]

  eks_managed_node_group_defaults = {
    use_name_prefix = true

    subnet_ids                 = local.eks_b_node_subnets
    key_name                   = local.eks_b_keyname
    enable_bootstrap_user_data = true

    pre_bootstrap_user_data = <<-EOT
      export CONTAINER_RUNTIME="containerd"
      export USE_MAX_PODS=false
      EOT

    post_bootstrap_user_data = <<-EOT
      echo "you are free little kubelet!"
      EOT

    force_update_version = false
    ebs_optimized        = true
    enable_monitoring    = true

    create_iam_role          = true
    iam_role_use_name_prefix = false
    iam_role_description     = "EKS managed node group role"
    iam_role_tags = merge(local.tags, {
      Purpose = "Protector of the kubelet"
    })
    iam_role_additional_policies = [
      "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
    ]

    create_security_group          = true
    security_group_use_name_prefix = false
    security_group_description     = "EKS managed node group security group"
    security_group_rules = {
      phoneOut = {
        description = "Hello CloudFlare"
        protocol    = "udp"
        from_port   = 53
        to_port     = 53
        type        = "egress"
        cidr_blocks = ["1.1.1.1/32"]
      }
      phoneHome = {
        description                   = "Hello cluster"
        protocol                      = "udp"
        from_port                     = 53
        to_port                       = 53
        type                          = "egress"
        source_cluster_security_group = true # bit of reflection lookup
      }
    }
    security_group_tags = merge(local.tags, {
      Purpose = "Protector of the kubelet"
    })

    block_device_mappings = {
      xvda = {
        device_name = "/dev/xvda"
        ebs = {
          volume_size           = 64
          volume_type           = "gp3"
          iops                  = 3000
          throughput            = 125
          delete_on_termination = false
        }
      }
    }


    tags = merge(local.tags, {
      CLUSTER_ID                                      = local.eks_b_name
      "k8s.io/cluster-autoscaler/enabled"             = true
      "k8s.io/cluster-autoscaler/${local.eks_b_name}" = true
    })
  }
  eks_managed_node_groups = {

    # ingest
    ingest = {
      name                 = format("%s-ingest-eks-mng-%s", local.env, local.v_tag)
      min_size             = 1
      max_size             = 2
      desired_size         = 1
      instance_types       = [local.eks_b_instance_type]
      ami_id               = local.eks_b_default_ami
      bootstrap_extra_args = "--container-runtime containerd --kubelet-extra-args '--node-labels=node.kubernetes.io/lifecycle=normal,node.lino.network/ingest=true'"

      iam_role_name = local.eks_b_ingest_iam_role_name

      security_group_name = local.eks_b_ingest_security_group_name



    },

    # transcoder
    transcoder = {
      name = format("%s-transcoder-eks-mng-%s", local.env, local.v_tag)

      min_size       = 1
      max_size       = 4
      desired_size   = 1
      instance_types = [local.eks_b_instance_type]
      ami_id         = local.eks_b_default_ami

      bootstrap_extra_args = "--container-runtime containerd --kubelet-extra-args '--node-labels=node.kubernetes.io/lifecycle=normal,node.lino.network/transcoder=true'"

      iam_role_name = local.eks_b_transcoder_iam_role_name

      security_group_name = local.eks_b_transcoder_security_group_name

    }
  }
}
#   {
#     name                  = "ingest"
#     asg_desired_capacity  = 0
#     asg_max_size          = 10
#     asg_min_size          = 0
#     instance_type         = "c5n.xlarge"
#     root_volume_size      = "16"
#     root_volume_type      = "gp2"
#     root_iops             = "0"
#     key_name              = format("%s-paco-worker", local.env)
#     public_ip             = false
#     autoscaling_enabled   = false
#     protect_from_scale_in = false
#     kubelet_extra_args    = "--node-labels=node.kubernetes.io/lifecycle=normal,node.lino.network/ingest=true"
#     subnets               = [
#       local.eks_b_node_subnets[ 0 ] ]
#     tags                  = [
#       {
#         key                 = "k8s.io/cluster-autoscaler/enabled"
#         propagate_at_launch = "false"
#         value               = "true"
#       },
#       {
#         key                 = "k8s.io/cluster-autoscaler/${local.eks_b_name}"
#         propagate_at_launch = "false"
#         value               = "true"
#       }
#     ]
#   },
#   {
#     name                  = "transcoder"
#     asg_desired_capacity  = 0
#     asg_max_size          = 0
#     asg_min_size          = 0
#     instance_type         = "c5.xlarge"
#     root_volume_size      = "64"
#     root_volume_type      = "gp2"
#     root_iops             = "0"
#     key_name              = format("%s-paco-worker", local.env)
#     public_ip             = false
#     autoscaling_enabled   = false
#     protect_from_scale_in = false
#     kubelet_extra_args    = "--node-labels=node.kubernetes.io/lifecycle=normal,node.lino.network/transcoder=true"
#     subnets               = [
#       local.eks_b_node_subnets[ 0 ] ]
#     tags                  = [
#       {
#         key                 = "k8s.io/cluster-autoscaler/enabled"
#         propagate_at_launch = "false"
#         value               = "true"
#       },
#       {
#         key                 = "k8s.io/cluster-autoscaler/${local.eks_b_name}"
#         propagate_at_launch = "false"
#         value               = "true"
#       }
#     ]
#   }

# tags = {
#   CLUSTER_ID = local.eks_b_name
# }


// ASG policy according to cpu utilization. (Only used for scale up).
//resource "aws_autoscaling_policy" "cpu" {
//  count                     = length(module.prd-paco-eks.workers_asg_names)
//  name                      = local.eks_b_name
//  autoscaling_group_name    = module.prd-paco-eks.workers_asg_names[ count.index ]
//  estimated_instance_warmup = 60
//
//  policy_type = "TargetTrackingScaling"
//  target_tracking_configuration {
//    predefined_metric_specification {
//      predefined_metric_type = "ASGAverageCPUUtilization"
//    }
//    target_value     = 80.0
//    disable_scale_in = true
//  }
//}

// Below is for dns: (1/4) iam policy attached to worker node
module "policy_external_dns_b" {
  source      = "../../modules/aws-iam-policy-attachment-v0513"
  for_each    = local.eks_b_policy_names
  role        = each.value
  name        = format("%s-paco-ingest-external-dns-%s", local.env, local.v_tag)
  description = "Grants permission to manage Route53. Managed by Terraform."

  policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Effect": "Allow",
     "Action": [
       "route53:ChangeResourceRecordSets"
     ],
     "Resource": [
       "arn:aws:route53:::hostedzone/*"
     ]
   },
   {
     "Effect": "Allow",
     "Action": [
       "route53:ListHostedZones",
       "route53:ListResourceRecordSets"
     ],
     "Resource": [
       "*"
     ]
   }
 ]
}
EOF
}

// Below is for s3: (2/4) iam policy attached to worker node
//resource "aws_iam_role_policy_attachment" "attachment" {
//  role       = module.prd-paco-eks.worker_iam_role_name
//  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
//}
module "policy_s3" {
  source      = "../../modules/aws-iam-policy-attachment-v0513"
  for_each    = local.eks_b_policy_names
  role        = each.value
  name        = format("%s-paco-s3-%s-", local.env, local.v_tag)
  description = "Grant permission to manage S3. Managed by Terraform."

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::prd-paco-playback/*",
        "arn:aws:s3:::prd-paco-livepacoing/*"
      ]
    }
  ]
}
EOF
}

# Below is for lb: (3/4) iam policy attached to worker node
module "policy_lb" {
  source      = "../../modules/aws-iam-policy-attachment-v0513"
  for_each    = local.eks_b_policy_names
  role        = each.value
  description = "Grant permission to manage Load balancer by Ingress Controller. Managed by Terraform."
  name        = format("%s-policy-lb-%s-", local.env, local.v_tag)

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "acm:DescribeCertificate",
                "acm:ListCertificates",
                "acm:GetCertificate"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:CreateSecurityGroup",
                "ec2:CreateTags",
                "ec2:DeleteTags",
                "ec2:DeleteSecurityGroup",
                "ec2:DescribeInstances",
                "ec2:DescribeInstanceStatus",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeSubnets",
                "ec2:DescribeAvailabilityZones",
                "ec2:DescribeTags",
                "ec2:DescribeVpcs",
                "ec2:ModifyInstanceAttribute",
                "ec2:ModifyNetworkInterfaceAttribute",
                "ec2:RevokeSecurityGroupIngress"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:AddTags",
                "elasticloadbalancing:CreateListener",
                "elasticloadbalancing:CreateLoadBalancer",
                "elasticloadbalancing:CreateRule",
                "elasticloadbalancing:CreateTargetGroup",
                "elasticloadbalancing:DeleteListener",
                "elasticloadbalancing:DeleteLoadBalancer",
                "elasticloadbalancing:DeleteRule",
                "elasticloadbalancing:DeleteTargetGroup",
                "elasticloadbalancing:DeregisterTargets",
                "elasticloadbalancing:DescribeListeners",
                "elasticloadbalancing:DescribeLoadBalancers",
                "elasticloadbalancing:DescribeLoadBalancerAttributes",
                "elasticloadbalancing:DescribeRules",
                "elasticloadbalancing:DescribeSSLPolicies",
                "elasticloadbalancing:DescribeTags",
                "elasticloadbalancing:DescribeTargetGroups",
                "elasticloadbalancing:DescribeTargetGroupAttributes",
                "elasticloadbalancing:DescribeTargetHealth",
                "elasticloadbalancing:ModifyListener",
                "elasticloadbalancing:ModifyLoadBalancerAttributes",
                "elasticloadbalancing:ModifyRule",
                "elasticloadbalancing:ModifyTargetGroup",
                "elasticloadbalancing:ModifyTargetGroupAttributes",
                "elasticloadbalancing:RegisterTargets",
                "elasticloadbalancing:RemoveTags",
                "elasticloadbalancing:SetIpAddressType",
                "elasticloadbalancing:SetSecurityGroups",
                "elasticloadbalancing:SetSubnets",
                "elasticloadbalancing:SetWebACL",
                "elasticloadbalancing:DescribeListenerCertificates",
                "elasticloadbalancing:AddListenerCertificates",
                "elasticloadbalancing:RemoveListenerCertificates"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "iam:GetServerCertificate",
                "iam:ListServerCertificates"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "waf-regional:GetWebACLForResource",
                "waf-regional:GetWebACL",
                "waf-regional:AssociateWebACL",
                "waf-regional:DisassociateWebACL"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "tag:GetResources",
                "tag:TagResources"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "waf:GetWebACL"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

# Below is for asg: (4/4) iam policy attached to worker node
module "policy_asg" {
  source      = "../../modules/aws-iam-policy-attachment-v0513"
  for_each    = local.eks_b_policy_names
  role        = each.value
  name        = format("%s-paco-asg-%s-", local.env, local.v_tag)
  description = "Grant permission to manage asg. Managed by Terraform."
  depends_on = [
    module.prd-paco-eks
  ]

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "autoscaling:DescribeTags",
                "autoscaling:DescribeAutoScalingGroups",
                "autoscaling:DescribeAutoScalingInstances",
                "autoscaling:DescribeLaunchConfigurations",
                "autoscaling:SetDesiredCapacity",
                "autoscaling:TerminateInstanceInAutoScalingGroup"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

# // create aws route 53 hosted zone
# resource "null_resource" "inner" {
#   provisioner "local-exec" {
#     command = <<EOF
# aws route53 create-hosted-zone --name "inner.paco.com." --caller-reference "inner-paco-com-$(date +%s)" --hosted-zone-config Comment="Managed by Terraform",PrivateZone=true --vpc VPCRegion="eu-central-1",VPCId=${local.eks_b_vpc_id} --vpc VPCRegion="eu-west-1",VPCId=${local.eks_app_vpc_id}
# EOF
#   }
# }
