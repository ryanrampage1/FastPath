# Functional Requirements - Dynamic Island Fast Timer Feature

**Project:** Intermittent Fasting Tracker (iOS)
**Feature Version:** 1.0
**Date:** May 4, 2025
**Author:** [Your Name/Company Name]

**1. Overview**

This document outlines the specific functional requirements for integrating the active fasting timer with the iOS Dynamic Island and Live Activities feature. This aims to provide users with at-a-glance information about their remaining fast time without needing to open the app. This feature depends on the "Daily Fast Goal" feature being implemented and a goal being set by the user.

**2. Functional Requirements**

* **DI-001: Start Live Activity**
    * **Description:** Initiate a Live Activity visible in the Dynamic Island when a fast starts and a goal is set.
    * **Details:**
        * A Live Activity shall automatically start when the user taps the "Start Fast" button (FR-001) *only if* a Daily Fast Goal (FR-007 / DFG-001) has been previously set by the user.
        * If no Daily Fast Goal is set, no Live Activity should be started.

* **DI-002: Dynamic Island Content (Compact/Minimal)**
    * **Description:** Display concise remaining fast time in the compact Dynamic Island view.
    * **Details:**
        * When the Live Activity is active and the app is not in the foreground, the compact Dynamic Island presentation should display:
            * A relevant icon (e.g., a simple timer or fasting symbol).
            * The remaining time until the Daily Fast Goal is met (counting down, e.g., HH:MM or MM:SS format).
        * The time display must update dynamically (at least every minute, adhering to system limitations/recommendations for Live Activity updates).

* **DI-003: Dynamic Island Content (Expanded/Long-Look)**
    * **Description:** Display more detailed information in the expanded Dynamic Island view and on the Lock Screen.
    * **Details:**
        * When the Live Activity is expanded (e.g., via user interaction or on the Lock Screen), it should display:
            * A clear title like "Fasting Goal".
            * The remaining time until the Daily Fast Goal is met (counting down, e.g., HH:MM:SS format).
            * Optionally, the total elapsed time of the current fast (counting up).
            * Optionally, the target goal time (e.g., "Goal: 16 hours").
        * The time displays must update dynamically (at least every minute, adhering to system update frequency guidelines).

* **DI-004: Goal Reached State**
    * **Description:** Update the Live Activity when the fasting goal duration is achieved.
    * **Details:**
        * When the countdown timer reaches zero (goal met), the Live Activity display (both compact and expanded) should update to indicate completion.
        * Examples: Change text to "Goal Reached!", display a checkmark icon, briefly animate.
        * The activity should likely persist for a short, configurable duration after the goal is reached or until the fast is manually stopped, allowing the user to see the completion status.

* **DI-005: End Live Activity (Fast Stop)**
    * **Description:** Terminate the Live Activity when the fast is manually stopped.
    * **Details:**
        * When the user taps the "Stop Fast" button (FR-002) in the app, the associated Live Activity must be immediately ended and removed from the Dynamic Island and Lock Screen.

* **DI-006: Handling Goal Changes (Optional - Consider Complexity)**
    * **Description:** Define behavior if the user changes their Daily Fast Goal while a fast (and Live Activity) is active.
    * **Details (Option A - Simpler):** The Live Activity continues counting down to the *original* goal set when the fast started. The change only applies to future fasts.
    * **Details (Option B - More Complex):** The Live Activity updates dynamically to reflect the *new* goal, recalculating the remaining time. (Requires careful state management).
    * **Decision:** Specify which option (A or B) should be implemented. Option A is recommended for initial implementation simplicity.

* **DI-007: Handling App Termination**
    * **Description:** Ensure the Live Activity persists or correctly reflects state if the app is terminated.
    * **Details:**
        * The Live Activity should ideally persist even if the app is manually terminated by the user, continuing the countdown based on the start time and goal duration (requires background processing capabilities allowed for Live Activities).
        * Upon app relaunch, the app state and the Live Activity state must be synchronized.

**3. Non-Functional Requirements (Related)**

* **NFR-UI-DI:** The Dynamic Island presentation should be visually clean, conform to Apple's HIG for Live Activities, and provide clear information. Use system fonts and appropriate iconography.
* **NFR-Perf-DI:** Live Activity updates should be efficient to minimize battery consumption, adhering to Apple's update frequency recommendations.
* **NFR-Compat-DI:** Requires iOS 16.1 or later (or the minimum version supporting Live Activities). The feature should gracefully handle being run on older iOS versions where Dynamic Island/Live Activities are unavailable (i.e., the app should function correctly without this specific UI element).

