FROM cirrusci/flutter:latest

RUN sudo apt-get update -y

RUN sudo apt-get install -y --no-install-recommends gnupg

# Add repo for gcloud sdk and install it
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | \
    sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list 

RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | \
    sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -

RUN sudo apt-get update && sudo apt-get install -y google-cloud-sdk && \
    gcloud config set core/disable_usage_reporting true && \
    gcloud config set component_manager/disable_update_check true

RUN yes | sdkmanager \
    "platforms;android-27" \
    "build-tools;27.0.3" \
    "extras;google;m2repository" \
    "extras;android;m2repository" \
    "system-images;android-21;default;armeabi-v7a"

RUN yes | sdkmanager --licenses

# Add repo for Google Chrome and install it
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
RUN echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' | sudo tee /etc/apt/sources.list.d/google-chrome.list
RUN sudo apt-get update && sudo apt-get install -y --no-install-recommends google-chrome-stable

# Add node
RUN curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
RUN sudo apt-get install -y nodejs

# Add firebase CLI
RUN sudo npm install -g firebase-tools
# this mkdir command shouldn't be necessary, as the directory is created by npm -- however, the Docker hub doesn't seem to make it.
RUN sudo mkdir -p /home/cirrus/.config/configstore
RUN sudo chown -R cirrus:cirrus /home/cirrus/.config/configstore

USER cirrus

# Update Flutter so we can do web builds
WORKDIR /home/cirrus
RUN flutter channel beta
RUN flutter upgrade
RUN flutter config --enable-web
