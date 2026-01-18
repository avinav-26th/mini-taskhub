# 📝 Mini TaskHub Pro - Flutter Assignment

> **Status:** Completed ✅ | **Role:** Flutter Developer Assignment

**Mini TaskHub Pro** is a feature-rich, personal task tracking application built with **Flutter** and **Supabase**. It goes beyond the basic requirements, implementing advanced features like **AI Coaching**, **Pomodoro Timer**, **Smart Analytics**, and a **Reactive UI** with optimistic updates.

---

## 📱 App Preview & Demo

| Dashboard & Filters | Task Details & AI | Analytics & Dark Mode |
|:---:|:---:|:---:|
| <img src="screenshots/dashboard.png" width="200"/> | <img src="screenshots/details.png" width="200"/> | <img src="screenshots/analytics.png" width="200"/> |

📺 **[Watch the Walkthrough Video Here](YOUR_YOUTUBE_OR_DRIVE_LINK_HERE)** 📥 **[Download the APK Here](YOUR_GITHUB_RELEASES_LINK_HERE)**

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

**Built with ❤️ by Avinav Prasad**