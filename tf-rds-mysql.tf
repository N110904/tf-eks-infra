#create a security group for RDS Database Instance
resource "aws_security_group" "rds_sg" {
  name = "rds_sg"
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#create a RDS Database Instance
resource "aws_db_instance" "rdsmysqldb" {
  engine               = "mysql"
  identifier           = "rdsmysqldb7879"
  db_name = "my_schema"
  allocated_storage    =  10
  engine_version       = "8.0.33"
  instance_class       = "db.t2.micro"
  username             = "admin"
  password             = "1qazWSX12345"
  ##parameter_group_name = "custom.mysql8.0.33"
  vpc_security_group_ids = ["${aws_security_group.rds_sg.id}"]
  skip_final_snapshot  = true
  publicly_accessible =  true
  storage_type = "gp2"
  ##db_subnet_group_name = ""
  ##delete_automated_backups = 
  allow_major_version_upgrade = false
  auto_minor_version_upgrade = false
  ##backup_retention_period = 7
  ##backup_window = "22:00-23:00"   ##UTC
  ##multi_az = true
  
}