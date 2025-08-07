# Stage 1: Сборка
FROM openjdk:21-jdk-slim AS builder
WORKDIR /app

# Копируем pom.xml и зависимости
COPY pom.xml .
COPY core/pom.xml core/
COPY service-api/pom.xml service-api/
COPY service/pom.xml service/
COPY dao/pom.xml dao/

RUN apt update && \
    apt install -y maven && \
    mvn dependency:go-offline -B

# Копируем код и собираем
COPY . .
RUN mvn clean package -DskipTests

# Stage 2: Финальный образ — только JRE
FROM eclipse-temurin:21.0.7_6-jre
WORKDIR /app

# Копируем JAR
COPY --from=builder /app/core/target/core.jar ./

EXPOSE 8080

CMD ["java", "-jar", "core.jar"]
