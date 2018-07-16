FROM ubuntu:14.04

MAINTAINER CHEF
RUN apt-get update && apt-get install -y apt-transport-https
RUN apt-get install -y apache2
COPY /test/index.html /var/www/html/
RUN export PATH=$PATH:/usr/sbin/
EXPOSE 80
#CMD ["sudo service apache2 start", "-D", "FOREGROUND"]
CMD /usr/sbin/apachectl -D FOREGROUND

