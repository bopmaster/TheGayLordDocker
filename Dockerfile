FROM openjdk:8-alpine

ENV SDK_TOOLS "3859397"
ENV BUILD_TOOLS "27.0.3"
ENV TARGET_SDK "27"
ENV ANDROID_HOME "/sdk"

RUN apk update \
    && apk upgrade \
    && apk add bash --no-cache libstdc++ qemu-system-x86_64 libvirt qemu-img
# Download and extract Android Tools
RUN wget http://dl.google.com/android/repository/sdk-tools-linux-${SDK_TOOLS}.zip -O /tmp/tools.zip && \
mkdir -p ${ANDROID_HOME} && \
unzip /tmp/tools.zip -d ${ANDROID_HOME} && \
rm -v /tmp/tools.zip

# Install SDK Packages
RUN mkdir -p /root/.android/ && touch /root/.android/repositories.cfg && \
yes | ${ANDROID_HOME}/tools/bin/sdkmanager "--licenses" && \
${ANDROID_HOME}/tools/bin/sdkmanager "--update" && \
${ANDROID_HOME}/tools/bin/sdkmanager "build-tools;${BUILD_TOOLS}" "platform-tools" "platforms;android-${TARGET_SDK}" "extras;android;m2repository" "extras;google;google_play_services" "extras;google;m2repository"
