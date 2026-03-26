# Build stage
FROM maven:3.9-eclipse-temurin-17-alpine AS build
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline -B
COPY src ./src
RUN mvn package -DskipTests -B

# Run stage
FROM eclipse-temurin:17-jre-alpine
RUN apk add --no-cache curl && addgroup -S spring && adduser -S spring -G spring
WORKDIR /app

# NEW: Copy the config-repo folder so the 'native' profile can find it
COPY config-repo/ /app/config-repo/
COPY --from=build /app/target/*.jar app.jar
RUN chown -R spring:spring /app
USER spring:spring

EXPOSE 8888
HEALTHCHECK --interval=30s --timeout=10s --start-period=120s --retries=3 \
  CMD curl -f http://localhost:8888/actuator/health || exit 1

ENTRYPOINT ["java", "-Djava.security.egd=file:/dev/./urandom", "-jar", "app.jar"]