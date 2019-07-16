resource "aws_ecr_repository" "flask_app" {
    name = "flask"
}

output "flask-repository" {
    value = "${aws_ecr_repository.flask_app.repository_url}"
    description = "Flask application Docker image repository URL"
}