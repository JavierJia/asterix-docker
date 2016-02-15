# Docker container for Asterix NC

FROM jianfeng/asterix-base:kiwi

# Create /nc and grant ownership to asterix
# chown asterix:asterix /nc*

# Set up the entrypoint
# NOTE: use root for now. since the ownership of the volumn cann't be easily changed
# USER asterix 
WORKDIR /home/asterix
ENTRYPOINT [ "/asterix/asterix-startup.sh", "nc" ]
EXPOSE 5000-8000
