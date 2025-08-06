FROM ubuntu:22.04
WORKDIR /popgen
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies and R inside the container
RUN apt-get update && apt-get install -y \
    software-properties-common \
    dirmngr \
    gnupg \
    curl && \
    curl -fsSL https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | gpg --dearmor -o /usr/share/keyrings/cran-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/cran-archive-keyring.gpg] https://cloud.r-project.org/bin/linux/ubuntu jammy-cran40/" >> /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y r-base && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install art_illumina inside the container
RUN apt-get update && \
    apt-get install -y art-nextgen-simulation-tools && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy all scripts and fsc28 inside the /app in the container
COPY . /popgen

RUN chmod +x popgenART.sh *.sh

CMD ["/bin/bash", "popgenART.sh", "-i", "sample_input.csv", "-p", "trial", "-f", "./fsc28", "-a", "art_illumina"]

