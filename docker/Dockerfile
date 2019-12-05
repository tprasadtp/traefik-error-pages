# nginx
FROM nginx:alpine as nginx

COPY nginx/nginx.conf /etc/nginx/conf.d/default.conf
COPY _site/ /var/www/public/
