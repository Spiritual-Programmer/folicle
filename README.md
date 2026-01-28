Folicle

Tagline: Personalized insights for facial hair growth triggers.

Overview

Folicle is a mobile-first wellness app designed for women experiencing hirsutism. It helps users identify lifestyle and physiological factors—such as stress, sleep, sugar intake, and exercise—that may precede facial hair growth flare-ups. The app leverages lagged Pearson correlation to reveal patterns in user behavior and includes an AI coach to provide understandable, human-friendly insights.

Disclaimer: Folicle provides statistical insights only. It does not predict outcomes or provide medical advice.

Features

Initial Assessment Questionnaire: Collects hair growth areas, previous treatments, known conditions, and hair removal methods.

Weekly Check-In: Users rate stress, sugar intake, sleep quality, exercise, and hair growth on a 0–5 scale.

Lagged Pearson Correlation: Identifies which lifestyle factors are most correlated with hair growth, accounting for delayed effects.

AI Coach: Provides plain-language insights and tips based on correlation results.

Minimalist, User-Friendly UI: Sleek, calming design inspired by apps like Flow.

Tech Stack

Frontend: Flutter (Android & iOS, web-ready)

State Management: setState (simple MVP, can scale to Provider or Riverpod)

Local Storage: Hive (stores weekly check-ins and assessment data)

Optional Backend: Firebase (for future user auth and cloud storage)

Data Analysis: Dart for Pearson correlation; AI layer can integrate LLM or rule-based insights

How It Works

Initial Assessment: User selects hair growth areas, treatments, conditions, and hair removal methods.

Weekly Check-In: User rates their behavior and hair growth.

Correlation Analysis: Lagged Pearson correlation identifies triggers over time.

Insights: AI coach summarizes the strongest correlations in plain language.

Continuous Tracking: Accuracy and relevance of insights improve as more weekly data is collected.

Installation

Clone the repository:

git clone https://github.com/yourusername/folicle.git


Navigate to the project directory:

cd folicle


Install dependencies:

flutter pub get


Run the app on your device/emulator:

flutter run

Future Improvements

User authentication and cloud syncing with Firebase

Enhanced AI coach using OpenAI or local LLM for personalized recommendations

Graphs and visualizations for longitudinal trends

Push notifications for weekly check-ins

Dark mode and more customization options
