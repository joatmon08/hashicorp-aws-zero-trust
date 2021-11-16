exit_after_auth = true
pid_file        = "./pidfile"

auto_auth {
  method "aws" {
    mount_path = "auth/aws"
    config = {
      type = "iam"
      role = "AWS_IAM_ROLE"
    }
  }

  sink "file" {
    config = {
      path = "/tmp/token"
    }
  }
}

template {
  source      = "/vault-agent/CONFIG_FILE_NAME"
  destination = "/config/CONFIG_FILE_NAME"
}
