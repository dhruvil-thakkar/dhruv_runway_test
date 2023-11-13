  #!/bin/bash -ex
  yum install nginx -y
  echo "<h1>$(hostname)</h1>" >  /usr/share/nginx/html/index.html 
  systemctl enable nginx
  systemctl start nginx