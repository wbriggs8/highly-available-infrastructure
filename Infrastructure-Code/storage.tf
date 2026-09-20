resource "aws_efs_file_system" "wp-efs-file-system" {
    encrypted = true
    kms_key_id = aws_kms_key.main-kms-key.id
}

resource "aws_efs_mount_target" "wp-efs-mount-target1" {
    file_system_id = aws_efs_file_system.wp-efs-file-system.id
    subnet_id = aws_subnet.application-subnet1.id
    security_groups = [aws_security_group.efs-security-group.id]
}
resource "aws_efs_mount_target" "wp-efs-mount-target2" {
    file_system_id = aws_efs_file_system.wp-efs-file-system.id
    subnet_id = aws_subnet.application-subnet2.id
    security_groups = [aws_security_group.efs-security-group.id]
}
resource "aws_efs_mount_target" "wp-efs-mount-target3" {
    file_system_id = aws_efs_file_system.wp-efs-file-system.id
    subnet_id = aws_subnet.application-subnet3.id
    security_groups = [aws_security_group.efs-security-group.id]
}
# to mount the asg wordpress application storage across all subnets that the asg uses