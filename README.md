# README
Setup cơ bản CI cho một ứng dụng Rails. Hướng dẫn này sẽ chia thành nhiều phần. Và việc đầu tiên chúng ta cần làm là Dockerize ứng dụng của mình.

# Dockerize my app

## Write Dockerfile

Dưới đây là một Dockerfile cơ bản nhất cho ứng dụng Rails của chúng ta:
```
FROM ruby:2.6.5
RUN apt-get update -qq && \
  apt-get install -y nodejs \
  mysql-client

ENV APP_ROOT /webapp
RUN mkdir $APP_ROOT
WORKDIR $APP_ROOT

COPY Gemfile $APP_ROOT/Gemfile
COPY Gemfile.lock $APP_ROOT/Gemfile.lock
RUN bundle install
COPY . $APP_ROOT

RUN ["chmod", "+x", "startup.sh"]
```
Hãy cùng đi phân tích từng dòng của Dockerfile trên.
`FROM ruby:2.6.5`: Dòng này là thông báo image này dựa trên ruby:2.6.5

```
RUN apt-get update -qq && \
  apt-et install -y nodejs \
  mysql-client
```
Đoạn này update và cài những package cần thiết cho image.

```
ENV APP_ROOT /webapp
RUN mkdir $APP_ROOT
WORKDIR $APP_ROOT
```
Đoạn này tạo folder gốc cho image

```
COPY Gemfile $APP_ROOT/Gemfile
COPY Gemfile.lock $APP_ROOT/Gemfile.lock
RUN bundle install
COPY . $APP_ROOT
```
Copy Gemfile và Gemfile.lock vào image và chạy bundle install để cài gem cần thiết. Sau đó copy toàn thư mục hiện tại vào APP_ROOT

Như vậy là chúng ta đã có 1 image tạm đủ để chạy ứng dụng. Bước tiếp theo là viết docker-compose để chạy image trên và thêm mysql để thành ứng dụng hoàn chỉnh.

## Write docker-compose.yml

Giờ nhìn qua phát docker-compose nó là cái gì nào:
```
version: '3'
services:
  db:
    image: mysql:5.7.29
    restart: always
    volumes:
      - ./tmp/db:/var/lib/mysql
  webapp:
    build: .
    entrypoint: ./startup.sh
    volumes:
      - .:/webapp
    ports:
      - 3000:3000
    depends_on:
      - db
```

Dòng đầu để khai báo version của file.
Tiếp theo là các services của ứng dụng:
```
db:
  image: mysql:5.7.29
  restart: always
  volumes:
    - ./tmp/db:/var/lib/mysql
```
Đây là database của chúng ta, dòng image là tên image và có thể tìm trên dockerhub. Dòng restart để ứng dụng này khởi động lại khi bị lỗi. Volumes là kết nối thư mục máy thật và container.

```
webapp:
  build: .
  entrypoint: ./startup.sh
  volumes:
    - .:/webapp
  ports:
    - 3000:3000
  depends_on:
    - db
```
Đây là app Rails của mình. Entrypoint là command sẽ run lúc tạo ứng dụng, file này trong thư mục gốc ứng dụng. Ports để set từ port máy thật qua container. Depends_on là những services cần thiết cho app này.

Tạm thời như này là đủ cho bước tiếp theo là setup CI.

# Setup CircleCI
