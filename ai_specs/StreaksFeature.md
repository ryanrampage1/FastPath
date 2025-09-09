# Functional Requirements - Streaks Feature

**Project:** Intermittent Fasting Tracker (iOS)
**Feature Version:** 1.0
**Date:** May 6, 2025
**Author:** [Your Name/Company Name]

**1. Overview**

This document outlines the specific functional requirements for implementing a "Streaks" feature within the Intermittent Fasting Tracker iOS application. This feature aims to motivate users by tracking and displaying their consistency in meeting their set daily fasting goals. This feature depends on the "Daily Fast Goal" feature (DFG-001) being implemented and a goal being actively used.

**2. Functional Requirements**

* **STR-001: Define Streak Criteria (Meeting Daily Goal)**
    * **Description:** Establish what constitutes a "streak."
    * **Details:**
        * A streak is defined as the number of consecutive days a user successfully completes a fast that meets or exceeds their currently set "Daily Fast Goal" duration (as per DFG-001).
        * A day is considered part of the streak if at least one fast completed on that calendar day meets the user's daily goal.
        * The determination of "completed on that calendar day" will be based on the fast's end time.

* **STR-002: Streak Calculation**
    * **Description:** Logic for calculating and updating the user's current streak.
    * **Details:**
        * When a fast is stopped (FR-002) and its duration meets or exceeds the user's set Daily Fast Goal for the day it ended:
            * If the previous day was also part of the streak, the current streak count increments by 1.
            * If the previous day was *not* part of the streak (or there was no fast meeting the goal on the previous day), the streak starts at 1.
        * If a calendar day passes where the user does *not* complete a fast that meets their Daily Fast Goal, the current streak is reset to 0. This check should ideally occur daily (e.g., at midnight or when the app is next opened after a day has passed).

* **STR-003: Streak Display**
    * **Description:** Show the user's current streak within the application.
    * **Details:**
        * The user's current streak count (e.g., "Current Streak: 5 days") shall be displayed in a prominent, easily visible location within the app (e.g., on the main dashboard/timer screen or a dedicated progress/stats area).
        * If the current streak is 0, it can either display "Current Streak: 0 days" or a motivational message (e.g., "Start a new streak today!").

* **STR-004: Streak Data Persistence**
    * **Description:** Store streak-related data locally and reliably.
    * **Details:**
        * The current streak count must be stored locally on the user's device.
        * The date of the last fast that contributed to the streak must also be stored to correctly calculate consecutive days.
        * This data must persist across application launches, device restarts, and app updates.

* **STR-005: Handling Changes to Daily Fast Goal**
    * **Description:** Define how changing the Daily Fast Goal affects an ongoing streak.
    * **Details:**
        * If a user changes their Daily Fast Goal, the streak calculation (STR-002) for *future* fasts will use the *new* goal.
        * The existing streak, built upon the previous goal, is maintained as long as subsequent fasts meet the *new* goal. Changing the goal mid-streak does not automatically reset the streak, but the new target must be met to continue it.

* **STR-006: Longest Streak (Optional - Future Enhancement)**
    * **Description:** Track and display the user's longest achieved streak.
    * **Details:** This is an optional enhancement for a future version. If implemented, the system would also store and display the user's "Longest Streak: X days".

**3. Non-Functional Requirements (Related)**

* **NFR-UI-Streak:** The streak display should be visually clear, motivating, and integrated naturally into the app's UI.
* **NFR-Data-Streak:** Streak data must be stored entirely locally on the device.
* **NFR-Perf-Streak:** Streak calculation logic should be efficient and not noticeably impact app performance, especially during app launch or when completing a fast.

**4. Dependencies**

* This feature relies on the implementation of:
    * User-settable "Daily Fast Goal" (DFG-001 and related requirements).
    * Core fasting start/stop and history logging functionality (FR-001, FR-002, FR-005).

