# Use the Eclipse Temurin Java 11 JRE as the base image
FROM eclipse-temurin:11-jre

# Set the working directory to /app at the start
WORKDIR /app

# Install Python and dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    build-essential \
    cmake \
    && rm -rf /var/lib/apt/lists/*
RUN ln -s /usr/bin/python3 /usr/bin/python

# Verify Java installation
RUN java -version || echo "Java installation failed during build"
RUN which java || echo "Java binary not found in PATH during build"

# Set JAVA_HOME dynamically and create the environment script
RUN JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java)))) && \
    echo "export JAVA_HOME=$JAVA_HOME" > /app/set_java_home.sh && \
    echo "export PATH=\$JAVA_HOME/bin:\$PATH" >> /app/set_java_home.sh

# Copy application files
COPY . .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt || echo "Failed to install dependencies"

# Ensure scripts are executable
RUN chmod +x padel.sh set_java_home.sh

# Run the application with the environment script sourced
CMD ["/bin/bash", "-c", ". /app/set_java_home.sh && gunicorn server:app --bind 0.0.0.0:${PORT:-5000}"]
