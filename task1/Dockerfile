FROM ubuntu:latest

WORKDIR /mo436

ENV TZ=America/Sao_Paulo
ENV DEBIAN_FRONTEND=noninteractive
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ >/etc/timezone

RUN apt -y update && apt -y install  python3 pip libcudart10.1
RUN cd /usr/lib/x86_64-linux-gnu/ && ln -s libcudart.so.10.1.243 libcudart.so.11.0 ; cd -
RUN pip install keras tensorflow tf2onnx netron

COPY task1.py /mo436/task1.py


EXPOSE 80/tcp
EXPOSE 8080/tcp

CMD python3 /mo436/task1.py

