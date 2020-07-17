#! /bin/bash

swift build
sudo cp .build/debug/SwiftSnapshotsBot /usr/local/bin
sudo cp Scripts/SwiftSnapshotsBot.service /usr/lib/systemd/system
