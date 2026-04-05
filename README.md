## WARNING
This project was done to test my knowledge about bash, if you face issues using the tool open an issue (i may or may not fix it, depends how much free time ill have to do this)

# ztools 🪟

A lightweight Bash toolkit for creating **Zenity GUI dialogs** from the terminal.  
Built around a shared core library, with tools for local prompts and sending dialogs to a friend's screen over SSH.

---

## Tools

| Tool | Stands for | What it does |
|------|-----------|--------------|
| `zques_lib.sh` | **Z**enity core lib | Shared library sourced by all tools |
| `zques` | **Z**enity **ques**tion | Show GUI dialogs from your terminal |
| `zmsgh` | **Z**enity **msg** over **SSH** | Send a dialog to a friend's screen over SSH |

---

## Requirements

- `bash` 4+
- `zenity`
- `ssh` + [Tailscale](https://tailscale.com) (for `zmsgh`)

```bash
# Install zenity
sudo apt install zenity      # Debian/Ubuntu
sudo dnf install zenity      # Fedora/RHEL
```

---

## Install

```bash
# Clone the repo
git clone https://github.com/DevCrystalGrey/ztools.git
cd ztools

# Run the installer
chmod +x install.sh
sudo ./install.sh
```

Or manually:

```bash
sudo cp libs/zques_lib.sh /usr/local/lib/zques_lib.sh
sudo cp tools/zques.sh    /usr/local/bin/zques  && sudo chmod +x /usr/local/bin/zques
sudo cp tools/zmsgh.sh    /usr/local/bin/zmsgh  && sudo chmod +x /usr/local/bin/zmsgh
```

## Uninstall

```bash
sudo ./install.sh uninstall
```

Or manually:

```bash
sudo rm -f /usr/local/lib/zques_lib.sh
sudo rm -f /usr/local/bin/zques
sudo rm -f /usr/local/bin/zmsgh
```

> **Note:** For `zmsgh` to work, your friend also needs `zques_lib.sh` installed at `/usr/local/lib/zques_lib.sh` and `zenity` installed on their machine.

---

## zques

Show a Zenity dialog from the terminal.

```
zques <title> <type> <text> [options...]
```

### Dialog types

**Simple — no extra options needed:**

| Type | Description |
|------|-------------|
| `info` | Informational message |
| `warning` | Warning message |
| `error` | Error message |
| `question` | Yes / No prompt |
| `entry` | Free-text input |
| `progress` | Progress bar |
| `calendar` | Date picker |
| `color` | Color picker |

**With options:**

| Type | Usage |
|------|-------|
| `list` | `zques <title> list <text> opt1 opt2 ...` |
| `checklist` | `zques <title> checklist <text> opt1 opt2 ...` |
| `radiolist` | `zques <title> radiolist <text> opt1 opt2 ...` |
| `combo` | `zques <title> combo <text> opt1 opt2 ...` |
| `scale` | `zques <title> scale <text> <min> <max> [step] [default]` |

### Examples

```bash
zques "Alert"   info      "Everything is fine."
zques "Confirm" question  "Delete this file?"
zques "Input"   entry     "Enter your username:"
zques "Pick"    list      "Choose a fruit:" Apple Banana Cherry
zques "Tags"    checklist "Select toppings:" Cheese Bacon Mushrooms
zques "Size"    radiolist "Pick a size:" Small Medium Large
zques "Volume"  scale     "Set volume:" 0 100 1 50
zques "Date"    calendar  "Pick a date:"
```

### Output

Every dialog prints what the user did:

```
The user selected: Yes
The user selected: Banana
The user selected: Cheese, Mushrooms
The user selected: Dismissed (×)
```

Capture it in a script:

```bash
NAME=$(zques "Setup" entry "Enter your name:")
# $NAME holds whatever they typed, terminal stays clean
```

---

## zmsgh

Send a Zenity dialog to a friend's screen over SSH, and see their response back in your terminal.  
Automatically detects the remote display — no manual `DISPLAY` setup needed.

```
zmsgh <host> <type> <text> [options...]
```

### Examples

```bash
zmsgh duck@pcduck info     "WAKE UP I WANNA PLAY WITH YOU"
zmsgh duck@pcduck question "Wanna play Minecraft?"
zmsgh duck@pcduck list     "Which game?" Minecraft Terraria "Deep Rock Galactic"
zmsgh duck@pcduck entry    "What time works for you?"
zmsgh duck@pcduck scale    "Rate your mood:" 1 10 1 5
```

### Output

```
→ Poking duck@pcduck...
← duck@pcduck says: Deep Rock Galactic
```

---

## License

MIT
