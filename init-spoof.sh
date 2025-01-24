#!/bin/sh

# Define the URL for the SpoofDPI ARM64 version
SPOOF_DPI_URL="https://github.com/xvzc/SpoofDPI/releases/download/v0.12.0/spoofdpi-linux-arm64.tar.gz"

# Define the temporary download location
TEMP_DIR="/tmp/spoofdpi"
TAR_FILE="$TEMP_DIR/spoofdpi-arm64.tar.gz"

# Create the temporary directory
mkdir -p $TEMP_DIR

# Download the SpoofDPI tarball
echo "Downloading SpoofDPI..."
wget -O $TAR_FILE $SPOOF_DPI_URL

# Extract the tarball
echo "Extracting SpoofDPI..."
tar -xzf $TAR_FILE -C $TEMP_DIR

# Move the SpoofDPI binary to /usr/bin
echo "Installing SpoofDPI..."
mv $TEMP_DIR/spoofdpi /usr/bin/spoofdpi

# Clean up
echo "Cleaning up..."
rm -rf $TEMP_DIR

echo "SpoofDPI installation completed."
