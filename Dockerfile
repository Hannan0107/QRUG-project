FROM python:3.11

# Set the working directory
WORKDIR /app

# Update package sources and install Java and system dependencies
RUN echo "deb http://deb.debian.org/debian bullseye main" > /etc/apt/sources.list && \
    echo "deb http://deb.debian.org/debian-security bullseye-security main" >> /etc/apt/sources.list && \
    apt-get update || { echo "apt-get update failed"; exit 1; }
RUN apt-get install -y --no-install-recommends \
    openjdk-11-jre \
    build-essential \
    cmake \
    || { echo "apt-get install failed"; exit 1; }
RUN rm -rf /var/lib/apt/lists/*

# Verify Java installation
RUN java -version || echo "Java installation failed during build"

# Set JAVA_HOME dynamically and create the environment script
RUN JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java)))) && \
    echo "export JAVA_HOME=$JAVA_HOME" > /app/set_java_home.sh && \
    echo "export PATH=\$JAVA_HOME/bin:\$PATH" >> /app/set_java_home.sh

# Verify Python and pip versions
RUN python --version
RUN pip --version

# Upgrade pip to avoid potential issues
RUN pip install --upgrade pip

# Copy application files
COPY . .

# Install gunicorn first to isolate it from other dependencies
RUN pip install gunicorn==20.1.0 --verbose || echo "Failed to install gunicorn"
RUN pip list | grep gunicorn || echo "gunicorn not in pip list"
RUN pip show gunicorn || echo "pip show gunicorn failed"
RUN which gunicorn || echo "gunicorn not found after installation"

# Install other dependencies from requirements.txt
RUN pip install --no-cache-dir -r requirements.txt --verbose || echo "Failed to install dependencies from requirements.txt"

# Ensure scripts are executable
RUN chmod +x padel.sh set_java_home.sh

# Debug the port at runtime
CMD ["/bin/bash", "-c", ". /app/set_java_home.sh && echo 'Binding to port ${PORT:-5000}' && gunicorn server:app --bind 0.0.0.0:${PORT:-5000}"]
