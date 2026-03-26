# Build stage
FROM maven:3.9-eclipse-temurin-17-alpine AS build
WORKDIR /app

COPY pom.xml .
RUN mvn dependency:go-offline -B

COPY src ./src
RUN mvn package -DskipTests -B

# Run stage
FROM eclipse-temurin:17-jre-alpine

RUN apk add --no-cache curl && \
    addgroup -S spring && adduser -S spring -G spring

WORKDIR /app
COPY --from=build /app/target/*.jar app.jar
RUN chown spring:spring app.jar
USER spring:spring

EXPOSE 8085

HEALTHCHECK --interval=15s --timeout=5s --start-period=60s --retries=3 \
  CMD curl -sf http://localhost:8085/api/v1/health || exit 1

ENTRYPOINT ["sh", "-c", "TASK_IP=$(hostname -i 2>/dev/null | awk '{print $1}'); [ -z \"$TASK_IP\" ] && TASK_IP=127.0.0.1; export EUREKA_INSTANCE_IP=$TASK_IP; exec java -XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0 -jar app.jar"]