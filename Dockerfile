# Use a base image with both Python and Java
FROM openjdk:11-jre-slim-buster

# Install Python and dependencies
RUN apt-get update && apt-get install -y python3 python3-pip && rm -rf /var/lib/apt/lists/*
RUN ln -s /usr/bin/python3 /usr/bin/python

# Verify Java and Python
RUN java -version
RUN python --version

# Set JAVA_HOME
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV PATH=$JAVA_HOME/bin:$PATH

WORKDIR /app
COPY . .
RUN pip install --no-cache-dir -r requirements.txt
RUN chmod +x padel.sh
EXPOSE 5000
CMD ["gunicorn", "server:app", "--bind", "0.0.0.0:5000"]
