FROM perl:5.40

WORKDIR /app

RUN cpanm Carton

COPY cpanfile cpanfile.snapshot ./
RUN carton install --deployment

COPY . .

EXPOSE 8080

CMD ["carton", "exec", "perl", "popfile.pl"]
