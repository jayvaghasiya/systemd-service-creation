# Systemd Service Setup for Python Scripts using Conda

This guide explains how to create a **systemd service** for running a Python script inside a **Conda environment** on Linux.

## Prerequisites

Ensure you have:
- A **Python script** that you want to run as a service.
- **Conda or Miniconda** installed on your system.
- **sudo privileges** to create systemd services.

## Step 1: Prepare Your Script

Identify the full path of the Python script you want to run as a service.
```sh
# Example script path
/home/user/app.py
```

## Step 2: Run the Setup Script

Execute the provided script to create the systemd service.

```sh
sudo bash setup_service.sh
```

The script will prompt you for the following details:
1. **Service Name** (e.g., `mypipeline`)
2. **Full Path to Python Script** (e.g., `/home/user/app.py`)
3. **Conda/Miniconda Path** (e.g., `/home/user/miniconda3`)
4. **Conda Environment Name** (e.g., `myenv`)

## Step 3: Verify the Service

Once the script completes, check the service status:
```sh
sudo systemctl status <service_name>
```
Example:
```sh
sudo systemctl status mypipeline
```

If the service is running, you should see output confirming that your Python script is active.

## Manual Commands (For Advanced Users)

If you prefer to manually set up the service, follow these steps:

### 1️⃣ Create the Service File
Create a new systemd service file:
```sh
sudo nano /etc/systemd/system/<service_name>.service
```
Example:
```sh
sudo nano /etc/systemd/system/mypipeline.service
```

### 2️⃣ Add the Following Configuration
Paste the following into the file (update placeholders accordingly):
```ini
[Unit]
Description=My Python Service
After=network.target

[Service]
User=<your_username>
WorkingDirectory=<script_directory>
ExecStart=/bin/bash -c "source <conda_path>/etc/profile.d/conda.sh && conda activate <conda_env> && exec python <script_path>"
Environment="LD_LIBRARY_PATH=$CONDA_PREFIX/lib:$LD_LIBRARY_PATH"
Environment="CUDA_HOME=$CONDA_PREFIX"
Restart=always
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
```

Replace:
- `<your_username>` → Output of `whoami`
- `<script_directory>` → Folder where your script is located
- `<conda_path>` → Path to Conda installation
- `<conda_env>` → Name of the Conda environment
- `<script_path>` → Full path to the Python script

### 3️⃣ Reload Systemd and Start the Service
```sh
sudo systemctl daemon-reload
sudo systemctl enable <service_name>
sudo systemctl start <service_name>
```

### 4️⃣ Check Logs
```sh
journalctl -u <service_name> -f
```

## Stopping and Removing the Service
If you need to stop or remove the service:

```sh
# Stop the service
sudo systemctl stop <service_name>

# Disable the service from auto-starting
sudo systemctl disable <service_name>

# Delete the service file
sudo rm /etc/systemd/system/<service_name>.service

# Reload systemd
sudo systemctl daemon-reload
```

## Troubleshooting
If the service fails to start:
- Check the logs using:
  ```sh
  journalctl -u <service_name> -f
  ```
- Ensure the **Conda path and environment name** are correct.
- Run the script manually inside the Conda environment to debug:
  ```sh
  conda activate <conda_env>
  python <script_path>
  ```

## Conclusion
You now have a **persistent systemd service** running your Python script inside a Conda environment! 🚀

