FROM python:3.11-slim
RUN apt-get update && apt-get install -y openjdk-11-jre && rm -rf /var/lib/apt/lists/*
RUN java -version || echo "Java installation failed"
WORKDIR /app
COPY . .
RUN pip install --no-cache-dir -r requirements.txt
RUN chmod +x padel.sh
EXPOSE 5000
CMD ["gunicorn", "server:app", "--bind", "0.0.0.0:5000"]
