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

# Determine JAVA_HOME dynamically and write to a script
RUN JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java)))) && \
    echo "export JAVA_HOME=$JAVA_HOME" > /app/set_java_home.sh && \
    echo "export PATH=\$JAVA_HOME/bin:\$PATH" >> /app/set_java_home.sh

WORKDIR /app
COPY . .
RUN pip install --no-cache-dir -r requirements.txt || echo "Failed to install dependencies"
RUN chmod +x padel.sh set_java_home.sh

# Set the startup command to source the script and run gunicorn
CMD ["/bin/bash", "-c", ". /app/set_java_home.sh && gunicorn server:app --bind 0.0.0.0:${PORT:-5000}"]
