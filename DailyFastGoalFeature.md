# Functional Requirements - Daily Fast Goal Feature

**Project:** Intermittent Fasting Tracker (iOS)
**Feature Version:** 1.0
**Date:** May 4, 2025
**Author:** [Your Name/Company Name]

**1. Overview**

This document outlines the specific functional requirements for the "Daily Fast Goal" feature within the Intermittent Fasting Tracker iOS application. This feature allows users to set a target duration for their daily fasts and view their progress towards that goal via a countdown timer.

**2. Functional Requirements**

* **DFG-001: Set/Modify Daily Fast Goal**
    * **Description:** Allow the user to define and change a target duration for their daily fast.
    * **Details:**
        * The application must provide a dedicated interface (e.g., within a settings screen or accessible via a button on the main view) for the user to set or change their desired daily fasting duration.
        * The interface must clearly indicate the currently set goal, if any.

* **DFG-002: Goal Input Methods**
    * **Description:** Provide flexible options for setting the daily fast goal duration.
    * **Details:**
        * The goal-setting interface must offer predefined suggestions for common fasting durations (see DFG-003).
        * The interface must allow the user to manually input a custom duration (e.g., using a number input, picker, or slider, specifying hours and optionally minutes).

* **DFG-003: Predefined Goal Suggestions**
    * **Description:** Offer common fasting schedules as quick-select options within the goal-setting interface.
    * **Details:**
        * The predefined suggestions shall be based on common intermittent fasting patterns identified through research (these are hardcoded, not fetched live).
        * Suggestions should include, but are not limited to:
            * **14 Hours:** (Associated with 14/10 schedule) "A gentle start to time-restricted eating."
            * **16 Hours:** (Associated with 16/8 schedule) "A popular choice, may aid weight management and blood sugar control."
            * **18 Hours:** (Associated with 18/6 schedule) "A longer fast, potentially enhancing fat burning and focus."
            * **20 Hours:** (Associated with 20/4 schedule) "An extended daily fast."
        * Each suggestion must clearly display the duration and include a brief, informative description.
        * Selecting a suggestion should populate the goal duration accordingly.

* **DFG-004: Countdown Timer Display**
    * **Description:** Show time remaining until the daily goal is achieved during an active fast on the main screen.
    * **Details:**
        * When a fast is active AND a daily fast goal has been set by the user, the main timer display area must show both:
            * The total elapsed time of the current fast (counting up).
            * The remaining time until the set goal duration is reached (counting down, e.g., formatted as "Goal in HH:MM:SS" or similar).
        * The countdown timer should update dynamically (at least every second).
        * If no daily fast goal is set, only the elapsed time timer should be shown on the main screen.
        * Once the goal duration is reached during an active fast, the countdown timer display should clearly indicate this (e.g., disappear, change text to "Goal Reached!", show 00:00:00).

* **DFG-005: Goal Persistence**
    * **Description:** Ensure the user's selected daily fast goal is saved locally and reliably.
    * **Details:**
        * The user's selected daily fast goal duration must be stored locally on the iOS device.
        * This setting must persist across application launches, device restarts, and app updates.
        * The application must correctly use the saved goal when displaying the countdown timer (DFG-004) upon subsequent launches.

**3. Non-Functional Requirements (Related)**

* **NFR-UI-Goal:** The goal-setting interface (DFG-001, DFG-002, DFG-003) should be clean, intuitive, and easy to understand and use, adhering to standard iOS Human Interface Guidelines.
* **NFR-Data-Goal:** The daily fast goal data must be stored entirely locally on the device (DFG-005). No external network calls are required for this feature.
* **NFR-Perf-Goal:** Timer updates (both elapsed and countdown) related to the goal must be smooth and responsive.

