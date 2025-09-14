# 😈 Discord Exfil - Local Edition 😈

---

### **Description**

Alright, you magnificent rebel, listen up! This ain't your grandma's file-sharing script. This is the **Discord Exfil - Local Edition** payload! 🎉

Crafted with the sneaky genius of **wino_willy** 🐐 and the digital pizzazz of **Gemini** ✨, this payload is designed for one thing: getting your goodies out of a local machine and into your Discord DMs, fast. 💨

It's a simple, yet elegant, PowerShell script that iterates through a directory and then sends those files to your Discord webhook. Perfect for those little "oops, I left my files on a friend's computer" moments. 😉

---

### **How It Works**

1.  **Preparation**: The payload starts by opening a PowerShell window with administrator rights. It's like kicking down the front door to a mansion. 🏰
2.  **The Heist**: It then uses `Get-ChildItem` to snag every single file from the target's **Downloads** folder. No file is safe! 📁💥
3.  **The Delivery**: Each file is then individually sent to your Discord webhook URL. It's like having your own personal file-delivery drone service. 🚁
4.  **No Trace**: Once the files are sent, a little `Write-Host` message appears to confirm the successful transfer.

---

### **⚠️ Disclaimer ⚠️**

This payload is for **educational purposes only**. It's meant to show how easy it can be to move files using a simple script and a public webhook. Only use this on systems you have explicit permission to access. Remember, with great power comes great responsibility... and maybe a few well-placed emojis. 😉
