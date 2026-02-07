# Claude Code Notifications Setup Guide

Get notified on your Mac and iPhone when Claude Code commands finish, even during Focus modes.

## Step 1: Test Basic Notification

Run this command to verify notifications work:

```bash
osascript -e 'display notification "Test message" with title "Test Title" sound name "Glass"'
```

You should see a notification appear on your Mac.

## Step 2: Set Up the Alias

Add this function to your `~/.zshrc` file:

```bash
clauden() {
    claude "$@" && osascript -e 'display notification "Claude Code task finished" with title "Task Complete" sound name "Glass"'
}
```

### How to add it:

1. Open your zsh config file:
   ```bash
   nano ~/.zshrc
   ```

2. Scroll to the bottom and paste the function above

3. Save and exit (Ctrl+O, Enter, Ctrl+X)

4. Reload your shell:
   ```bash
   source ~/.zshrc
   ```

## Step 3: Configure Mac Notification Settings

### Enable Script Editor notifications:

1. Open **System Settings**
2. Click **Notifications**
3. Scroll down to find **Script Editor**
4. Click on Script Editor
5. Toggle on **"Allow Time Sensitive Notifications"**

### Configure Focus mode settings:

1. In System Settings, go to **Focus**
2. For each Focus mode you use (Do Not Disturb, Work, Sleep, etc.):
   - Click on the Focus mode
   - Under "Allowed Notifications" click **Apps**
   - Find and enable **Script Editor**
   - Click **Done**

## Step 4: Configure iPhone Settings

### Enable notifications from your Mac:

1. Open **Settings** on your iPhone
2. Go to **Focus**
3. Select each Focus mode you use
4. Tap **Apps** under "Allowed Notifications"
5. Add any apps that relay macOS notifications
6. Or toggle on **"Time Sensitive Notifications"** to allow all time-sensitive alerts

### Verify Continuity is enabled:

1. Settings > General > AirPlay & Handoff
2. Ensure **Handoff** is enabled
3. Verify you're signed into the same iCloud account on both devices

## Step 5: Test It Out

Run a Claude Code command with your new alias:

```bash
clauden "create a simple hello world function"
```

You should receive a notification on both your Mac and iPhone when the command completes.

## Usage

Instead of running:
```bash
claude "your task here"
```

Run:
```bash
clauden "your task here"
```

The `n` suffix stands for "notify" - you can still use the regular `claude` command when you don't want notifications.

## Troubleshooting

**Notifications not showing up on iPhone:**
- Check that both devices are on the same WiFi network or have Bluetooth enabled
- Verify iCloud sync is working
- Restart both devices

**Notifications not breaking through Focus:**
- Double-check that Script Editor is in the allowed apps list for each Focus mode
- Ensure "Time Sensitive Notifications" is enabled for Script Editor

**Command not found error:**
- Make sure you ran `source ~/.zshrc` after adding the function
- Try opening a new terminal window
