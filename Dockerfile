# Application top directory
ARG APP_TOP=/root/MatlabSupport

# Create the builder image
FROM jesusvasquez333/smurf-epics-slac:R1.0.0 as builder
ARG APP_TOP
# Prepare the build directory
RUN mkdir -p ${APP_TOP}
WORKDIR ${APP_TOP}
# Copy the source code
ADD . .
# Build the application
RUN make distclean && make

# Create the final image
FROM centos:6.10
ARG APP_TOP
## EPICS CONFIGURATIONS (should come from builder)
ENV EPICS_CA_REPEATER_PORT 5065
ENV EPICS_CA_AUTO_ADDR_LIST YES
ENV EPICS_CA_SERVER_PORT 5064
ENV IOC_DATA /data/epics/ioc/data
# Name if the IOC were are running in the container
# (defaults to sioc-smrf-ml00, cab be changed using --build-arg)
ARG IOC_NAME=sioc-smrf-ml00
# Copy the IOC produced during the building stage
COPY --from=builder ${APP_TOP} ${APP_TOP}
# Go to the IOC top level
WORKDIR ${APP_TOP}/iocBoot/${IOC_NAME}
# Start the IOC by default
CMD ["./st.cmd"]
