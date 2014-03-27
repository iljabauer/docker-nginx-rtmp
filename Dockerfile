FROM ubuntu:12.04
WORKDIR /home/nginx/
CMD ruby start.rb

RUN /sbin/ip route | awk '/default/ { print "Acquire::http::Proxy \"http://"$3":8000\";" }' > /etc/apt/apt.conf.d/30proxy

ADD sources.list /etc/apt/
RUN apt-get update

RUN apt-get install -y build-essential wget git bison libpcre3 libpcre3-dev zlib1g-dev libssl-dev libhiredis-dev #ffmpeg

RUN groupadd nginx
RUN useradd -m -g nginx nginx

# nginx
RUN cd /home/nginx/ && wget -q http://nginx.org/download/nginx-1.4.3.tar.gz
RUN cd /home/nginx/ && tar -xzvf nginx-1.4.3.tar.gz

# rtmp server
RUN cd /home/nginx/nginx-1.4.3 && git clone git://github.com/arut/nginx-rtmp-module.git


# nginx
RUN cd /home/nginx/nginx-1.4.3; ./configure --prefix=/usr/local/nginx \
  --add-module=ngx_mruby \
  --add-module=ngx_mruby/dependence/ngx_devel_kit \
  --add-module=nginx-rtmp-module \
  --with-http_ssl_module && \
  make && \
  make install

# configuration
RUN rm /usr/local/nginx/conf/nginx.conf
ADD conf/nginx.conf /usr/local/nginx/conf/

# finish up 
RUN chown -R nginx:nginx /usr/local/nginx/
RUN rm -rf /home/nginx/nginx-1.4.3
EXPOSE 8000 8000
EXPOSE 1935 1935
USER nginx
