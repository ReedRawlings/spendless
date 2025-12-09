# SpendLess — Remaining Tasks by Priority

## 🔴 CRITICAL (Blocks Launch)

### 1. Paywall & Subscription System Dashboard Configuration
**Status:** Code complete, dashboard config needed  
**Priority:** CRITICAL — Required for monetization

**Tasks:**
- [ ] **RevenueCat Dashboard:**
  - [ ] Create products in App Store Connect (monthly $6.99, annual $39.99)
  - [ ] Configure products in RevenueCat dashboard
  - [ ] Create offerings (default offering with trial)
  - [ ] Set up entitlements ("Future Selves Pro")
  - [ ] Test subscription flow end-to-end

- [ ] **App Store Connect:**
  - [ ] Set up subscription products (monthly, annual)
  - [ ] Configure subscription groups
  - [ ] Set pricing and availability

- [ ] **Paywall Messaging Strategy:**
  - [ ] Design RevenueCat paywall UI (showing systems/outcomes, not just features)
  - [ ] Show who they'll become using the app
  - [ ] Trial messaging: "We want you to trial our tool before committing"
  - [ ] Finalize pricing and trial duration

**Note:** Using RevenueCat PaywallView only (Superwall removed)

**Estimated Time:** 2-3 days (dashboard work)

---

### 2. Notification System (Waiting List Reminders)
**Status:** Basic infrastructure ✅ complete, waiting list reminders needed  
**Priority:** CRITICAL — Waiting list is core feature, needs reminders

**What's Already Done:**
- ✅ `NotificationManager` exists and handles shield restoration notifications
- ✅ Notification permission requested in onboarding
- ✅ Deep linking infrastructure in place

**Still Needed:**
- [ ] Add waiting list notification methods to `NotificationManager`
- [ ] Schedule notifications when items are added (Day 2, 4, 6, 7 check-ins)
- [ ] Deep link to specific waiting list item (`spendless://waitinglist/{itemID}`)
- [ ] Cancel notifications when items are buried/bought
- [ ] Streak celebration notifications (7, 14, 30, 60, 90 days) - check on app launch
- [ ] Weekly summary notifications (Sunday evening) - schedule weekly
- [ ] Re-engagement notifications (if no app opens in 7 days) - check on app launch
- [ ] Settings toggle for notification preferences (waiting list, streaks, summaries)

**Estimated Time:** 2-3 days

---

### 3. App Store Preparation
**Status:** ✅ Screenshots and metadata done  
**Priority:** CRITICAL — Cannot launch without

**Tasks:**
- [x] **Screenshots** ✅ Done
- [x] **Metadata** ✅ Done
- [ ] **App Icon:**
  - [ ] 1024x1024 master icon
  - [ ] All required sizes generated
- [ ] **App Preview Video:**
  - [ ] 30-second video showing problem → solution
  - [ ] Highlight key features (blocking, waiting list, goal tracking)

**Estimated Time:** 1-2 days (icon + video)

---

### 4. Legal & Compliance (Required for Launch)
**Status:** Not started  
**Priority:** CRITICAL — App Store requirement

**Tasks:**
- [ ] **Privacy Policy:**
  - [ ] Data collection disclosure
  - [ ] Screen Time API usage explanation
  - [ ] Third-party services (RevenueCat, analytics)
  - [ ] User data rights (GDPR, CCPA if applicable)
  - [ ] Host on website (URL required for App Store)

- [ ] **Terms of Service:**
  - [ ] Create and host (recommended, not required)

- [ ] **App Store Connect Privacy Details:**
  - [ ] Data types collected
  - [ ] Data linked to user
  - [ ] Data used to track user
  - [ ] Data not collected

- [ ] **Support URL:**
  - [ ] Set up support email/contact method
  - [ ] Create FAQ document
  - [ ] Common issues troubleshooting guide

**Estimated Time:** 2-3 days (legal review may add time)

---

### 5. Testing & QA (Required Before Launch)
**Status:** Partial  
**Priority:** CRITICAL — Must test before launch

**Tasks:**
- [ ] **Internal Testing:**
  - [ ] All onboarding screens tested
  - [ ] App blocking tested on multiple shopping apps
  - [ ] Shield screens tested (all difficulty modes)
  - [ ] Waiting list flow tested (7-day timer)
  - [ ] Panic button flow tested
  - [ ] Goal tracking tested
  - [ ] Notification delivery tested
  - [ ] Paywall flow tested (trial, purchase, restore)

- [ ] **Edge Cases:**
  - [ ] No internet connection scenarios
  - [ ] App backgrounded during critical flows
  - [ ] Screen Time authorization revoked
  - [ ] Multiple device scenarios
  - [ ] Low storage space scenarios

- [ ] **TestFlight Beta:**
  - [ ] Build uploaded to TestFlight
  - [ ] External testers invited (10-50 users)
  - [ ] Feedback collection system in place
  - [ ] Crash reporting enabled
  - [ ] Test duration: 2-4 weeks minimum

**Estimated Time:** Ongoing (2-4 weeks for beta)

---

## 🟠 HIGH PRIORITY (Core V1 Features)

### 6. No-Goal Mode UI
**Status:** Not implemented  
**Priority:** HIGH — Users can select "Just want to stop wasting" in onboarding, need good option

**Tasks:**
- [ ] Cash pile visualization (grows as savings increase)
- [ ] Dashboard shows "$X kept in your pocket" instead of goal progress
- [ ] "Set a goal for this?" prompt when savings reach thresholds
- [ ] Handle goal completion → no-goal transition
- [ ] Update goal completion flow to support no-goal mode
- [ ] Design compelling no-goal experience (not just empty state)

**Estimated Time:** 2-3 days

---

### 7. Relapse Handling Flow
**Status:** Needs deeper design discussion  
**Priority:** HIGH — Important for user retention and support

**Questions to Answer:**
- What exactly constitutes a "relapse"? (Opening blocked app? Making a purchase?)
- How do we detect it? (Shield analytics? User self-report?)
- What's the user experience when it happens?
- How does grace period work in practice?
- What educational content is most helpful?

**Potential Tasks (TBD after design discussion):**
- [ ] Detect when streak breaks
- [ ] Show supportive messaging screen
- [ ] "I didn't buy anything" option with streak preservation
- [ ] Grace period logic and limits
- [ ] Educational content: "Why We Slip" and "Getting Back Up"
- [ ] Relapse tracking and insights

**Estimated Time:** TBD (needs design discussion first)

---

### 8. Paywall Integration Testing
**Status:** Code complete, needs testing  
**Priority:** HIGH — Must work before launch

**Tasks:**
- [ ] Test trial signup flow
- [ ] Test subscription purchase
- [ ] Test restore purchases
- [ ] Test subscription management
- [ ] Test paywall triggers (post-onboarding, Settings)
- [ ] Verify subscription status checks throughout app
- [ ] Test subscription limits (free tier restrictions)

**Estimated Time:** 1-2 days

---

### 9. Share to Waitlist (iOS Share Extension)
**Status:** Not implemented  
**Priority:** HIGH — Unique feature, move up in priority

**Tasks:**
- [ ] Create iOS Share Extension target
- [ ] Allow sharing items from Amazon/Target directly to waitlist
- [ ] Parse shared content (URL, text)
- [ ] Extract item name and price (if possible)
- [ ] Add to waiting list with pre-filled data
- [ ] Handle various shopping site formats

**Estimated Time:** 3-4 days

---

## 🟡 MEDIUM PRIORITY (Nice to Have for V1)

### 10. Card Sharing
**Status:** Not implemented  
**Priority:** MEDIUM — Should be super easy to implement

**Tasks:**
- [ ] Generate shareable image for dark pattern cards
- [ ] Instagram stories format
- [ ] Use `UIActivityViewController` for native share sheet
- [ ] Pre-populate caption: "Stopped impulse shopping with @spendlessapp 💪"

**Estimated Time:** 1-2 days (should be quick)

---

### 11. Returns Logging
**Status:** Flow exists in graveyard, may make more prominent later  
**Priority:** MEDIUM — Already functional, enhancement for later

**Current State:**
- Returns can be logged in graveyard
- Shows with special 🔄 badge

**Potential Enhancements (Later):**
- [ ] Make returns entry more prominent (dedicated button in Dashboard/Settings)
- [ ] Better returns tracking UI
- [ ] "X items returned, $Y recovered" stats

**Estimated Time:** 1 day (if we decide to enhance)

---

## 🟢 LOW PRIORITY (Post-Launch / V1.5)

### 12. Analytics Integration (Mixpanel/Amplitude)
**Status:** Deferred  
**Priority:** LOW — Can add post-launch

**Tasks:**
- [ ] Choose platform (Mixpanel or Amplitude)
- [ ] Integrate SDK
- [ ] Set up user journey tracking
- [ ] Conversion funnel analysis
- [ ] Cohort analysis by acquisition source
- [ ] "Where did you hear about us?" tracking

**Note:** Shield analytics ✅ complete, this is for broader app analytics

**Estimated Time:** 3-4 days

---

### 13. Additional Dark Pattern Cards
**Status:** 3 cards implemented, 10+ remaining  
**Priority:** LOW — Content expansion

**Tasks:**
- [ ] Add remaining cards:
  - Fake Scarcity
  - Social Pressure
  - Confirm Shaming
  - Hidden Costs
  - Anchoring
  - One-Click Trap
  - Infinite Scroll
  - Push Notifications
  - Personalized Ads
  - Loyalty Traps
  - Subscription Creep

**Estimated Time:** 1-2 days per card (content creation)

---

### 14. Letter to Future Self
**Status:** Not implemented  
**Priority:** LOW — Nice motivational feature

**Tasks:**
- [ ] Add text field in onboarding (after commitment screen)
- [ ] Store in UserProfile
- [ ] Show in shield screen subtitle (if space allows)
- [ ] Show in panic button flow
- [ ] Show after relapse

**Estimated Time:** 1-2 days

---

### 15. Saved Payment Removal Walkthrough
**Status:** Not implemented  
**Priority:** LOW — Helpful but not critical

**Tasks:**
- [ ] Create guided flow for removing saved cards
- [ ] Cover: Amazon, Target, Walmart, Shein, Temu, Apple Pay, Google Pay, PayPal
- [ ] Show during onboarding or Settings → "Boost Your Defenses"
- [ ] Step-by-step instructions with checkboxes

**Estimated Time:** 2-3 days

---

### 16. Gamification System (V2)
**Status:** Not implemented  
**Priority:** LOW — V2 feature

**Tasks:**
- [ ] SpendLess Coins system
- [ ] Achievement badges
- [ ] Weekly challenges
- [ ] Dashboard themes, goal frames, celebration effects

**Estimated Time:** 1-2 weeks

---

### 17. Danger Time Auto-Detection (V2)
**Status:** Not implemented  
**Priority:** LOW — V2 feature

**Tasks:**
- [ ] Track when users trigger blocked apps
- [ ] Track panic button usage patterns
- [ ] Track waiting list additions
- [ ] After 2 weeks: suggest extra protection during danger times
- [ ] Auto-switch to Firm mode during detected times
- [ ] Preemptive notifications

**Estimated Time:** 1 week

---

### 18. Email Unsubscribe Integration (V2)
**Status:** Not implemented  
**Priority:** LOW — V2 feature, Gmail only

**Tasks:**
- [ ] Gmail OAuth integration
- [ ] Scan for shopping domain emails
- [ ] Show unsubscribe list
- [ ] Process `List-Unsubscribe` headers
- [ ] On-device processing only

**Estimated Time:** 1 week

---

### 19. Widget Support (V2)
**Status:** Not implemented  
**Priority:** LOW — V2 feature

**Tasks:**
- [ ] Streak counter widget
- [ ] Goal progress bar widget
- [ ] Panic quick-action widget
- [ ] HALT check widget

**Estimated Time:** 1 week

---

## 📊 MARKETING & GROWTH (Ongoing)

### 20. Content Strategy (Ongoing)
**Status:** Not started  
**Priority:** MEDIUM — Longer content is up, better SEO/LLM indexing

**Tasks:**
- [ ] Start writing blog posts immediately:
  - Shopping compulsion articles
  - Impulse buying guides
  - ADHD and shopping content
  - Psychology of shopping addiction
- [ ] SEO-optimized articles targeting keywords
- [ ] Create shareable resources:
  - "How to Spend Less Guide" (PDF)
  - TikTok shop videos with guide downloads
  - Free downloadable checklists

**Estimated Time:** Ongoing (start now, continue post-launch)

---

### 21. Community & Review Strategy
**Status:** Not started  
**Priority:** MEDIUM — Important for launch momentum

**Tasks:**
- [ ] Pre-launch review preparation
  - [ ] Identify beta testers likely to leave positive reviews
  - [ ] Prepare review request messaging (non-pushy)
- [ ] Reddit & Quora strategy
  - [ ] Post to relevant subreddits (r/shoppingaddiction, r/nobuy, r/adhd)
  - [ ] Answer Quora questions about shopping addiction
  - [ ] Provide value, not just promotion
- [ ] Launch announcement copy prepared

**Estimated Time:** Ongoing (start now, continue post-launch)

---

## 📋 SUMMARY

### Critical Path to Launch (Must Complete):
1. **Paywall Dashboard Configuration** (2-3 days) - RevenueCat only
2. **Notification System** (2-3 days) - Waiting list reminders
3. **App Store Preparation** (1-2 days) - Icon + video (screenshots/metadata ✅ done)
4. **Legal & Compliance** (2-3 days)
5. **Testing & QA** (2-4 weeks beta)

**Total Critical Path:** ~3-4 weeks (with beta testing)

### High Priority (Should Complete for V1):
6. **No-Goal Mode UI** (2-3 days) - Need good option
7. **Relapse Handling Flow** (TBD) - Needs design discussion first
8. **Paywall Integration Testing** (1-2 days)
9. **Share to Waitlist** (3-4 days) - Unique feature, moved up

**Total High Priority:** ~1-2 weeks (depending on relapse design)

### Medium Priority (Nice to Have):
10. Card Sharing (1-2 days) - Should be easy
11. Returns Logging (1 day) - Enhancement for later

### Low Priority (Post-Launch):
12-19. Various V2 features (analytics, cards, gamification, widgets, etc.)

### Ongoing (Marketing):
20. Content Strategy (ongoing)
21. Community & Review Strategy (ongoing)

---

## 🎯 RECOMMENDED APPROACH

### Phase 1: Launch Blockers (Weeks 1-4)
Focus on Critical items 1-5. These must be done before launch.

### Phase 2: V1 Polish (Week 5)
Complete High Priority items 6-9 (except #7 which needs design discussion first).

### Phase 3: Launch Prep (Week 6)
Final testing, App Store submission, marketing prep.

### Phase 4: Post-Launch (Weeks 7+)
Monitor, iterate, add Medium/Low priority features based on user feedback.

---

## 🔍 NOTES

- **Superwall Removed:** Using RevenueCat PaywallView only
- **ASO Done:** Screenshots and metadata complete ✅
- **Notifications:** Basic infrastructure exists, need waiting list reminders
- **Relapse Handling:** Needs design discussion to clarify requirements
- **Share to Waitlist:** Moved to High Priority as unique feature

---

*Last Updated: Based on user feedback and codebase review*
