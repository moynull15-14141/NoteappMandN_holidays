=====================================
   NoteApp - LAN Digital Diary
=====================================

VERSION: 1.0.2

=====================================
SETUP & INSTALLATION
=====================================

1. REQUIREMENTS:
   - Windows 10 or later
   - Node.js 16+ (Download from https://nodejs.org/)

2. QUICK START:

   SERVER PC:
   ─────────
   1. Double-click: start_server.bat
   2. You'll see "Server started on port 4000"
   3. Keep this window open (in background if you want)

   CLIENT PC (or same PC):
   ──────────────────────
   1. Double-click: noteapp.exe
   2. Open Settings > LAN Chat > Manual Configuration
   3. Enter Server Address: [Your Server IP]
       (e.g., 192.168.0.151)
   4. Port: 4000 (default)
   5. Save and go to Chat tab
   6. You should see "Connected" status

3. FINDING YOUR SERVER IP:

   On the SERVER PC, open Command Prompt and type:
   
   ipconfig
   
   Look for "IPv4 Address" under your network adapter
   (usually starts with 192.168.x.x)

4. MULTIPLE DEVICES:

   - Each Client PC can run noteapp.exe
   - All can connect to the same server
   - Real-time chat across the entire network

=====================================
TROUBLESHOOTING
=====================================

Q: Server won't start
A: 1. Make sure Node.js is installed
   2. Try running start_server.bat as Administrator
   3. Check if port 4000 is available

Q: App connects but can't find server
A: 1. Verify server IP is correct (ipconfig)
   2. Check firewall - allow port 4000
   3. Make sure both are on same network

Q: "Cannot find module" error
A: 1. Re-extract all files from the zip
   2. Don't modify server folder
   3. Reinstall if corrupted

=====================================
FILE STRUCTURE
=====================================

noteapp_portable/
├── noteapp.exe           (Flutter client app)
├── start_server.bat      (Server launcher)
├── README.txt            (This file)
└── server/
    ├── index.js          (Server code)
    ├── package.json      (Dependencies)
    └── node_modules/     (Packages - auto created)

=====================================
FEATURES
=====================================

✓ Real-time LAN chat
✓ Typing indicators
✓ Online user presence
✓ Persistent messages
✓ Dark/Light theme
✓ PIN protection
✓ Auto-update checking
✓ Digital diary with encryption

=====================================
SUPPORT & MORE INFO
=====================================

GitHub: https://github.com/moynull15-14141/NoteappMandN_holidays
Issues: Report bugs on GitHub

=====================================
