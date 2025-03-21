#!/bin/bash

# Prompt for service name and script path
echo "Enter the name of your systemd service (e.g., mypipeline):"
read SERVICE_NAME

echo "Enter the full path of your Python script (e.g., /home/user/app.py):"
read SCRIPT_PATH
WORKING_DIR=$(dirname "$SCRIPT_PATH")
echo "Root Dir: $WORKING_DIR"

# Validate script path
if [ ! -f "$SCRIPT_PATH" ]; then
    echo "Error: The script path does not exist. Please check and try again."
    exit 1
fi

# Get the Conda environment name
echo "Enter the path of your Conda/Miniconda :"
read CONDA_BASE

echo "Enter the name of your Conda environment:"
read CONDA_ENV

# Find necessary paths
USER_NAME=$(whoami)
SERVICE_FILE="/etc/systemd/system/$SERVICE_NAME.service"

# Ensure the user has sudo privileges
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run with sudo privileges."
    exit 1
fi

# Creating the systemd service file
echo "Creating systemd service file at $SERVICE_FILE..."

cat <<EOF | sudo tee $SERVICE_FILE > /dev/null
[Unit]
Description=$SERVICE_NAME Service
After=network.target

[Service]
User=$USER_NAME
WorkingDirectory=$WORKING_DIR
ExecStart=/bin/bash -c "source $CONDA_BASE/etc/profile.d/conda.sh && conda activate $CONDA_ENV && exec python $SCRIPT_PATH"
Environment="LD_LIBRARY_PATH=\$CONDA_PREFIX/lib:\$LD_LIBRARY_PATH"
Environment="CUDA_HOME=$CONDA_PREFIX"
Restart=always
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

# Set correct permissions for the service file
sudo chmod 644 $SERVICE_FILE

# Reload systemd, enable and start the service
echo "Reloading systemd..."
sudo systemctl daemon-reload

echo "Enabling the service to start on boot..."
sudo systemctl enable "$SERVICE_NAME"

echo "Starting the service..."
sudo systemctl start "$SERVICE_NAME"

echo "Checking service status..."
sudo systemctl status "$SERVICE_NAME" --no-pager
