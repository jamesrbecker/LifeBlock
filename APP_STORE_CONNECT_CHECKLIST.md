# LifeBlocks - App Store Connect Setup Checklist

## Step 1: Create App in App Store Connect

1. Go to [appstoreconnect.apple.com](https://appstoreconnect.apple.com)
2. Click **My Apps** → **+** → **New App**
3. Fill in:

| Field | Value |
|-------|-------|
| Platform | iOS |
| Name | **LifeBlocks** |
| Primary Language | English (U.S.) |
| Bundle ID | **com.lifeblock.app** |
| SKU | **lifeblock001** |
| User Access | Full Access |

---

## Step 2: App Information

### Basic Info
- **Name:** LifeBlocks
- **Subtitle:** Your Daily Accomplice
- **Category:** Health & Fitness
- **Secondary Category:** Lifestyle

### Privacy Policy URL
`https://jamesrbecker.github.io/LifeBlocks/privacy.html`

### Support URL
`https://x.com/lifeblockapp` (or your X handle)

---

## Step 3: Pricing & Availability

- **Price:** Free (with in-app purchases)
- **Availability:** All territories (or select specific ones)

---

## Step 4: In-App Purchases (IMPORTANT!)

Go to **In-App Purchases** → **+** → **Auto-Renewable Subscription**

### Create Subscription Group
- **Group Name:** LifeBlocks Premium

### Individual Subscriptions (Group: LifeBlocks Premium)

| Field | Value |
|-------|-------|
| Reference Name | Premium Monthly |
| Product ID | **com.lifeblock.premium.monthly** |
| Price | $1.99 |
| Subscription Duration | 1 Month |
| Display Name | Premium Monthly |
| Description | Full access to all premium features |

| Field | Value |
|-------|-------|
| Reference Name | Premium Annual |
| Product ID | **com.lifeblock.premium.yearly** |
| Price | $19.99 |
| Subscription Duration | 1 Year |
| Display Name | Premium Annual (Save 16%) |
| Description | Best value - save 16% |

### Family Subscriptions (Group: LifeBlocks Family)

| Field | Value |
|-------|-------|
| Reference Name | Family Monthly |
| Product ID | **com.lifeblock.premium.family.monthly** |
| Price | $4.99 |
| Subscription Duration | 1 Month |
| Display Name | Family Monthly |
| Description | Premium for up to 5 family members |

| Field | Value |
|-------|-------|
| Reference Name | Family Annual |
| Product ID | **com.lifeblock.premium.family** |
| Price | $39.99 |
| Subscription Duration | 1 Year |
| Display Name | Family Annual (Save 33%) |
| Description | Best family value - save 33% |

### Non-Consumable (Lifetime)

| Field | Value |
|-------|-------|
| Reference Name | Premium Lifetime |
| Product ID | **com.lifeblock.premium.lifetime** |
| Price | $49.99 |
| Type | Non-Consumable |
| Display Name | Lifetime Premium |
| Description | Unlock all premium features forever |

| Field | Value |
|-------|-------|
| Reference Name | Family Lifetime |
| Product ID | **com.lifeblock.premium.family.lifetime** |
| Price | $79.99 |
| Type | Non-Consumable |
| Family Sharing | Yes |
| Display Name | Family Lifetime |
| Description | Premium for your whole family, forever |

---

## Step 5: App Store Listing

### Screenshots (Upload from Marketing/Screenshots/)
1. `01_choose_path.png` - Choose your path
2. `02_daily_checkin.png` - 30 seconds to track
3. `03_year_visualized.png` - Your year visualized
4. `04_stay_motivated.png` - Stay motivated
5. `05_widgets.png` - Home screen widgets
6. `06_privacy_free.png` - Privacy & pricing

### Promotional Text (170 chars)
```
Stop scrolling. Start building. Choose your life path, track daily habits in 30 seconds, and watch your progress grid turn green. Block by block.
```

### Description
```
Stop scrolling. Start building.

LifeBlocks is the habit tracker for people who want to actually build the life they envision—not just watch time pass.

CHOOSE YOUR PATH
Select from 8 life paths—Content Creator, Entrepreneur, Software Engineer, Fitness, Investor, Health & Wellness, Creative, or Student—and get curated daily habits designed for your goals.

TRACK IN 30 SECONDS
Swipe through simple cards. Done, partial, or skipped. That's it. No complex logging. No guilt trips.

SEE YOUR PROGRESS
Your effort becomes a visual grid. Watch it turn green over time. Every block is a day you showed up for yourself.

STAY MOTIVATED
• Daily quotes tailored to your path
• Streak tracking to build momentum
• Level up as you grow
• Milestones at 7, 14, 21, 30, 100, and 365 days

FEATURES
• 8 life path templates with curated habits
• GitHub-style contribution grid
• Custom habit creation
• Apple Health integration (auto-track exercise & sleep)
• Home screen widgets (small, medium, large)
• Daily reminder notifications
• Detailed statistics
• Data export (Premium)
• Color themes (Premium)

PRIVACY FIRST
Your data stays on your device. We don't collect, sell, or share anything. Period.

FREE VS PREMIUM
Free: 5 habits, basic widgets, full tracking
Premium: Unlimited habits, all widgets, data export, themes

Build your life. Block by block.
```

### Keywords (100 chars max)
```
habit tracker,daily habits,goal setting,productivity,streak,motivation,self improvement,life path
```

### What's New (Version 1.0)
```
Welcome to LifeBlocks!

• Choose your life path from 8 archetypes
• Track daily habits with simple swipe cards
• Visualize progress with a contribution grid
• Apple Health integration
• Home screen widgets
• Daily motivational quotes

Build Your Life. Block by Block..
```

---

## Step 6: App Review Information

### Contact Info
- First Name: [Your name]
- Last Name: [Your name]
- Phone: [Your phone]
- Email: [Your email]

### Notes for Review
```
LifeBlocks is a habit tracking app.

To test the full experience:
1. Complete onboarding and select a life path
2. Check in by tapping "Check In" and swiping through habits
3. View your progress grid on the main screen
4. Add the widget to your home screen

In-app purchases:
- Premium Monthly: $1.99/month
- Premium Annual: $19.99/year
- Premium Lifetime: $49.99 one-time
- Family Monthly: $4.99/month
- Family Annual: $39.99/year
- Family Lifetime: $79.99 one-time

No demo account needed - all data is stored locally.
```

---

## Step 7: App Icon
- Already included in the build (1024x1024)

---

## Step 8: Build Upload

1. Open Xcode: `/Users/jamesbecker/Desktop/LifeBlock/LifeBlocks.xcodeproj`
2. Select your Apple Developer team in Signing & Capabilities
3. Select **Any iOS Device** as destination
4. **Product → Archive**
5. Once archived, click **Distribute App**
6. Choose **App Store Connect**
7. Follow prompts to upload

---

## Step 9: Submit for Review

1. Select the uploaded build
2. Answer export compliance (No encryption = No)
3. Answer content rights (You own everything = Yes)
4. Answer advertising identifier (No IDFA = No)
5. Click **Submit for Review**

---

## Expected Timeline

- Upload: Today
- Review: 24-48 hours (sometimes same day)
- Live: After approval

---

## Post-Launch Checklist

- [ ] Share on X/Twitter
- [ ] Post on Instagram
- [ ] Post on TikTok
- [ ] Post on LinkedIn
- [ ] Post on Reddit (r/productivity, r/getdisciplined)
- [ ] Tell friends and family
- [ ] Monitor App Store Connect for reviews
