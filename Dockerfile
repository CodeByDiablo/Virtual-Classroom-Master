# Stage 1: Build the WAR file
# We use a JDK image to have access to the 'jar' command and 'wget'
FROM openjdk:17-jdk-slim AS builder

WORKDIR /app

# 1. Install wget to download the MySQL driver
RUN apt-get update && \
    apt-get install -y wget && \
    rm -rf /var/lib/apt/lists/*

# 2. Download MySQL JDBC Driver (Connector/J)
# We use version 8.0.33 which is compatible with MySQL 8.0 and 5.7
RUN wget https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-j-8.0.33.tar.gz && \
    tar -xzf mysql-connector-j-8.0.33.tar.gz && \
    # Move the jar to a standard location
    mv mysql-connector-j-8.0.33/mysql-connector-j-8.0.33.jar /app/mysql-connector.jar && \
    rm -rf mysql-connector-j-8.0.33*

# 3. Prepare the application structure in a temporary build directory
WORKDIR /app/build
COPY . .

# 4. Create WEB-INF/lib and add the MySQL driver
RUN mkdir -p WEB-INF/lib && \
    cp /app/mysql-connector.jar WEB-INF/lib/

# 5. Clean up unnecessary files before packaging (optional but good practice)
RUN rm -f Dockerfile README.md .gitignore && \
    rm -rf .git .vscode .runtime

# 6. Package everything into a WAR file
# The 'jar' command is used to create the archive. 'c' create, 'v' verbose, 'f' file.
RUN jar -cvf /app/ROOT.war *

# Stage 2: Run in Tomcat
FROM tomcat:9.0-jdk17-temurin

# 1. Clean default Tomcat applications to avoid conflicts and clutter
RUN rm -rf /usr/local/tomcat/webapps/*

# 2. Copy the compiled WAR file from the builder stage
COPY --from=builder /app/ROOT.war /usr/local/tomcat/webapps/ROOT.war

# 3. Expose the default Tomcat port
EXPOSE 8080

# 4. Launch Tomcat
CMD ["catalina.sh", "run"]
