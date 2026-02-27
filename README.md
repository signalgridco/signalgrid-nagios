# Signalgrid Nagios / Icinga Plugin

This script bridges Nagios & Icinga monitoring alerts to the
**Signalgrid** push notification API.\
It automatically maps Nagios states (OK, Warning, Critical) to
Signalgrid notification types.

------------------------------------------------------------------------

## Prerequisites

-   **curl**: Required to send the API requests.
-   **Permissions**: The script must be executable by the `nagios` or
    `icinga` user.

------------------------------------------------------------------------

## Installation

1.  Save the script to your server (e.g.,
    `/usr/local/bin/signalgrid-notify.sh`).
2.  Make it executable:

``` bash
chmod +x /usr/local/bin/signalgrid-notify.sh
```

3.  Edit the script and insert your credentials:

``` bash
CLIENT_KEY="[your-client-key]"
CHANNEL_TOKEN="[your-channel-token]"
```

------------------------------------------------------------------------

## Usage

The script accepts four positional arguments:

  -----------------------------------------------------------------------
  Argument           Description           Mapping / Values
  ------------------ --------------------- ------------------------------
  \$1                **Title**             The headline of the
                                           notification.

  \$2                **Body**              The detailed message or plugin
                                           output.

  \$3                **State**             `OK`, `UP`, `WARNING`,
                                           `CRITICAL`, or `DOWN`.

  \$4                **Critical Flag**     `true` to force high-priority,
                                           otherwise `false`.
  -----------------------------------------------------------------------

------------------------------------------------------------------------

# Nagios Configuration

## 1. Define Notification Commands

``` nagios
define command {
    command_name    notify-service-signalgrid
    command_line    /usr/local/bin/signalgrid-notify.sh "$SERVICEDESC$ on $HOSTNAME$ is $SERVICESTATE$" "$SERVICEOUTPUT$" "$SERVICESTATE$" "false"
}

define command {
    command_name    notify-host-signalgrid
    command_line    /usr/local/bin/signalgrid-notify.sh "Host $HOSTNAME$ is $HOSTSTATE$" "$HOSTOUTPUT$" "$HOSTSTATE$" "false"
}
```

## 2. Assign to Contact

``` nagios
define contact {
    contact_name                    your_user
    alias                           Your User
    service_notification_commands   notify-service-signalgrid
    host_notification_commands      notify-host-signalgrid
}
```

------------------------------------------------------------------------

# Icinga 2 Configuration

## 1. Define the NotificationCommand

``` icinga2
object NotificationCommand "signalgrid-notify" {
  command = [ "/usr/local/bin/signalgrid-notify.sh" ]

  arguments = {
    0 = {
      value = service ?
        service.name + " on " + host.name + " is " + service.state :
        "Host " + host.name + " is " + host.state
    }
    1 = {
      value = service ? service.output : host.output
    }
    2 = {
      value = service ? service.state : host.state
    }
    3 = {
      value = (service && service.state == "Critical") ||
              (!service && host.state == "Down") ?
              "true" : "false"
    }
  }
}
```

## 2. Apply Service Notifications

``` icinga2
apply Notification "signalgrid-service" to Service {
  command = "signalgrid-notify"

  states = [ OK, Warning, Critical, Unknown ]
  types  = [ Problem, Recovery ]

  users = [ "icingaadmin" ]

  assign where host.vars.enable_signalgrid == true
}
```

## 3. Apply Host Notifications

``` icinga2
apply Notification "signalgrid-host" to Host {
  command = "signalgrid-notify"

  states = [ Up, Down ]
  types  = [ Problem, Recovery ]

  users = [ "icingaadmin" ]

  assign where host.vars.enable_signalgrid == true
}
```

Enable per host:

``` icinga2
object Host "my-server" {
  import "generic-host"
  address = "192.168.1.10"

  vars.enable_signalgrid = true
}
```

------------------------------------------------------------------------

# Manual Testing

Verify the integration directly from the CLI:

``` bash
/usr/local/bin/signalgrid-notify.sh "Test Alert" "Manual test from terminal" "CRITICAL" "false"
```
