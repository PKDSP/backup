output "ip_addresses_nginx" {
  value = ["${aws_instance.nginx.public_dns}"]
}
output "ip_addresses_nodejs" {
  value = ["${aws_instance.nodejs.public_dns}"]
}
output "ip_addresses_postgres" {
  value = ["${aws_instance.postgres.public_dns}"]
}