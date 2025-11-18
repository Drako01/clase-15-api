FROM maven:3.9-eclipse-temurin-21 AS builder
WORKDIR /workspace

# Copiar las dependencias
COPY pom.xml .
RUN mvn -B -f pom.xml dependency:go-offline

# Copiar el resto de los archivos
COPY src ./src
RUN mvn -B -DskipTests clean package

FROM eclipse-temurin:21-jre
WORKDIR /app

ENV JAVA_OPTS=""
ENV PORT=8080

COPY --from=builder /workspace/target/*.jar app.jar
EXPOSE 8080

CMD [ "sh", "-c", "exec java $JAVA_OPTS -Dserver.port=${PORT:-8080} -jar app.jar" ]
