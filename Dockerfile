# Multi-stage or Standalone Maven Container
FROM maven:3.9-eclipse-temurin-17

# Set working directory
WORKDIR /app

# Copy project files
COPY pom.xml .
COPY src ./src

# Pre-compile the application
RUN mvn clean compile -DskipTests

# Expose default port
EXPOSE 8080

# Environment variables
ENV PORT=8080

# Run the embedded Tomcat application
CMD ["mvn", "exec:java"]
