# Use the official OpenJDK base image with Alpine Linux
FROM openjdk:8-alpine

# Set the working directory
WORKDIR /minecraft

# Copy the Minecraft server JAR file into the container
COPY server.jar .

# Create a volume for persistent data (world data)
VOLUME ["/minecraft/world"]

# Expose the default Minecraft server port
EXPOSE 25565

# Start the Minecraft server
CMD ["java", "-Xmx1024M", "-Xms1024M", "-jar", "minecraft_server.jar", "nogui"]
