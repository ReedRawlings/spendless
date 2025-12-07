# SpendLess Launch Guide

This guide contains all marketing, content strategy, ad strategy, and launch preparation information for SpendLess.

---

## Pre-Launch Checklist

### Technical Readiness
- [ ] All V1 features implemented and tested
- [ ] Paywall integrated and tested (RevenueCat + Superwall)
- [ ] Notification system working (waiting list reminders, streak celebrations)
- [ ] Screen Time extensions tested on multiple devices
- [ ] App Groups configured correctly across all targets
- [ ] Deep linking tested (for shield actions → main app)
- [ ] Data persistence verified (SwiftData + UserDefaults)
- [ ] No critical bugs in core flows (onboarding, blocking, waiting list, graveyard)

### App Store Assets
- [ ] **App Icon** (1024x1024, all required sizes)
- [ ] **Screenshots** (6.7", 6.5", 5.5" displays)
  - Onboarding flow highlights
  - Dashboard with goal progress
  - Waiting list interface
  - Shield screen (if possible to capture)
  - Learning library cards
- [ ] **App Preview Video** (30 seconds, optional but recommended)
  - Show problem → solution flow
  - Highlight key features (blocking, waiting list, goal tracking)
- [ ] **App Store Description**
  - Subtitle (30 characters max)
  - Description (4000 characters max)
  - Keywords (100 characters max)
  - Promotional text (170 characters, can update without resubmission)
- [ ] **Privacy Policy URL** (required)
- [ ] **Terms of Service URL** (recommended)
- [ ] **Support URL** (required)

### Legal & Compliance
- [ ] Privacy Policy created and hosted
  - Data collection disclosure
  - Screen Time API usage explanation
  - Third-party services (RevenueCat, Superwall, analytics)
  - User data rights (GDPR, CCPA if applicable)
- [ ] Terms of Service created and hosted
- [ ] App Privacy details completed in App Store Connect
  - Data types collected
  - Data linked to user
  - Data used to track user
  - Data not collected

### Monetization Setup
- [ ] RevenueCat account configured
  - Products created (monthly, annual)
  - Entitlements configured
  - Webhooks set up (optional)
- [ ] Superwall account configured
  - Paywall templates created (use carousel format showing features)
  - A/B test variants set up
  - Paywall triggers defined
  - Notification integration configured (Superwall can pass notifications)
- [ ] **Paywall Messaging Strategy**
  - "Hey this is going to cost money, we need to earn money to continue building amazing tools. We want you to trial our tool before committing"
  - Show systems and outcomes, not just features
  - Show who they'll become using the app
  - Use carousel format for features they'll get access to
- [ ] Subscription pricing finalized
  - Monthly: $6.99
  - Annual: $39.99 (or equivalent)
  - Trial period duration determined
- [ ] Subscription terms tested end-to-end
  - Trial signup flow
  - Subscription purchase
  - Restore purchases
  - Subscription management

### Attribution & Analytics Setup
- [ ] **Analytics Platform Configured** (Amplitude or Mixpanel)
  - User journey tracking
  - Conversion funnel analysis
  - Cohort analysis by acquisition source
  - "Where did you hear about us?" tracking
- [ ] **Attribution Tracking**
  - Track which ads/videos users came from
  - Test dozens of ad variations
  - Identify which cohorts convert best
  - Track organic vs. paid acquisition

### Testing & QA
- [ ] **Internal Testing**
  - All onboarding screens tested
  - App blocking tested on multiple shopping apps
  - Shield screens tested (all difficulty modes)
  - Waiting list flow tested (7-day timer)
  - Graveyard functionality tested
  - Panic button flow tested
  - Goal tracking tested
  - Notification delivery tested
- [ ] **TestFlight Beta**
  - Build uploaded to TestFlight
  - External testers invited (10-50 users)
  - Feedback collection system in place
  - Crash reporting enabled (if using service)
  - Test duration: 2-4 weeks minimum
- [ ] **Edge Cases Tested**
  - No internet connection scenarios
  - App backgrounded during critical flows
  - Screen Time authorization revoked
  - Multiple device scenarios (if applicable)
  - Low storage space scenarios

### Marketing Preparation

**Content Strategy (Start Immediately)**
- [ ] **Start writing content immediately** — Longer it's up, better Google/LLM indexing
  - Blog posts about shopping compulsion, impulse buying, ADHD and shopping
  - "How to spend less" guides
  - Psychology of shopping addiction content
  - SEO-optimized articles targeting keywords users search for
- [ ] **Create shareable resources**
  - "How to Spend Less Guide" (like Kaizen journal) — link to SpendLess inside
  - TikTok shop videos with guide downloads
  - Free downloadable resources (PDFs, checklists)

**App Store Optimization (ASO) - Critical**
- [ ] **Keyword Research** (Use Sensor Tower + App Store search)
  - Find 2-3 keywords users associate with their future self (breaking compulsive shopping, reducing spending)
  - **MUST search App Store** to see what's currently ranking
  - Goal: Hold #1 ranking for target keywords
- [ ] **Title & Subtitle Optimization**
  - Put right keywords in title and subtitle
  - Test different combinations
  - Ensure keywords match what users search for
- [ ] **Description Optimization**
  - Call out pain points and offer solutions
  - Show aggregate view: "How they see themselves today" vs "What they could look like with SpendLess"
  - Position user as hero for choosing to spend less
  - Include keywords naturally throughout

**Community & Review Strategy**
- [ ] **Pre-launch review preparation**
  - Have users ready to write reviews immediately after launch
  - Identify beta testers who are likely to leave positive reviews
  - Prepare review request messaging (non-pushy)
- [ ] **Reddit & Quora Strategy**
  - Post product to relevant subreddits (r/shoppingaddiction, r/nobuy, r/adhd, etc.)
  - Post to Quora answering questions about shopping addiction
  - Answer authentically when users are looking for competitors
  - Provide value, not just promotion
  - Engagement bait, not rage bait

**Launch Strategy**
- [ ] Launch date selected
- [ ] Press kit prepared (if applicable)
- [ ] Social media accounts ready
- [ ] Launch announcement copy prepared
- [ ] TikTok shop video strategy planned

---

## Launch Day Checklist

### App Store Connect
- [ ] Final build uploaded and submitted for review
- [ ] App Store listing finalized
- [ ] Pricing and availability set
- [ ] Release date/time scheduled (or manual release)
- [ ] App review information completed
  - Demo account credentials (if required)
  - Review notes explaining Screen Time API usage
  - Contact information for reviewer questions

### Technical Monitoring
- [ ] Analytics dashboard set up (if using analytics)
- [ ] Crash reporting monitoring active
- [ ] RevenueCat dashboard monitoring
- [ ] Server/backend monitoring (if applicable)
- [ ] Error tracking alerts configured

### Support Preparation
- [ ] Support email/contact method ready
- [ ] FAQ document prepared
- [ ] Common issues troubleshooting guide
- [ ] Response templates for common questions

---

## Post-Launch (First Week)

### Monitoring
- [ ] Daily review of:
  - App Store reviews and ratings
  - Crash reports
  - RevenueCat subscription metrics
  - User feedback channels
  - Analytics (Amplitude/Mixpanel)
  - **Keyword rankings** (track position changes)
  - **Ad performance** (which ads/videos are converting)
  - **Attribution data** (where users are coming from)
- [ ] Monitor for:
  - Critical bugs
  - User confusion points
  - Paywall conversion rates
  - Onboarding drop-off points
  - **First 5 minutes engagement** (are users seeing value?)
  - **7-day journey completion** (are users progressing through the journey?)

### Organic Growth Strategy
- [ ] **Start with organic** — See what works organically first
- [ ] **Then scale with paid** — Use paid acquisition to amplify what's working
- [ ] **Create flywheel effect** — Organic + paid acquisition creates momentum
- [ ] **Content marketing**
  - Continue publishing SEO content
  - Answer questions on Reddit/Quora authentically
  - Engage in communities where users need help

### Quick Response
- [ ] Respond to App Store reviews (especially negative ones)
- [ ] Address critical bugs immediately
- [ ] Update FAQ based on common questions
- [ ] Consider hotfix release if critical issues found

### Iteration Planning
- [ ] Gather user feedback
- [ ] Identify top feature requests
- [ ] Plan V1.1 update based on real usage data
- [ ] Document lessons learned
- [ ] **Analyze ad performance** — Test dozens of ad variations, identify winners
- [ ] **Optimize onboarding** — This is where users convert (ads get them in, onboarding gets money)
- [ ] **Refine paywall** — Test different messaging, carousel formats, feature presentations

---

## Launch Metrics to Track

### User Acquisition
- App Store impressions
- App Store conversion rate (views → installs)
- Organic vs. paid installs
- **Keyword rankings** (track position for target keywords)
- **CPM (Cost Per Mille)** for paid ads
- Attribution by source (which ads/videos drive installs)
- "Where did you hear about us?" responses

### Engagement
- **Onboarding completion rate** (critical — ads get users in door, onboarding gets them to spend money)
- **First 5 minutes value delivery** (must convey value immediately)
- Daily active users (DAU)
- Weekly active users (WAU)
- Retention rates (Day 1, Day 7, Day 30)
- **7-Day Journey Completion**
  - Day 1: Get set up and identify goals/triggers
  - Day 2: Trial new interventions
  - Day 3: Learn about psychology
  - Day 4: Start leveraging waitlist
  - Day 5: First resisted shopping experience
  - Day 6: Leverage tools for better habits
  - Day 7: Watch waitlist items fade away

### Monetization
- Trial signup rate
- Trial-to-paid conversion rate
- Monthly recurring revenue (MRR)
- Annual plan adoption rate
- Churn rate
- **Demographics of converting users** (who responds to ads, converts, commits, generates revenue)
- **SMS engagement** (95% of texts read within 5 minutes)

### Feature Usage
- App blocking usage (shields triggered)
- Waiting list items created
- Graveyard items buried
- Panic button usage
- Goal completion rate

---

## Ad Strategy & Creative Guidelines

### Ad Best Practices
- **Clear Intent** — Clearly call out the tool and what it does
- **Differentiator** — What makes SpendLess unique vs. competitors
- **Engagement Bait, Not Rage Bait** — Create curiosity and engagement, not anger
- **Persuasion Hooks** — Use psychological triggers that resonate
- **Headlines** — Strong, clear headlines that communicate value
- **Building Trust** — Show social proof, testimonials, results
- **Strong CTA** — Clear call-to-action

### Ad Testing Strategy
- **Test dozens of variations** — Don't settle on first ad
- **Experiment with cohorts** — Track which ads drive which user types
- **UGC Ads** — User-generated content performs well
- **Influencer Partnerships** — Consider influencer collaborations
- **TikTok Shop Videos** — Create "How to spend less guide" videos linking to SpendLess

### Ad Targeting Considerations
- **Who's responding to ads?** (Demographics)
- **Who's converting through ads?** (Conversion analysis)
- **Who's going to commit and generate revenue?** (Revenue attribution)
- Focus paid spend on cohorts that convert and generate revenue

---

## User Engagement & Retention Strategy

### GIVE, GIVE, GIVE Model
- **Give value first** — Provide helpful resources before asking for anything
- **Get email or SMS** — After providing value, capture contact info
- **Send helpful resources** — Text/email with helpful content
- **Personalized interventions** — "This intervention might work best for you" based on their profile

### SMS Strategy (95% read within 5 minutes)
- Use SMS for high-engagement communications
- Send helpful resources via SMS
- Personalized intervention suggestions
- Check-in messages during trial period

### User Sharing & Virality
- **Shared Goals Feature** — Enable users to share goals with friends/family
- **Share to Waitlist Feature** — Allow users to share items from Amazon/Target directly to waitlist (instead of copying links)
- **Social sharing** — Make it easy to share wins, streaks, goal progress
- **Referral program** — Incentivize users to share the app

---

## Onboarding Optimization (Critical for Conversion)

### Onboarding Philosophy
- **"Ads get users in the door, onboarding gets them to spend money"**
- This is the best setup opportunity — make it count
- Must convey value in first 5 minutes

### Onboarding Strategy
- **Tie users to their questions earlier** — They give you answers, you make them feel seen
- **Call out pain points and offer solutions** — Address their struggles directly
- **Show aggregate view** — "How they see themselves today" vs "What they could look like with SpendLess"
- **Position user as hero** — They're making a brave choice to spend less and hit their goals
- **Trial messaging** — "We want you to trial our tool before committing"

### 7-Day Journey Framework
Show users the systems and outcomes they'll receive:

- **Day 1:** Get set up and identify your goals and triggers
- **Day 2:** Trial new interventions to find what fits
- **Day 3:** Learn about the psychology of habit formation and shopping compulsion
- **Day 4:** Start leveraging your waitlist
- **Day 5:** Experience your first resisted shopping experience
- **Day 6:** Leverage tools to help your brain build better habits
- **Day 7:** Watch your first waitlist items fade away as you make progress toward your goals

---

## Content & Lead Generation Strategy

### Content Marketing Approach
- **Use ads and generic content** to bring people into a single tool or survey
- **Nurture them as prospects** — Provide value, build relationship
- **Convert to trial** — After providing value, offer trial

### Content Types
- "How to spend less" guides (like Kaizen journal)
- Link to SpendLess inside guides
- TikTok shop videos with downloadable guides
- Psychology of shopping compulsion articles
- ADHD and shopping resources
- Free downloadable resources (PDFs, checklists)

---

## Resources

### ASO & Keyword Research Tools
- [Sensor Tower](https://sensortower.com/) — Keyword research and competitor analysis
- App Store search (manual) — **MUST check what's currently ranking**
- [AppTweak](https://www.apptweak.com/) — Alternative ASO tool

### Analytics & Attribution
- [Amplitude](https://amplitude.com/) — Product analytics
- [Mixpanel](https://mixpanel.com/) — Product analytics
- RevenueCat Analytics — Subscription analytics

---

*Last updated: Based on interview notes from Kyle Fowler, Clear30 Review, and Hunter Isaacson*

