# 🐶 SoPup: A Dual-Mode iOS Application for Safe Dog Socialisation

This project was developed as part of an **MSc in Software Engineering** and focuses on **clean iOS architecture, real-time systems, and scalable backend design.**

## 🔗 Related link
🌐 **[Demo & Case Study](https://mpmookr.wixsite.com/mysite/sopup)**
- The portfolio contains full UX flows, videos, system diagrams, and design decisions.

📦 **[Backend (Cloud Functions/Firebase)](https://github.com/MpmookR/SoPup_CloudFucntion)**
⚙️ **[TestFlight](https://testflight.apple.com/join/duM8Wv9Q)**
- **(Try Puppy Mode On Figma)[https://www.figma.com/proto/cxcrc0qeORVgLmnGKOeDhn/SoPup?page-id=0%3A1&node-id=10-712&p=f&viewport=251%2C420%2C0.16&t=XrOfr5vW7gh56Mzd-1&scaling=scale-down&content-scaling=fixed&starting-point-node-id=10%3A712]**
- **(Try Social Mode On Figma)[https://www.figma.com/proto/cxcrc0qeORVgLmnGKOeDhn/SoPup?page-id=111%3A1833&node-id=111-1834&viewport=313%2C305%2C0.14&t=dBB2LbexYm78ETOl-1&scaling=scale-down&content-scaling=fixed]**

---

<p align="center">
  <img src="docs/images/cover.png" width="700" alt="SoPup" />
</p>

SoPup is a SwiftUI-based iOS application designed to support responsible dog socialisation, adapting the experience based on the dog’s age.

The app operates in two distinct modes:
- **Puppy Mode** (0–12 weeks): education, safety, and controlled exposure
- **Social Mode** (12+ weeks): matchmaking, chat, meet-ups, and reviews

<p align="center">
  <img src="docs/images/mode.png" width="700" alt="dualMode" />
</p>

<p align="center">
  <img src="docs/images/keyFeatures.png" width="700" alt="keyFeatures" />
</p>

## 🧠 Key Features
- Dual experience modes based on dog age (Puppy / Social)
- Location-aware dog matchmaking
- Real-time chat with meet-up requests
- Post-meetup review system
- Push notifications for matches, messages, and meet-ups

## 🧱 Architecture Overview

<p align="center">
    <img src=docs/images/SimpleSystemDiagram.jpg width="700" alt="SystemDiagram" />
</p>

- SwiftUI client with MVVM & Clean Architecture
- Firebase Auth for authentication
- Firestore for real-time data and matchmaking state
- Cloud Functions (TypeScript) for business logic:
    - Match requests
    - Chat room creation
    - Meet-up lifecycle
    - Review aggregation
- FCM for push notifications

## 🛠 Tech Stack
**iOS**
- Swift, SwiftUI 
- MVVM + Clean Architecture
- Swift Concurrency (async/await, @MainActor)
- SwiftData
- MapKit & Core Location
- Modular, reusable UI components

**Backend**
- Firebase Authentication
- Firestore (real-time updates)
- Cloud Functions (TypeScript)
- Firebase Cloud Messaging (FCM)

## 🔐 Authentication & Data
- Sign in with Apple
- Sign in with Google
- Email / password authentication
- Firestore document existence checks
- Secure user-scoped data access

## 📐 System Design
A detailed breakdown of the system architecture, workflows, and backend orchestration is available here:
📄 [System Design Documentation](docs/system_design.md)