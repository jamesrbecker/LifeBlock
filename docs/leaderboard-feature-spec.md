# LifeBlocks Leaderboard Feature Spec

## Overview
Social competition through leaderboards - unverified but with sanity checks to filter obvious cheaters.

## Sanity Checks (Server-Side)

### Automatic Filters
1. **Streak can't exceed account age** - If account is 30 days old, max streak is 30
2. **Streak can't exceed app release date** - Nobody has a 900-day streak on day 2
3. **Daily check-in limit** - Can only check in once per day per habit
4. **Reasonable score caps** - Max score per day based on habit count
5. **Account age minimum** - Must have account for 7+ days to appear on leaderboards
6. **Activity threshold** - Must have checked in at least 50% of days to qualify

### Soft Flags (Monitored, Not Blocked)
- Perfect scores every single day for 30+ days
- Checking in at exactly the same time every day (bot behavior)
- Sudden jumps in activity after long inactivity

## Leaderboard Types

### 1. Streak Leaderboard
- **Metric:** Current consecutive day streak
- **Tiebreaker:** Total lifetime check-ins
- **Reset:** Resets when streak breaks

### 2. Weekly Consistency
- **Metric:** Check-in percentage this week (0-100%)
- **Tiebreaker:** Total score this week
- **Reset:** Every Monday

### 3. Monthly Champions
- **Metric:** Total score for the month
- **Tiebreaker:** Consistency percentage
- **Reset:** First of each month

### 4. All-Time Legends
- **Metric:** Lifetime total score
- **Tiebreaker:** Account age (newer = more impressive)
- **No reset**

## Scope Options

### Global
- All LifeBlocks users worldwide
- Top 100 displayed
- Your rank shown even if not in top 100

### Friends
- Only users you've added as friends
- Requires friend system (already exists in app)
- More personal, less intimidating

### Challenges (Premium)
- Create custom leaderboards
- Invite friends via link
- Set duration (1 week, 30 days, etc.)
- Custom rules (specific habits only)

## Data Model

```swift
// CloudKit Record Types

struct LeaderboardEntry {
    let userID: String
    let displayName: String
    let avatarURL: String?

    // Metrics
    let currentStreak: Int
    let weeklyScore: Int
    let monthlyScore: Int
    let lifetimeScore: Int
    let consistencyPercent: Double

    // Sanity check fields
    let accountCreatedAt: Date
    let firstCheckInDate: Date
    let totalCheckIns: Int
    let totalDaysActive: Int

    let lastUpdated: Date
}

struct UserProfile {
    let userID: String
    let displayName: String
    let avatarEmoji: String  // Simple: just pick an emoji
    let isPublic: Bool       // Opt-in to global leaderboards
    let friendIDs: [String]
}
```

## UI Design

### Leaderboard Tab (New)
- Bottom nav: Home | Stats | **Leaderboard** | Settings
- Or: Accessible from Stats view

### Leaderboard View Layout
```
┌─────────────────────────────────┐
│  🏆 Leaderboards                │
├─────────────────────────────────┤
│ [Streak] [Weekly] [Monthly] [All]│  ← Segment control
├─────────────────────────────────┤
│  🥇 1. Sarah M.     47 days 🔥  │
│  🥈 2. Mike T.      43 days     │
│  🥉 3. Alex K.      41 days     │
│     4. Jordan P.    38 days     │
│     5. Casey R.     35 days     │
│     ...                         │
├─────────────────────────────────┤
│  ─────────────────────────────  │
│     47. You        12 days      │  ← Your position highlighted
│  ─────────────────────────────  │
├─────────────────────────────────┤
│  [👥 Friends Only] [🌍 Global]  │  ← Toggle
└─────────────────────────────────┘
```

### Profile Card (Tap on user)
```
┌─────────────────────────────────┐
│         🏃 Sarah M.             │
│                                 │
│   47 day streak 🔥              │
│   92% consistency               │
│   Member since Jan 2025         │
│                                 │
│   [Add Friend]  [View Grid]     │
└─────────────────────────────────┘
```

## Privacy & Opt-In

### Default: Private
- Users must opt-in to appear on global leaderboards
- Friends leaderboard is automatic if you have friends

### Privacy Settings
```
Leaderboards
├── Show me on Global Leaderboards  [Toggle]
├── Show my grid to friends         [Toggle]
├── Display Name: [James B.    ]    ← Editable
└── Profile Emoji: [🏃]             ← Picker
```

### What's Shared
- Display name (not real name)
- Streak/score numbers
- Consistency percentage
- Optionally: habit grid (friends only)

### What's NEVER Shared
- Email
- Specific habit names
- Check-in times
- Location

## Backend Architecture

### Option A: CloudKit (Recommended for MVP)
- Free with Apple Developer account
- Native iOS integration
- Handles auth via iCloud
- Public database for leaderboards
- Private database for user data

### Option B: Custom Backend (Future)
- More control
- Cross-platform potential
- Additional cost

### CloudKit Schema
```
Public Database:
├── LeaderboardEntry (indexed, queryable)
└── UserProfile (public info only)

Private Database:
├── UserSettings
├── HabitData
└── FriendConnections
```

## Implementation Phases

### Phase 1: Friends Leaderboard
- Use existing Friend model
- Local calculation, shared via CloudKit
- Simple streak comparison
- No global component yet

### Phase 2: Global Leaderboards
- Opt-in public profiles
- Server-side aggregation
- Top 100 + your rank
- Sanity check filtering

### Phase 3: Challenges
- Create/join challenge groups
- Custom durations
- Invite links
- Premium feature

## Monetization

### Free
- Friends leaderboard (unlimited friends)
- View global leaderboards
- Your rank on all boards

### Premium
- Create challenges
- Detailed competitor stats
- Historical leaderboard data
- Custom challenge rules

## Marketing Angle

```
"Compete with friends. Climb the ranks.
See how your consistency stacks up against the world."

"Your streak isn't just for you anymore."

"Join 10,000+ people competing to build better habits."
```

## Edge Cases

1. **User deletes account** → Remove from all leaderboards
2. **User goes private** → Remove from global, keep on friends
3. **Timezone differences** → Use device timezone for "day" calculation
4. **Tied scores** → Secondary sort by account age (newer wins)
5. **Inactive users** → Fade from leaderboards after 14 days inactive
6. **Name conflicts** → Allow duplicates (no unique requirement)

## Success Metrics

- % of users who opt-in to global leaderboards
- Average friends per user
- Retention rate for users on leaderboards vs not
- Challenge creation rate (premium)
- Social shares of leaderboard position
