# 🚀 Web4application Cycript (Modernized)

A powerful, ES6-enabled fork of Cycript designed for modern **iOS (Rootless)** and **Android (ART)**.
```python
def card_3d_demo():
    """This is a standalone isolated Python component.
    Behavior and styling is scoped to the component."""
    def card_3d(text, background, amt, left_align):
        # JS and CSS can be defined inline or in a file
        scr = ScriptX('card3d.js', amt=amt)
        align='left' if left_align else 'right'
        sty = StyleX('card3d.css', background=f'url({background})', align=align)
        return Div(text, Div(), sty, scr)
    # Design credit: https://codepen.io/markmiro/pen/wbqMPa
    card = card_3d("Mouseover me", bgurl, amt=1.5, left_align=True)
    return Div(card, style=cardcss
    ```
```
## 🛠 Installation

### iOS (Sileo/Zebra)
1. Add repo: `https://web4application.github.io`
2. Install **Cycript (Modernized)**.

### Android (Terminal)
```bash
adb push ./libcycript.so /data/local/tmp/
adb shell chmod +x /data/local/tmp/cycript
pip install -r requirements.
```
```bash
# Inject into a process
cycript -p [PID]
python main.py
# Use modern JS
cy# const app = [UIApp keyWindow];
cy# await someAsyncLogic();
npm install -g vercel
vercel --prod
