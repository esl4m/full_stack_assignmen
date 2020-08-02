FROM python:alpine
WORKDIR /var/www

RUN pip install mysql-connector-python

COPY . .
RUN chmod -R +x ./
CMD ["./main.py"]