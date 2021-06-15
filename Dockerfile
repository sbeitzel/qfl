FROM cirrusci/flutter:latest

# Note that some of this stuff is cribbed from https://github.com/flutter/plugins/blob/master/.ci/Dockerfile
# This is so that, when necessary, we can build Flutter plugins.

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
    "extras;android;m2repository"

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

# 2021-06-15: the base image seems to have a flutter that can't be modified;
# updating doesn't work, nor does setting the channel, nor upgrading.

# Update Flutter so we can do web builds
WORKDIR ${HOME}
#RUN flutter channel beta
#RUN flutter upgrade
RUN flutter config --enable-web

# Sometimes, CirrusCI runs things as user 'root' and sometimes as user 'cirrus'.
# As of 20210614, no currus user is created, and everything runs as root.
# This makes Flutter cranky, so we'll create a cirrus user now.
#RUN sudo useradd -m -r -U cirrus

#RUN mkdir -p /home/cirrus/.config/configstore
#RUN chown -R cirrus:cirrus /home/cirrus/.config
#RUN chown -R cirrus:cirrus /sdks/flutter

#USER cirrus

