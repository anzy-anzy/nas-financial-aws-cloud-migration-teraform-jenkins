resource "aws_db_instance" "this" {
  identifier = "${var.project}-${var.env}-mysql"

  engine         = "mysql"
  instance_class = var.instance_class

  allocated_storage = var.allocated_storage
  storage_type       = "gp3"
  storage_encrypted  = true

  db_name  = var.db_name
  username = var.db_username
  password = random_password.db.result

  multi_az               = var.multi_az
  publicly_accessible    = false
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [var.db_sg_id]

  backup_retention_period = var.backup_retention_days

  # Project-friendly defaults
  deletion_protection = false
  skip_final_snapshot = true

  tags = merge(var.tags, {
    Name = "${var.project}-${var.env}-mysql"
  })
}
