# UI Migration and Integration Spec for Cocoa Folder

## Purpose
This document tracks the migration of all UI pages from the `cocoa/src/app/pages` folder to Flutter, ensuring all input elements are connected to the backend and the UI concept is preserved for future development.

## Migration Checklist
- [ ] Home
- [ ] Login
- [ ] Register
- [ ] Profile
- [ ] Chat
- [ ] Messages
- [ ] RegisterTalent
- [ ] Settings
- [ ] Favorites
- [ ] TopUp
- [ ] TransactionHistory
- [ ] UserProfile
- [ ] ErrorPage
- [ ] ReviewTalent
- [ ] TalentAnalytics
- [ ] TalentChat
- [ ] TalentHome
- [ ] TalentMessages
- [ ] TalentProfile
- [ ] TalentReviews
- [ ] TalentSchedule
- [ ] TalentSettings

## Migration Guidelines
1. **UI Parity**: Replicate the UI/UX from each React/TSX page in Flutter, using appropriate widgets and layouts.
2. **Input Handling**: All input fields (text, select, password, etc.) must be connected to backend endpoints via provider, bloc, or controller patterns.
3. **Navigation**: Maintain navigation structure (routes, tabs, etc.) as in the original UI.
4. **State Management**: Use a consistent state management approach (e.g., Provider, Riverpod, Bloc).
5. **Backend Integration**: All forms and actions (login, register, chat, top-up, etc.) must call backend APIs.
6. **Componentization**: Reuse components (cards, nav, modals) as Flutter widgets.
7. **Future-proofing**: Any new UI must extend this concept and be documented here.

## Notes
- Do not diverge from the UI/UX concept except for improvements or Flutter-specific best practices.
- Document any backend endpoints or integration details per page below.

---

## Page Integration Details

### Home
- **Inputs**: Search, City filter
- **Backend**: Fetch hosts, filter by city/query

### Login
- **Inputs**: Email, Password, Login type (user/talent)
- **Backend**: POST /login

### Register
- **Inputs**: Username, Password, Confirm Password, First/Last Name, Email, Phone, Gender, DOB, Address, Country, City, Postcode
- **Backend**: POST /register

### Profile
- **Inputs**: Actions (chat, voice, video, favorite, meet offline, payment)
- **Backend**: GET /profile/:id, POST /favorite, POST /payment

### Chat
- **Inputs**: Message input, Gift modal
- **Backend**: GET/POST /chat/:id

### Messages
- **Inputs**: Conversation selection
- **Backend**: GET /messages

### RegisterTalent
- **Inputs**: All user fields + talent-specific fields (stageName, bio, agency, languages, specialties, experience, socialMedia)
- **Backend**: POST /register-talent

### Settings
- **Inputs**: Tabs (basic, security, verification), File upload (idCard, selfie)
- **Backend**: PATCH /settings, POST /verify

### Favorites
- **Inputs**: None (display only)
- **Backend**: GET /favorites

### TopUp
- **Inputs**: Package selection, Payment method
- **Backend**: POST /topup

### TransactionHistory
- **Inputs**: None (display only)
- **Backend**: GET /transactions

### UserProfile
- **Inputs**: Edit profile, Logout
- **Backend**: GET/PATCH /user, POST /logout

---

## Extension
- Any new UI or feature must be appended here and follow the above guidelines.
- This file is the single source of truth for UI migration and integration.
