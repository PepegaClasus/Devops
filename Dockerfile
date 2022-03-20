FROM python:3.8-slim-buster


RUN apt-get update -y

COPY requirements.txt ./
RUN pip install -r requirements.txt

WORKDIR /app 
COPY . .

CMD [ "python3", "jenkins.py"]
