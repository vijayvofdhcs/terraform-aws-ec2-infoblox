#!/usr/bin/env bash

set -eu

apt-get -y update
apt-get install -y unzip

# download and install cloud agent
echo "[INFO] Downloading and installing cloud agent."
wget "https://releases.hashicorp.com/tfc-agent/${tfc_agent_version}/tfc-agent_${tfc_agent_version}_linux_amd64.zip"
unzip "tfc-agent_${tfc_agent_version}_linux_amd64.zip"
mv tfc-agent tfc-agent-core /usr/bin

# create systemd service unit 
echo "[INFO] Creating systemd service unit file."
cat - <<EOF > /etc/systemd/system/tfc-agent@.service
[Unit]
Description="Terraform Cloud Agent #%i"
PartOf=tfc-agents.target

[Service]
Type=simple
ExecStart=/usr/bin/tfc-agent \
  -name agent-%i \
  -token ${tfc_agent_token}
EOF

for ((i=1; i<=${number_of_agents}; i++)); 
do 
  tfc_agent_services+="tfc-agent@$i.service "
done

# create systemd target unit
echo "[INFO] Creating systemd target unit file."
cat - <<EOF > /etc/systemd/system/tfc-agents.target
[Unit]
Description="Terraform Cloud Agents"
After=network-online.target
Wants=$tfc_agent_services

[Install]
WantedBy=network-online.target
EOF

echo "[INFO] Starting tfc-agents service."
systemctl daemon-reload
systemctl enable --now tfc-agents.target

echo "[INFO] user_data script finished successfully!"