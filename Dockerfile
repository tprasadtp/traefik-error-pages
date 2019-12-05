FROM alpine
COPY docker/_site/ /var/www/public/
CMD ["ls", "-la", "/var/www/public"]
