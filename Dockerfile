FROM openjdk:8u342-jre

# Update packages and install prerequisites
RUN apt update && \
    apt install -y --no-install-recommends \
    unzip \
    curl \
    python3 \
    python3-pip \
    python-is-python3 && \
    rm -rf /var/lib/apt/lists/*

RUN pip3 install \
    pygame \
    pillow

# Download and install Minecraft Forge
RUN mkdir /bin/forge
WORKDIR /bin/forge

RUN curl \
    -L https://maven.minecraftforge.net/net/minecraftforge/forge/1.12.2-14.23.5.2860/forge-1.12.2-14.23.5.2860-installer.jar \
    -o /bin/forge/forge-installer.jar
RUN java -jar forge-installer.jar --installServer
RUN printf "#%s\neula=true" "\$(date)" > /bin/forge/eula.txt

# Download and install Raspberry Jam
RUN mkdir /tmp/RaspberryJamMod
RUN curl -L https://github.com/arpruss/raspberryjammod/releases/download/0.94/mods.zip -o /tmp/RaspberryJamMod/mods.zip
RUN curl -L https://github.com/arpruss/raspberryjammod/releases/download/0.94/python-scripts.zip -o /tmp/RaspberryJamMod/python-scripts.zip
RUN unzip /tmp/RaspberryJamMod/mods.zip -d /tmp/RaspberryJamMod
RUN unzip /tmp/RaspberryJamMod/python-scripts.zip -d /tmp/RaspberryJamMod
RUN mkdir /bin/forge/mods
RUN cp /tmp/RaspberryJamMod/1.12.2/*.jar /bin/forge/mods/
RUN cp -a /tmp/RaspberryJamMod/mcpipy /bin/forge/mcpipy

EXPOSE 25565 14711 4711

CMD ["java", "-jar", "forge-1.12.2-14.23.5.2860.jar"]
