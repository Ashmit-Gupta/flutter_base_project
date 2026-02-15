# App Design System – Color Semantics & Usage Guide

This document explains **every color-related term** used in the app design system, **why it exists**, **what it represents**, and **how it must be used**.

The goal is to ensure:

* Visual consistency
* Accessibility
* Correct light/dark behavior
* Zero guesswork for developers

---

## 1. Core Principle (Read This First)

> **Colors represent MEANING, not appearance.**

You never choose a color because it *looks nice*.
You choose a color because it *means something*.

This system follows the same semantic approach used by:

* Material Design
* Apple HIG
* Enterprise fintech apps

---

## 2. Brand & Action Colors

### `primary`

**What it is:**
The main brand and action color.

**What it represents:**

* The most important action on a screen
* Value, progress, confirmation

**Used for:**

* Primary CTA buttons (Submit, Redeem, Login)
* Active navigation items
* Highlights & emphasis

**Rules:**

* Only ONE primary action per screen
* Never use for destructive actions

---

### `onPrimary`

**What it is:**
The content color that appears **on top of `primary`**.

**What it represents:**

* Readable content on a strong surface

**Used for:**

* Text on primary buttons
* Icons on primary buttons
* Loading indicators on primary buttons

**Why it exists:**

* Guarantees contrast
* Prevents hardcoded white/black
* Improves accessibility

**Golden Rule:**

> If the background is `primary`, the content MUST be `onPrimary`.

---

### `primaryDark`

**What it is:**
A darker shade of the primary color.

**Used for:**

* Pressed states
* Active states
* Emphasized UI elements

**Rule:**

* Never use directly in widgets
* Only used via theme/state styling

---

### `primaryLight`

**What it is:**
A light tint of the primary color.

**Used for:**

* Low-emphasis backgrounds
* Success containers
* Highlighted cards

**Rule:**

* Never used for text

---

## 3. Secondary & Informational Colors

### `secondary`

**What it is:**
Supporting brand color.

**What it represents:**

* Trust
* Information
* Navigation

**Used for:**

* Links
* Wallet balances
* Secondary actions

**Rule:**

* Should never overpower `primary`

---

## 4. Layout & Surface Colors

### `background`

**What it is:**
The base canvas of the app.

**Used for:**

* Scaffold background
* Page backgrounds

**Rule:**

* Nothing should visually fight with this color

---

### `surface`

**What it is:**
Raised surfaces above the background.

**Used for:**

* Cards
* Bottom sheets
* Dialogs
* Input fields

**Rule:**

* Always sits on top of `background`

---

### `border`

**What it is:**
Low-emphasis separator color.

**Used for:**

* Input borders
* Dividers
* Card outlines

**Rule:**

* Should NEVER dominate the UI

---

## 5. Text Colors

### `textPrimary`

**What it is:**
Highest emphasis text color.

**Used for:**

* Headings
* Important values
* Titles

---

### `textSecondary`

**What it is:**
Medium emphasis text color.

**Used for:**

* Body text
* Labels
* Descriptions

---

### `textMuted`

**What it is:**
Low emphasis text color.

**Used for:**

* Hint text
* Disabled text
* Placeholder text

**Rule:**

* Never use for important content

---

## 6. Status & Feedback Colors

### `success`

**What it is:**
Positive outcome color.

**Used for:**

* Success messages
* Completed actions
* Active states

---

### `warning`

**What it is:**
Cautionary state color.

**Used for:**

* Pending actions
* Low balance warnings
* Attention-required states

---

### `error`

**What it is:**
Failure or blocking issue color.

**Used for:**

* Validation errors
* Failed actions
* Destructive alerts

---

## 7. Transaction Semantics

### `credit`

**What it is:**
Incoming value color.

**Used for:**

* Money received
* Coupon allocations

---

### `debit`

**What it is:**
Outgoing value color.

**Used for:**

* Payments
* Fuel redemption

---

### `neutral`

**What it is:**
Non-positive, non-negative transaction color.

**Used for:**

* Fees
* Adjustments
* System-generated entries

---

## 8. What NOT to Do (Very Important)

❌ Do NOT hardcode colors in widgets
❌ Do NOT guess text colors
❌ Do NOT create new colors casually
❌ Do NOT use colors based on preference

---

## 9. When to Add New Colors

Add a new color ONLY if:

* A new semantic meaning appears
* The meaning cannot be expressed with existing colors

Examples:

* Rewards → `reward`
* Fraud → `critical`

---

## 10. Final Golden Rule

> **Widgets choose MEANING.**
> **The design system decides COLOR.**

This is how scalable, maintainable apps are built.
