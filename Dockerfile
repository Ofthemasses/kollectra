FROM alpine:3.21.3

ENV SBT_VERSION="1.10.7"
ENV OSS_VERSION="2025-02-17"

RUN apk add --no-cache \
    "curl=8.12.1-r0" \
	"tar=1.35-r2" \
    "bash=5.2.37-r0" \
    "make=4.4.1-r2" \
    "openjdk17-jdk=17.0.14_p7-r0" \
    "git=2.47.2-r0"

RUN curl -L https://github.com/sbt/sbt/releases/download/v${SBT_VERSION}/sbt-${SBT_VERSION}.tgz -o sbt.tgz && \
    tar -xzvf sbt.tgz -C /usr/local/ && \
    ln -s /usr/local/sbt/bin/sbt /usr/local/bin/sbt && \
    rm sbt.tgz

RUN curl -L \
	https://github.com/YosysHQ/oss-cad-suite-build/releases/download/${OSS_VERSION}/oss-cad-suite-linux-x64-${OSS_VERSION//-/}.tgz \
	-o oss.tgz && \
	tar -xzvf oss.tgz -C /opt/ && \
    rm oss.tgz
	
WORKDIR /project

ENTRYPOINT ["/bin/bash", "-c", "source /opt/oss-cad-suite/environment && exec /bin/bash"]
