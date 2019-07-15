resource "aws_ecr_repository" "flask-app" {
    name = "flask"
}

output "flask-repository" {
    value = "${aws_ecr_repository.flask-app.repository_url}"
    description = "Flask application Docker image repository URL"
}