FROM python:3.12-slim
RUN apt-get update -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt .
COPY app.py .
COPY .env .

RUN pip install --no-cache-dir -r requirements.txt


EXPOSE 5000

HEALTHCHECK --interval=10s --timeout=5s --retries=3 --start-period=10s \
    CMD python -c "import http.client; http.client.HTTPConnection('localhost', 5000).request('GET', '/health'); exit(0)"

CMD ["python", "app.py"]
