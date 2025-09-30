# Al-Rahma Mobile ERP app

## Overview
A custom mobile application built for **Al-Rahma Company**, specialized in **Aluminum (Alumetal) & UPVC windows and doors** work.  
The app helps craftsmen and managers organize their workflow digitally instead of manual paperwork.  

It provides tools for managing:
- Clients
- Projects
- Painting work
- Payments

---

## Key Features
- 🗂️ **Clients & Projects Management** – add, track, and update projects easily.  
- 🎨 **Drawing Tool (Main Feature):** allows craftsmen to sketch, annotate, and save project-related drawings.  
  - Save drawings as images  
  - Export/share as PDF  
- 💳 **Payments Tracking** with project-based history.  
- ⏳ **Free Trial System:**  
  - Free for 2 weeks, then locks until payment is made.  
  - Implemented using **Supabase** (with `flutter_dotenv` for environment configuration).  
- 💾 **Local Storage:**  
  - Built on **Hive** with an abstraction layer (`AppPreference`) to support future DB migration easily.  
- ⚡ **State Management:**  
  - Entirely developed with **Cubit (Flutter Bloc)**.  
- 📱 **Responsive UI:**  
  - Implemented using **MediaQuery** + **Flutter ScreenUtil** for smooth scaling across devices.  
- 📤 **File Sharing:**  
  - Export and share project drawings as PDF files.  

---

## Tech Stack
- **Framework:** Flutter  
- **State Management:** Cubit (Bloc)  
- **Local Database:** Hive (with abstraction)  
- **Cloud Backend:** Supabase (for free trial & auth logic)  
- **Environment Handling:** flutter_dotenv  
- **UI Responsiveness:** MediaQuery + Flutter ScreenUtil  

---

## Demo
📹 Watch the 5-minute demo video here:  
👉 [Demo Video on Google Drive](your-drive-link-here)

*(Screenshots and a full screen-by-screen documentation will be added soon.)*

---
License

This project is a private business app for Al-Rahma Company.
Not intended for public commercial use.



---

## ☕ Support the Project

If you find **Flutter Gradle Doctor** useful and want to support its development, you can buy me a coffee:

[![Buy Me a Coffee](https://img.shields.io/badge/Buy%20Me%20a%20Coffee-FF813F?style=for-the-badge&logo=buy-me-a-coffee&logoColor=white)](https://www.buymeacoffee.com/Mohamed_Fawzy)



