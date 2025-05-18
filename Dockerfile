FROM openjdk:11-jre-slim-buster

# Install Python and system dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    build-essential \
    cmake \
    && rm -rf /var/lib/apt/lists/*
RUN ln -s /usr/bin/python3 /usr/bin/python

# Debug Java installation
RUN java -version || echo "Java installation failed during build"
RUN which java || echo "Java binary not found in PATH during build"
RUN echo "PATH during build: $PATH"
RUN find / -name "java" 2>/dev/null || echo "Java binary not found anywhere"

# Set JAVA_HOME by finding the correct path
RUN JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java)))) && \
    echo "JAVA_HOME set to $JAVA_HOME" && \
    echo "export JAVA_HOME=$JAVA_HOME" >> /etc/environment && \
    echo "export PATH=$JAVA_HOME/bin:$PATH" >> /etc/environment
ENV JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))
ENV PATH=$JAVA_HOME/bin:$PATH

# Verify Java again after setting JAVA_HOME
RUN java -version || echo "Java still not found after setting JAVA_HOME"

RUN python --version

WORKDIR /app
COPY . .
RUN pip install --no-cache-dir -r requirements.txt || echo "Failed to install dependencies"
RUN chmod +x padel.sh
EXPOSE 5000
CMD ["gunicorn", "server:app", "--bind", "0.0.0.0:${PORT:-5000}"]
