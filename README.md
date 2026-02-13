# Signalgrid Nagios Notification Plugin

This script bridges Nagios monitoring alerts to the **Signalgrid** push notification API. It automatically maps Nagios states (OK, Warning, Critical) to Signalgrid notification types.

---

## Prerequisites
* **curl**: Required to send the API requests.
* **Permissions**: The script must be executable by the `nagios` user.

## Installation
1. Save the script to your Nagios server (e.g., `/usr/local/bin/signalgrid-notify.sh`).
2. Make it executable:
   ```bash
   chmod +x /usr/local/bin/signalgrid-notify.sh
   ```
3. Edit the script and insert your credentials:
   ```bash
   CLIENT_KEY="[your-client-key]"
   CHANNEL_TOKEN="[your-channel-token]"
   ```

---

## Usage
The script accepts four positional arguments:

| Argument | Description | Mapping / Values |
| :--- | :--- | :--- |
| \$1 | **Title** | The headline of the notification. |
| \$2 | **Body** | The detailed message or plugin output. |
| \$3 | **State** | \`OK\`, \`UP\`, \`WARNING\`, \`CRITICAL\`, or \`DOWN\`. |
| \$4 | **Critical Flag** | \`true\` to force high-priority, otherwise \`false\`. |

---

## Nagios Configuration

To automate notifications, define the commands in your Nagios configuration files (typically \`commands.cfg\`).

### 1. Define Notification Commands
```nagios
# Service Notification
define command {
    command_name    notify-service-by-signalgrid
    command_line    /usr/local/bin/signalgrid-notify.sh "\$SERVICEDESC\$ on \$HOSTNAME\$ is \$SERVICESTATE\$" "\$SERVICEOUTPUT\$" "\$SERVICESTATE\$" "false"
}

# Host Notification
define command {
    command_name    notify-host-by-signalgrid
    command_line    /usr/local/bin/signalgrid-notify.sh "Host \$HOSTNAME\$ is \$HOSTSTATE\$" "\$HOSTOUTPUT\$" "\$HOSTSTATE\$" "true"
}
```

### 2. Assign to Contact
Add these commands to your contact definition in \`contacts.cfg\`:

```nagios
define contact {
    contact_name                    signalgrid_admin
    alias                           Signalgrid Admin
    service_notification_commands   notify-service-by-signalgrid
    host_notification_commands      notify-host-by-signalgrid
}
```

---

## Manual Testing
Verify the integration directly from the CLI:
```bash
/usr/local/bin/signalgrid-notify.sh "Test Alert" "Manual test from terminal" "CRITICAL" "false"
```
