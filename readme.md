# 🚀 Web4application Cycript (Modernized)

A powerful, ES6-enabled fork of Cycript designed for modern **iOS (Rootless)** and **Android (ART)**.

## 🛠 Installation

### iOS (Sileo/Zebra)
1. Add repo: `https://web4application.github.io`
2. Install **Cycript (Modernized)**.

### Android (Terminal)
```bash
adb push ./libcycript.so /data/local/tmp/
adb shell chmod +x /data/local/tmp/cycript
```
```bash
# Inject into a process
cycript -p [PID]

# Use modern JS
cy# const app = [UIApp keyWindow];
cy# await someAsyncLogic();
