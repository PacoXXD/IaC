region = "eu-west-1"
env    = "prd"
v_tag  = "20221026"



es_domain_name = "prd-es-search"
sg_id          = "sg-06aa603f0414a8221"
engine_version = "Elasticsearch_7.7"
#instance_type  = "r6g.large.search"
instance_type  = "r5.large.search"
subnet_ids     = ["subnet-0125e9cbbf9daa41e", "subnet-020bf002c59c806cf", "subnet-06ec337f23c593802"]