FROM python:3.11-slim

# Install Java and debug
RUN apt-get update && apt-get install -y openjdk-11-jre && rm -rf /var/lib/apt/lists/*
RUN java -version || echo "Java installation failed"
RUN which java || echo "Java binary not found in PATH"
RUN echo "PATH is: $PATH"

# Set JAVA_HOME and update PATH
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV PATH=$JAVA_HOME/bin:$PATH
RUN java -version || echo "Java still not found after setting PATH"

WORKDIR /app
COPY . .
RUN pip install --no-cache-dir -r requirements.txt
RUN chmod +x padel.sh
EXPOSE 5000
CMD ["gunicorn", "server:app", "--bind", "0.0.0.0:5000"]
