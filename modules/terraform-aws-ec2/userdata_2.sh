              #!/bin/bash
              apt-get update
              apt-get install -y docker.io curl
              curl -L "https://github.com/docker/compose/releases/download/1.25.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
              chmod +x /usr/local/bin/docker-compose
              curl -LO https://github.com/apache/incubator-devlake/releases/download/v0.16.1/docker-compose.yml
              curl -LO https://github.com/apache/incubator-devlake/releases/download/v0.16.1/env.example
              mv env.example .env
              openssl rand -base64 2000 | tr -dc 'A-Z' | fold -w 128 | head -n 1 > .env
              docker-compose up -d
              EOF