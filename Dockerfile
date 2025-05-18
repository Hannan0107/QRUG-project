FROM adoptopenjdk/openjdk11:jre-11.0.11_9

# Install Python and dependencies
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

# Set JAVA_HOME and PATH
ENV JAVA_HOME=/opt/java/openjdk
ENV PATH=$JAVA_HOME/bin:$PATH

RUN java -version || echo "Java still not found after setting JAVA_HOME"

WORKDIR /app
COPY . .
RUN pip install --no-cache-dir -r requirements.txt || echo "Failed to install dependencies"
RUN chmod +x padel.sh
EXPOSE 5000
CMD ["gunicorn", "server:app", "--bind", "0.0.0.0:${PORT:-5000}"]
