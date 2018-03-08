FROM openjdk:8-slim

ENV SDK_TOOLS "3859397"
ENV BUILD_TOOLS "26.0.2"
ENV TARGET_SDK "26"
ENV ANDROID_HOME "/sdk"
ENV GRADLE_HOME /gradle
ENV GRADLE_VERSION 4.6

ARG GRADLE_DOWNLOAD_SHA256=98bd5fd2b30e070517e03c51cbb32beee3e2ee1a84003a5a5d748996d4b1b915

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    wget \
    lib32stdc++6 \
    libgcc1 \
    zlib1g-dev \
    libncurses5-dev \
    libsdl1.2debian \
    qemu-kvm \
    build-essential \
    libglu1 \
    python2.7

RUN echo "Downloading Gradle" \
	&& wget --no-verbose --output-document=gradle.zip "https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip" \
	\
	&& echo "Checking download hash" \
	&& echo "${GRADLE_DOWNLOAD_SHA256} *gradle.zip" | sha256sum -c \
	&& echo "Installing Gradle" \
	&& unzip gradle.zip \
	&& rm gradle.zip \
	&& mv "gradle-${GRADLE_VERSION}" "${GRADLE_HOME}/" \
	&& ln -s "${GRADLE_HOME}/bin/gradle" /usr/bin/gradle



# Download and extract Android Tools
RUN wget http://dl.google.com/android/repository/sdk-tools-linux-${SDK_TOOLS}.zip -O /tmp/tools.zip && \
    mkdir -p ${ANDROID_HOME} && \
    unzip /tmp/tools.zip -d ${ANDROID_HOME} && \
    rm -v /tmp/tools.zip && \
    ln -s "${ANDROID_HOME}/tools/bin/sdkmanager" /usr/bin/sdkmanager && \
    ln -s "${ANDROID_HOME}/tools/bin/avdmanager" /usr/bin/avdmanager && \
    ln -s "${ANDROID_HOME}/tools/emulator" /usr/bin/emulator

# Install SDK Packages
RUN mkdir -p /root/.android/ && touch /root/.android/repositories.cfg && \
    yes | sdkmanager "--licenses"
    
RUN wget -nv https://pypi.python.org/packages/1e/8e/40c71faa24e19dab555eeb25d6c07efbc503e98b0344f0b4c3131f59947f/vnc2flv-20100207.tar.gz && tar -zxvf vnc2flv-20100207.tar.gz && rm vnc2flv-20100207.tar.gz && \
    cd vnc2flv-20100207 && ln -s /usr/bin/python2.7 /usr/bin/python && python setup.py install

RUN mkdir /sdk/tools/keymaps && \
    touch /sdk/tools/keymaps/en-us

RUN mkdir /helpers

COPY wait-for-avd-boot.sh /helpers

ADD packages.txt /sdk

RUN sdkmanager --package_file=/sdk/packages.txt --verbose

RUN sdkmanager --update
