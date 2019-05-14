FROM ubuntu:14.04 as builder

RUN useradd docker \
	&& mkdir /home/docker \
	&& chown docker:docker /home/docker \
	&& addgroup docker staff

COPY /site /home/docker/site
COPY /nginx /home/docker/nginx

# Install Hugo
RUN apt-get update && apt-get install -y --no-install-recommends wget

RUN wget --no-check-certificate https://github.com/spf13/hugo/releases/download/v0.54.0/hugo_0.54.0_Linux-64bit.deb
RUN dpkg -i hugo_0.54.0_Linux-64bit.deb

## Build Site
WORKDIR /home/docker/site
RUN ls
RUN hugo


FROM nginx:1.13.3-alpine

## Remove default nginx website
RUN rm -rf /usr/share/nginx/html/*

## Copy our default nginx config
COPY --from=builder /home/docker/nginx/default.conf /etc/nginx/conf.d/

## Copy compiled site
COPY --from=builder /home/docker/site/public /usr/share/nginx/html

## Copy mainfest files to nginx folder
COPY --from=builder /home/docker/site/browserconfig.xml /usr/share/nginx/html
COPY --from=builder /home/docker/site/site.webmanifest /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
