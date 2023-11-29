FROM python:3-alpine

WORKDIR /usr/src/app

RUN apk add gcc musl-dev make 'luajit' 'luajit-dev'

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

RUN make
RUN make install

CMD [ "python", "./shithouse_tv.py", "-s", "/usr/src/app"]
