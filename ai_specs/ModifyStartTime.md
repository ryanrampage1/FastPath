# Functional Requirements - Edit Active Fast Start Time Feature

**Project:** Intermittent Fasting Tracker (iOS)
**Feature Version:** 1.0
**Date:** May 6, 2025
**Author:** [Your Name/Company Name]

**1. Overview**

This document outlines the specific functional requirements for allowing users to edit the start time of an *currently active* fasting period. This feature addresses scenarios where a user forgets to start the timer immediately or makes a small adjustment to their actual fast initiation time (e.g., had a late snack).

**2. Functional Requirements**

* **EST-001: Access to Edit Start Time**
    * **Description:** Provide a clear way for the user to initiate the start time editing process for an ongoing fast.
    * **Details:**
        * When a fast is currently active (FR-003), an "Edit Start Time" button or option shall be accessible on the main timer screen.
        * This option should be clearly labeled (e.g., "Adjust Start Time," "Edit Start").

* **EST-002: Start Time Modification Interface**
    * **Description:** Allow the user to select a new start date and time.
    * **Details:**
        * Upon activating the "Edit Start Time" option, the application shall present a date and time picker interface.
        * The picker should default to the currently recorded start time of the active fast.

* **EST-003: New Start Time Validation**
    * **Description:** Implement rules to ensure the new start time is valid.
    * **Details:**
        * The selected new start time cannot be in the future.
        * The selected new start time cannot be later than the current system time (or a very brief moment before, e.g., current time - 1 minute, to avoid issues).
        * An appropriate error message or feedback should be provided to the user if an invalid time is selected.

* **EST-004: Confirmation of Change**
    * **Description:** Require user confirmation before applying the new start time.
    * **Details:**
        * After selecting a new valid start time, the user must explicitly confirm the change (e.g., via a "Save," "Confirm," or "Update" button).
        * An option to "Cancel" the edit and revert to the original start time must also be available.

* **EST-005: Timer Recalculation and Display Update**
    * **Description:** Ensure all relevant timers and displays reflect the adjusted start time.
    * **Details:**
        * Upon confirmation of the new start time:
            * The elapsed time for the active fast (FR-003) must immediately recalculate and update based on the new start time.
            * If a Daily Fast Goal is set and a countdown timer is active (DFG-004), it must also immediately recalculate and update.
            * The main screen display must refresh to show the corrected timer(s).

* **EST-006: Data Persistence of New Start Time**
    * **Description:** The adjusted start time for the active fast must be saved.
    * **Details:**
        * The new, confirmed start time for the currently active fast must be saved to local storage, overwriting the previous start time for this specific fast instance.

* **EST-007: Impact on Dynamic Island / Live Activity**
    * **Description:** Ensure any active Live Activity reflects the change.
    * **Details:**
        * If a Live Activity for the current fast is active in the Dynamic Island (DI-001), its displayed remaining time (and any other relevant data) must update to reflect the new start time and recalculated goal completion.

**3. Non-Functional Requirements (Related)**

* **NFR-UI-EST:** The editing interface should be intuitive, consistent with iOS date/time selection patterns, and provide clear feedback.
* **NFR-Perf-EST:** The recalculation and display updates should be instantaneous from the user's perspective.
* **NFR-Data-EST:** The update to the locally stored start time must be atomic and reliable.

**4. Scope Considerations (Out of Scope for this Version)**

* Editing the start time of *completed* fasts (i.e., fasts in the history view). This is a separate feature.
* Editing the *end time* of an active or completed fast.

**5. Dependencies**

* This feature modifies an active fast, so it depends on the core fasting timer functionality (FR-001, FR-003).
* Interaction with the countdown timer depends on the "Daily Fast Goal" feature (DFG-001).
* Interaction with the Dynamic Island depends on the "Dynamic Island Fast Timer Feature" (DI-001).
