              #!/bin/bash
              apt-get update -y
              apt-get install -y \
                apt-transport-https \
                ca-certificates \
                curl \
                software-properties-common \
                gnupg \
                lsb-release

              # Install Docker
              curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
              echo \
                "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
                $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

              apt-get update -y
              apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose

              # Enable Docker
              systemctl start docker
              systemctl enable docker

              # Pull specific OpenProject Docker image
              docker pull openproject/openproject:15

              # Run OpenProject container with specified environment variables
              docker run -d --name openproject \
                -e OPENPROJECT_SECRET_KEY_BASE=secret \
                -e OPENPROJECT_HOST__NAME=localhost:8080 \
                -e OPENPROJECT_HTTPS=false \
                -e OPENPROJECT_DEFAULT__LANGUAGE=en \
                -p 8080:80 \
                openproject/openproject:15