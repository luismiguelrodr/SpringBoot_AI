FROM mcr.microsoft.com/devcontainers/java:17

# Install AI/ML tools
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    openjdk-17-jdk \
    maven \
    && rm -rf /var/lib/apt/lists/*

# Install Python ML libraries
RUN pip3 install \
    tensorflow \
    numpy \
    pandas \
    scikit-learn \
    openai \
    langchain

# Install additional Java tools
RUN sdk install springboot