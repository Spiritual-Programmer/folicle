# 🌸 Folicle

***Personalized insights for facial hair growth triggers***

---

## 💡 Overview

Folicle is a **mobile-first wellness app** designed for women experiencing **hirsutism**. It helps users discover **personal lifestyle and physiological triggers**—like stress, sleep, sugar intake, and exercise—that may precede facial hair flare-ups.

The app combines **lagged Pearson correlation** for statistical analysis with an **AI coach** that provides clear, human-friendly insights.

> ⚠️ **Disclaimer:** Folicle provides **statistical insights only**. It does **not predict outcomes or provide medical advice**.

---

## ✨ Features

* **📝 Initial Assessment Questionnaire**
  Collects hair growth areas, previous treatments, known conditions, and hair removal methods.

* **📊 Weekly Check-In**
  Users rate stress, sugar intake, sleep quality, exercise, and hair growth on a **0–5 scale**.

* **📈 Lagged Pearson Correlation**
  Identifies which lifestyle factors are most correlated with hair growth, accounting for delayed effects.

* **🤖 AI Coach**
  Provides plain-language, actionable insights based on your data.

* **🎨 Minimalist, User-Friendly UI**
  Sleek, calming design inspired by apps like Flow.

---

## 🛠 Tech Stack

| Layer            | Technology                           |
| ---------------- | ------------------------------------ |
| Frontend         | Flutter (Android & iOS, web-ready)   |
| State Management | `setState` (MVP)                     |
| Local Storage    | Hive (weekly check-ins & assessment) |
| Optional Backend | Firebase (future user auth & cloud)  |
| Data Analysis    | Dart (lagged Pearson correlation)    |
| AI Layer         | Rule-based / LLM for insights        |

---

## ⚙️ How It Works

1. **Initial Assessment**
   User selects hair growth areas, treatments, conditions, and hair removal methods.

2. **Weekly Check-In**
   Users rate their **behavior** and **hair growth** on a 0–5 scale.

3. **Correlation Analysis**
   Lagged Pearson correlation identifies patterns over time.

4. **AI Coach Insights**
   The AI coach summarizes the strongest correlations in **plain language**.

5. **Continuous Tracking**
   Insights improve as **more weekly data** is collected.

---

## 📈 Screenshots

*(Add your screenshots here for better impact — initial assessment, weekly check-in, AI insights, etc.)*

---

## 🚀 Installation

```bash
# Clone the repo
git clone https://github.com/yourusername/folicle.git

# Navigate to project folder
cd folicle

# Install dependencies
flutter pub get

# Run on connected device or emulator
flutter run
```

---

## 🔮 Future Improvements

* **User authentication** and cloud syncing via Firebase
* **Enhanced AI coach** with OpenAI or local LLM integration
* **Graphs & visualizations** for longitudinal trends
* **Push notifications** for weekly check-ins
* **Dark mode** and more customization options
