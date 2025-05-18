# Use an official Python runtime as the base image
FROM python:3.11-slim

# Install Java (required for PaDEL-Descriptor)
RUN apt-get update && apt-get install -y default-jre && rm -rf /var/lib/apt/lists/*

# Set the working directory in the container
WORKDIR /app

# Copy the project files into the container
COPY . .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Ensure padel.sh is executable
RUN chmod +x padel.sh

# Expose the port the app runs on (Render will override this with PORT env var)
EXPOSE 5000

# Command to run the app with Gunicorn
CMD ["gunicorn", "server:app", "--bind", "0.0.0.0:5000"]