FROM python:3.12-alpine
ADD requirements.txt /code/requirements.txt
ADD app.py /code/app.py
WORKDIR /code
RUN pip install -r requirements.txt
CMD ["python", "app.py"]