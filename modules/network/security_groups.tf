# ports:     0 = all
# protocol: -1 = all
#===========================================================
# Security Group to Allow All Internal Traffic (VPC: main)
#===========================================================
resource "aws_default_security_group" "main-default" {
  vpc_id = aws_vpc.main.id

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
    description = "allow local traffic"
  }

  ingress {
    protocol  = -1
    from_port = 0
    to_port   = 0
    cidr_blocks = [var.openvpn_cidr_block]
    description = "allow peer traffic from openvpn"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    name = "main-default"
    env  = "${var.env}"
  }
}

#===========================================================
# Database (Postgres) Security Group
# Attention to Postgres Port
#===========================================================
resource "aws_security_group" "databases" {
  name        = "database_security_group"
  description = "Security Group For Databases"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    security_groups = [aws_default_security_group.main-default.id, var.openvpn_sg]
    description = "allow local traffic for pg"
  }
}

#===========================================================
# EMR Studio: Engine - Allow Traffic From Workspace
#===========================================================
resource "aws_security_group" "emr_engine_security_group" {
  name        = "emr_engine_security_group"
  description = "allow traffic from workspace"
  vpc_id      = aws_vpc.main.id
  tags        = {
    for-use-with-amazon-emr-managed-policies = true
  }
}

resource "aws_security_group_rule" "emr_engine_security_group_egress" {
  type                      = "egress"
  from_port                 = 0
  to_port                   = 0
  protocol                  = -1
  security_group_id         = aws_security_group.emr_engine_security_group.id
  cidr_blocks               = ["0.0.0.0/0"]
  description               = "allow all egress traffic"
  depends_on = [
    aws_security_group.emr_engine_security_group,
    aws_security_group.emr_workspace_security_group
  ]
}

resource "aws_security_group_rule" "emr_engine_security_group" {
  type                      = "ingress"
  from_port                 = 18888
  to_port                   = 18888
  protocol                  = "tcp"
  security_group_id         = aws_security_group.emr_engine_security_group.id
  source_security_group_id  = aws_security_group.emr_workspace_security_group.id
  description               = "allow traffic from workspace"
  depends_on = [
    aws_security_group.emr_engine_security_group,
    aws_security_group.emr_workspace_security_group
  ]
}

#===========================================================
# EMR Studio: Workspace - Allow Traffic To Engine and To Git
#===========================================================
resource "aws_security_group" "emr_workspace_security_group" {
  name        = "emr_workspace_security_group"
  description = "allow all egress traffic"
  vpc_id      = aws_vpc.main.id
  tags        = {
    for-use-with-amazon-emr-managed-policies = true
  }
}

resource "aws_security_group_rule" "emr_workspace_security_group_egress" {
  type                      = "egress"
  from_port                 = 0
  to_port                   = 0
  protocol                  = -1
  security_group_id         = aws_security_group.emr_workspace_security_group.id
  cidr_blocks               = ["0.0.0.0/0"]
  description               = "allow traffic from workspace"
  depends_on = [
    aws_security_group.emr_engine_security_group,
    aws_security_group.emr_workspace_security_group
  ]
}

resource "aws_security_group_rule" "emr_workspace_security_group_18888" {
  type                      = "egress"
  from_port                 = 18888
  to_port                   = 18888
  protocol                  = "tcp"
  security_group_id         = aws_security_group.emr_workspace_security_group.id
  source_security_group_id  = aws_security_group.emr_engine_security_group.id
  description               = "allow traffic to engine"
  depends_on = [
    aws_security_group.emr_engine_security_group,
    aws_security_group.emr_workspace_security_group
  ]
}

resource "aws_security_group_rule" "emr_workspace_security_group_443" {
  type                      = "egress"
  from_port                 = 443
  to_port                   = 443
  protocol                  = "tcp"
  cidr_blocks               = ["0.0.0.0/0"]
  security_group_id         = aws_security_group.emr_workspace_security_group.id
  description               = "allow traffic to git" 
  depends_on = [
    aws_security_group.emr_engine_security_group,
    aws_security_group.emr_workspace_security_group
  ]
}