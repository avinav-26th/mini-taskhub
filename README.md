# 📝 Mini TaskHub Pro - Flutter Assignment

> **Status:** Completed ✅ | **Role:** Flutter Developer Assignment

**Mini TaskHub Pro** is a feature-rich, personal task tracking application built with **Flutter** and **Supabase**. It goes beyond the basic requirements, implementing advanced features like **AI Coaching**, **Pomodoro Timer**, **Smart Analytics**, and a **Reactive UI** with optimistic updates.

---

## 📱 App Preview & Demo

| Dashboard | Task Details | Analytics |
|:---:|:---:|:---:|

| <img src="https://github.com/user-attachments/assets/ef280d2a-cd08-4dd6-9a87-e820d30b6dbc" width="200"/> | <img src="https://github.com/user-attachments/assets/49b3e2eb-bd99-4cb0-8a15-9e37312de1af" width="200"/> | <img src="https://github.com/user-attachments/assets/d60d75e1-7407-4815-8256-8ad574345844" width="200"/> |

📺 **[Watch the Walkthrough Video Here](https://drive.google.com/file/d/1L16krikKgZI56TLilt_NA4J_MnCFcI0l/view?usp=drive_link)** 📥 **[Download the APK Here](https://github.com/avinav-26th/mini-taskhub/releases/tag/v1.0.0)**

---

## ✅ Features Implemented

### 🎯 Core Requirements (Completed)
- **Authentication:** robust Email/Password Sign Up & Login via **Supabase Auth**.
- **Task Management:** Create, Read, Update, and Delete (CRUD) tasks.
- **Responsive UI:** Matches the provided Figma aesthetic (Minimalist Teal/Dark theme).
- **State Management:** Used **Riverpod 2.0** (StateNotifier) for scalable, testable state.

### 🚀 "Pro" Features (Bonus)
- **🧠 AI Assistant (Groq/Llama 3):**
    - **Smart Split:** Automatically breaks down complex tasks into subtasks.
    - **Coach:** Provides motivation and actionable advice for tasks.
- **🍅 Pomodoro Focus Timer:** Integrated timer with customizable durations (15/25/50 mins) to boost productivity.
- **📊 Smart Analytics:** Visual charts (Pie & Bar) showing completion rates and category distribution.
- **🎨 Theming:** Full **Dark/Light Mode** toggle with persistent settings.
- **📂 Categories:** Color-coded categories (Work, Personal, etc.) with management capabilities.
- **📅 Calendar View:** Monthly calendar integration to visualize deadlines.
- **🗑️ Trash Bin:** Soft delete functionality with "Restore" and "Delete Forever" options.
- **⚡ Reactive UI:** Optimistic updates ensure the app feels instant (0ms delay) even on slow networks.

---

## 🛠️ Tech Stack

* **Framework:** Flutter (3.x)
* **Language:** Dart
* **Backend:** Supabase (PostgreSQL + Auth)
* **State Management:** Flutter Riverpod
* **AI Engine:** Groq API (Llama 3 / Mixtral)
* **Local Storage:** Shared Preferences (Theme settings)
* **Charts:** fl_chart
* **Navigation:** GoRouter

---

## 📂 Project Structure & Architecture

The project follows a **Feature-First / Clean Architecture** approach. While the assignment suggested a flat structure, I chose this modular approach to demonstrate scalability and professional coding standards.

```text
lib/
├── app/                 # Global app configuration (Constants, Router, Theme)
├── core/                # Shared utilities (Validators, UI Helpers)
├── features/            # Feature-based modules
│   ├── auth/            # Login, Signup, Auth Controller
│   ├── tasks/           # Dashboard, Details, Task Controller, Repository
│   ├── categories/      # Category Management
│   ├── pomodoro/        # Timer Logic
│   ├── ai/              # Groq API Integration
│   ├── stats/           # Statistical Analysis
│   ├── home/            # Home and Navigation
│   └── settings/        # Theme & App Settings
└── main.dart            # Entry point

```

**Why this structure?**

1. **Scalability:** Each feature (e.g., `ai`, `pomodoro`) is self-contained. Adding new features doesn't clutter the core logic.
2. **Maintainability:** UI, Logic (Controllers), and Data (Repositories) are separated.
3. **Testing:** Easier to mock repositories and controllers for unit testing.

---

## ⚙️ Setup & Installation

### Prerequisites

* Flutter SDK installed.
* A Supabase Project (URL & Anon Key).
* A Groq Cloud API Key (for AI features).

### Steps

1. **Clone the Repo:**
```bash
git clone [https://github.com/avinav2611/mini_taskhub_pro.git](https://github.com/avinav2611/mini_taskhub_pro.git)
cd mini_taskhub_pro

```


2. **Install Dependencies:**
```bash
flutter pub get

```


3. **Configure Environment:**
   Open `lib/app/constants.dart` and add your keys:
```dart
class AppConstants {
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_KEY';
  static const String groqApiKey = 'YOUR_GROQ_KEY';
}

```


4. **Run the App:**
```bash
flutter run

```



---

## 🔥 Hot Reload vs. Hot Restart

* **⚡ Hot Reload (`r`):**
* **What it does:** Injects updated source code files into the running Dart Virtual Machine (VM) without losing state.
* **Use Case:** Updating UI colors, adjusting layouts, or fixing logic inside a method. The app retains your current screen and variable values (e.g., text inside a text field remains).


* **🔄 Hot Restart (`R`):**
* **What it does:** Completely destroys the current state, recompiles the code, and restarts the app from `main()`.
* **Use Case:** Changing Global State logic (Providers), App Initialization (Supabase init), or significant structural changes. It resets the app to the initial screen.



---

## 🔮 Future Scope

* **Mobile Widgets:** Add a Home Screen widget for quick task views.
* **Voice Tasks:** Use speech-to-text to add tasks.
* **Collaboration:** Share lists with other users via Supabase Realtime.

---

## Other ScreenShots

| <img src="https://github.com/user-attachments/assets/d7ecb6be-16d5-447e-a322-8e0757cb6b0e" width="150"/> | <img src="https://github.com/user-attachments/assets/c35b8354-120a-4ce8-8ac1-3e9afe4b4799" width="150"/> | <img src="https://github.com/user-attachments/assets/d89ff409-bc09-48a1-92ac-206cc0254d71" width="150"/> | <img src="https://github.com/user-attachments/assets/b2eecf3d-9a9d-4ae6-9864-af794dcfbd1c" width="150"/> | <img src="https://github.com/user-attachments/assets/5a5887ee-e497-428f-9554-15d37bcb3b2c" width="150"/> | <img src="https://github.com/user-attachments/assets/18466ecf-06ea-4d47-a261-ff2241d8daff" width="150"/> | <img src="https://github.com/user-attachments/assets/69399d1a-b35f-4411-9e73-02528f857282" width="150"/> | <img src="https://github.com/user-attachments/assets/30f4f1d7-7126-4473-ab77-80c4879f5bb9" width="150"/> | <img src="https://github.com/user-attachments/assets/7d8861e4-d38e-40fe-84d2-fa436ad015de" width="150"/> | <img src="https://github.com/user-attachments/assets/b0fbf936-88d9-4076-a615-91c947feab6c" width="150"/> | <img src="https://github.com/user-attachments/assets/78d9af4f-7876-43f5-b4c2-e1bb2d016f19" width="150"/> | <img src="https://github.com/user-attachments/assets/036f22fe-8471-41f1-9377-5903f834e54d" width="150"/> | <img src="https://github.com/user-attachments/assets/f01e23d6-bef3-4eca-841d-86124922d7eb" width="150"/> | <img src="https://github.com/user-attachments/assets/75a22077-517e-4185-a219-a0fd149b59f3" width="150"/> | <img src="https://github.com/user-attachments/assets/708c8f9c-ed4e-4f18-b79f-9701a1bc41e8" width="150"/> |


**Built with ❤️ by Avinav Prasad**
