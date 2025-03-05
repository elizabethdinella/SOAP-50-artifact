# Use an official OpenJDK runtime as a parent image
FROM openjdk:11.0.11-jdk-slim

RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory in the container
WORKDIR /SOAP-50

# Copy the current directory contents into the container at /app
COPY . /SOAP-50

# Expose port (if your app requires it, e.g., for web applications)
# EXPOSE 8080

# Command to run your Java program (modify as needed)
# For example, to run a jar file:
# CMD ["java", "-jar", "your-app.jar"]

# Or to run a class with the main method:
# CMD ["java", "MainClassName"]

