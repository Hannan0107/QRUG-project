FROM eclipse-temurin:11-jre

# Set the working directory
WORKDIR /app

# Install Python and dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    build-essential \
    cmake \
    && rm -rf /var/lib/apt/lists/*
RUN ln -s /usr/bin/python3 /usr/bin/python

# Verify Python and pip versions
RUN python --version
RUN pip --version

# Verify Java installation
RUN java -version || echo "Java installation failed during build"
RUN which java || echo "Java binary not found in PATH during build"

# Set JAVA_HOME dynamically and create the environment script
RUN JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java)))) && \
    echo "export JAVA_HOME=$JAVA_HOME" > /app/set_java_home.sh && \
    echo "export PATH=\$JAVA_HOME/bin:\$PATH" >> /app/set_java_home.sh

# Copy application files
COPY . .

# Install Python dependencies and debug gunicorn installation
RUN pip install --no-cache-dir -r requirements.txt || echo "Failed to install dependencies from requirements.txt"
RUN pip install gunicorn==20.1.0 || echo "Failed to install gunicorn separately"
RUN pip show gunicorn || echo "pip show gunicorn failed"
RUN which gunicorn || echo "gunicorn not found after installation"

# Ensure scripts are executable
RUN chmod +x padel.sh set_java_home.sh

# Debug the port at runtime
CMD ["/bin/bash", "-c", ". /app/set_java_home.sh && echo 'Binding to port ${PORT:-5000}' && gunicorn server:app --bind 0.0.0.0:${PORT:-5000}"]
