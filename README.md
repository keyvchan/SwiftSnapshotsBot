# SwiftSnapshotsBot

Getting notification when the latest swift toolchain was released.

## Installation 

1. Cloen the repo.
```shell
git clone https://github.com/keyvchan/SwiftSnapshotsBot
```

2. Build it and install binary using `init.sh`.
```shell
cd SwiftSnapshotsBot
bash ./Scripts/init.sh
```

3. Set the environment variable `SWIFT_SNAPSHOTS_BOT_TOKEN` to your API key.
```shell
systemctl edit SwiftSnapshotsBot
```
The content should be like down below, make sure change `YOUR_TOKEN` to your own.
```toml
[Service]
Environment="SWIFT_SNAPSHOTS_BOT_API_TOKEN=YOUR_TOKEN"
```

4. Start bot using systemd
```shell
# start the bot on boot(optional)
# systemctl enable SwiftSnapshotsBot

# start the bot
systemctl start Swift
```
