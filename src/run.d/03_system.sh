#!/bin/sh -e

# Switch default root shell
sed -i 's,/root:/bin/ash,/root:/bin/bash,' /etc/passwd

# Disable VS Code first run notice
config_dir='/root/.config/vscode-dev-containers'
mkdir -p "${config_dir}"
first_run_file='first-run-notice-already-displayed'
touch "${config_dir}/${first_run_file}"

# Set up direnv
cat >>/root/.bashrc <<EOF

"\$(direnv export bash)"
EOF
