FROM perl:5.40

WORKDIR /app

RUN cpanm Carton

COPY cpanfile cpanfile.snapshot ./
RUN carton install --deployment

COPY . .

EXPOSE 7070

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]
