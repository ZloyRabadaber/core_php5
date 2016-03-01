use:
docker run -p 80:80 zrabadaber/core_php5

check for correct:
http://localhost/myip.php
http://localhost/phpinfo.php

you can redefine http directory:
docker run -p 80:80 -v some_dir:/var/www zrabadaber/core_php5
