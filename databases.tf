resource "rds_instance" "testrdsinstance" {
    allocated_storage = 20
    engine = "mysql"
    engine_version = "8.0"
    instance_class = "db.tg4.micro"
    name = "testdb"
    username = "admin"
    password = data.aws_secretsmanager_secret_version.db_password.secret_string
    parameter_group_name = "default.mysql8.0"
    skip_final_snapshot = true
    vpc_security_group_ids = [aws_security_group.testsecuritygroup.id]
    db_subnet_group_name = aws_subnet_group.testdbsubnetgroup.name
    multi_az = false
}
resource "aws_db_subnet_group" "testdbsubnetgroup" {
    name = "testdbsubnetgroup"
    subnet_ids = [aws_subnet.testprivatesubnet.id]
}