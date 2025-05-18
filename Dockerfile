FROM eclipse-temurin:11-jre

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
RUN find / -name "java" 2>/dev/null || echo "Java binary not found anywhere"

# Determine JAVA_HOME dynamically and write to a temporary file
RUN JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java)))) && \
    echo "JAVA_HOME=$JAVA_HOME" > /tmp/java_home.env

# Source the JAVA_HOME from the temporary file and set it as an environment variable
RUN . /tmp/java_home.env && echo "JAVA_HOME set to $JAVA_HOME"
ENV JAVA_HOME=$(cat /tmp/java_home.env | grep JAVA_HOME | cut -d= -f2)
ENV PATH=$JAVA_HOME/bin:$PATH

# Verify Java after setting JAVA_HOME
RUN java -version || echo "Java still not found after setting JAVA_HOME"

WORKDIR /app
COPY . .
RUN pip install --no-cache-dir -r requirements.txt || echo "Failed to install dependencies"
RUN chmod +x padel.sh
EXPOSE 5000
CMD ["gunicorn", "server:app", "--bind", "0.0.0.0:${PORT:-5000}"]
