resource "aws_rds_instance" "testrdsinstance" {
    allocated_storage = 20
    max_allocated_storage = 50
    min_allocated_storage = 20
    engine = "mysql"
    engine_version = "8.0"
    instance_class = "db.tg4.micro"
    name = "testdb"
    username = "admin"
    password = aws_secretsmanager_secret_version.db_password.secret_string
    parameter_group_name = "default.mysql8.0"
    skip_final_snapshot = true
    vpc_security_group_ids = [aws_security_group.private-tier-securitygroup.id]
    db_subnet_group_name = aws_subnet_group.testdbsubnetgroup.name
    multi_az = false
    storage_encrypted = true
    kms_key_id = aws_kms_key.testkmskey.arn
}
# rds instance defines the engine + version, the class, where it gets its password + how its encrypted
# used default parameter group as well as defined the subnet group + security group for the db
resource "aws_db_subnet_group" "testdbsubnetgroup" {
    name = "testdbsubnetgroup"
    subnet_ids = [aws_subnet.private-subnet.id]
}
resource "aws_kms_key" "testkmskey" {
    description = "KMS key for RDS encryption"
    deletion_window_in_days = 7
}
# kms key used to encrypt the database, with an alias for easy reference
# deletion window of 7 days, if the key is deleted, it will be recoverable for 7 days before being permanently deleted