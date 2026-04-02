## Supported tags

* [`latest` (*Dockerfile*)](https://github.com/soulofsorrow/docker-smtp/blob/master/Dockerfile)

## Quick reference

This image allows containers to send outgoing email via Exim4. It can relay
mail through a smarthost (e.g. Gmail, SendGrid) or send directly to recipients.
It also accepts incoming SMTP connections from your local network.

* **Image:** `ghcr.io/soulofsorrow/docker-smtp:latest`
* **Code repository:** https://github.com/soulofsorrow/docker-smtp
* **Where to file issues:** https://github.com/soulofsorrow/docker-smtp/issues

## Usage

### Basic SMTP server

Containers can connect to hostname `mail` on port `25` to send outgoing email.
Mail is sent directly to recipients without a smarthost.

```yaml
services:
  mail:
    image: ghcr.io/soulofsorrow/docker-smtp:latest
    restart: always
```

### SMTP smarthost (e.g. Gmail)

Mail is relayed through an external SMTP server. For Gmail, use an
[App Password](https://myaccount.google.com/apppasswords) — not your regular
account password.

```yaml
services:
  mail:
    image: ghcr.io/soulofsorrow/docker-smtp:latest
    restart: always
    ports:
      - "192.168.178.39:25:25"
    environment:
      MAILNAME: mail.domain.tld
      RELAY_HOST: smtp.gmail.com
      RELAY_PORT: 587
      RELAY_USERNAME: user@gmail.com
      RELAY_PASSWORD: your-app-password
      LOCAL_INTERFACES: "127.0.0.1;::1;192.168.178.39"
      RELAY_NETS: "192.168.178.0/24"
      HIDE_MAILNAME: "false"
      LOCAL_DELIVERY: maildir_home
```

## Environment variables

All environment variables are optional.

| Variable | Default | Description |
|---|---|---|
| `MAILNAME` | hostname | Sets Exim's `primary_hostname`. |
| `RELAY_HOST` | — | Remote SMTP server to relay outgoing mail through. |
| `RELAY_PORT` | `25` | Port of the remote SMTP server. |
| `RELAY_USERNAME` | — | Username for authenticating with the smarthost. |
| `RELAY_PASSWORD` | — | Password for authenticating with the smarthost. |
| `RELAY_NETS` | `10.0.0.0/8;172.16.0.0/12;192.168.0.0/16` | Networks allowed to use the smarthost, separated by semicolons. |
| `LOCAL_INTERFACES` | `` (all) | IP addresses Exim listens on for incoming SMTP connections, separated by semicolons. |
| `OTHER_HOSTNAMES` | — | Additional domains for which Exim accepts mail. |
| `RELAY_DOMAINS` | — | Domains for which Exim relays mail. |
| `HIDE_MAILNAME` | `true` | Whether to hide the local mailname in outgoing mail (`true`/`false`). |
| `LOCAL_DELIVERY` | `mail_spool` | Local delivery method: `mail_spool`, `maildir_home`, or `maildir_directory`. |

> **Note:** If you set `RELAY_HOST`, you should also set `RELAY_PORT`,
> `RELAY_USERNAME`, and `RELAY_PASSWORD`, otherwise authentication will likely fail.
