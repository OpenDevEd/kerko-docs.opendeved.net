FROM nginx:alpine

ARG SERVER_NAME

COPY nginx.conf /etc/nginx/conf.d

RUN sed -i "s/example.com/${SERVER_NAME}/g" /etc/nginx/conf.d/nginx.conf && \
    rm /etc/nginx/conf.d/default.conf

EXPOSE 80