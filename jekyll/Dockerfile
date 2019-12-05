# jekyll
FROM jekyll/builder:latest as jekyll
WORKDIR /tmp
COPY . /tmp
RUN chown -R jekyll:jekyll /tmp
RUN jekyll build
