# 💧 Hydration Tracker  
![SwiftUI](https://img.shields.io/badge/SwiftUI-Blue?logo=swift) 
![iOS](https://img.shields.io/badge/iOS-16%2B-lightgrey?logo=apple) 
![Xcode](https://img.shields.io/badge/Xcode-16+-blue?logo=xcode) 
![License](https://img.shields.io/badge/license-MIT-green)

A simple **SwiftUI** app to set and save your daily hydration goal (in ml).

---

## 🚀 Features
- Local persistence using `UserDefaults`  
- Numeric input validation  
- Clean interface with `NavigationStack`  
- Default goal: **2000 ml**

---

## 🧩 Structure
```swift
GoalStore → Manages and persists the daily goal  
GoalEditor → UI for editing and viewing the goal
