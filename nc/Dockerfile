# Docker container for Asterix NC

FROM jianfeng/asterix-base:master

# Create /nc and grant ownership to asterix
chown asterix:asterix /nc*

# Set up the entrypoint
USER asterix
WORKDIR /home/asterix
ENTRYPOINT [ "/asterix/asterix-startup.sh", "nc" ]
EXPOSE 5000-8000
