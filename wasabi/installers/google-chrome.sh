#!/bin/bash -e
################################################################################
##  File:  google-chrome.sh
##  Desc:  Installs google-chrome, chromedriver and chromium
################################################################################

download_with_retries() {
# Due to restrictions of bash functions, positional arguments are used here.
# In case if you using latest argument NAME, you should also set value to all previous parameters.
# Example: download_with_retries $ANDROID_SDK_URL "." "android_sdk.zip"
    local URL="$1"
    local DEST="${2:-.}"
    local NAME="${3:-${URL##*/}}"
    local COMPRESSED="$4"

    if [[ $COMPRESSED == "compressed" ]]; then
        local COMMAND="curl $URL -4 -sL --compressed -o '$DEST/$NAME' -w '%{http_code}'"
    else
        local COMMAND="curl $URL -4 -sL -o '$DEST/$NAME' -w '%{http_code}'"
    fi

    echo "Downloading '$URL' to '${DEST}/${NAME}'..."
    retries=20
    interval=30
    while [ $retries -gt 0 ]; do
        ((retries--))
        # Temporary disable exit on error to retry on non-zero exit code
        set +e
        http_code=$(eval $COMMAND)
        exit_code=$?
        if [ $http_code -eq 200 ] && [ $exit_code -eq 0 ]; then
            echo "Download completed"
            return 0
        else
            echo "Error — Either HTTP response code for '$URL' is wrong - '$http_code' or exit code is not 0 - '$exit_code'. Waiting $interval seconds before the next attempt, $retries attempts left"
            sleep 30
        fi
        # Enable exit on error back
        set -e
    done

    echo "Could not download $URL"
    return 1
}

# Download and install Google Chrome
CHROME_DEB_URL="https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
CHROME_DEB_NAME="google-chrome-stable_current_amd64.deb"
download_with_retries $CHROME_DEB_URL "/tmp" "${CHROME_DEB_NAME}"
sudo apt install "/tmp/${CHROME_DEB_NAME}" -f

CHROME_VERSION=$(google-chrome --product-version)
CHROME_VERSION=${CHROME_VERSION%.*}

# Determine latest release of chromedriver
# Compatibility of Google Chrome and Chromedriver: https://sites.google.com/a/chromium.org/chromedriver/downloads/version-selection
LATEST_CHROMEDRIVER_VERSION=$(curl "https://chromedriver.storage.googleapis.com/LATEST_RELEASE_$CHROME_VERSION")

# Download and unpack latest release of chromedriver
echo "Downloading chromedriver v$LATEST_CHROMEDRIVER_VERSION..."
wget "https://chromedriver.storage.googleapis.com/$LATEST_CHROMEDRIVER_VERSION/chromedriver_linux64.zip"
unzip chromedriver_linux64.zip
rm chromedriver_linux64.zip

CHROMEDRIVER_DIR="/usr/local/share/chrome_driver"
CHROMEDRIVER_BIN="$CHROMEDRIVER_DIR/chromedriver"

sudo rm -rf $CHROMEDRIVER_DIR/*
sudo rm -rf $CHROMEDRIVER_BIN/*

sudo mkdir -p $CHROMEDRIVER_DIR
sudo mv "chromedriver" $CHROMEDRIVER_BIN
sudo chmod +x $CHROMEDRIVER_BIN
chromedriver --version