import Foundation
import SwiftUI

// MARK: - Life Path Archetypes

enum LifePathCategory: String, CaseIterable, Codable {
    case contentCreator = "content_creator"
    case fitnessInfluencer = "fitness_influencer"
    case entrepreneur = "entrepreneur"
    case softwareEngineer = "software_engineer"
    case investor = "investor"
    case healthWellness = "health_wellness"
    case creative = "creative"
    case student = "student"
    // New paths
    case musician = "musician"
    case actor = "actor"
    case doctor = "doctor"
    case athlete = "athlete"
    case gameDeveloper = "game_developer"
    case writer = "writer"
    case parent = "parent"
    case digitalNomad = "digital_nomad"
    case custom = "custom"

    var displayName: String {
        switch self {
        case .contentCreator: return "Content Creator"
        case .fitnessInfluencer: return "Fitness Influencer"
        case .entrepreneur: return "Entrepreneur"
        case .softwareEngineer: return "Software Engineer"
        case .investor: return "Investor & Trader"
        case .healthWellness: return "Health & Wellness"
        case .creative: return "Creative Artist"
        case .student: return "Student"
        case .musician: return "Musician"
        case .actor: return "Actor & Performer"
        case .doctor: return "Doctor & Medical"
        case .athlete: return "Athlete"
        case .gameDeveloper: return "Game Developer"
        case .writer: return "Writer & Author"
        case .parent: return "Parent"
        case .digitalNomad: return "Digital Nomad"
        case .custom: return "Custom Path"
        }
    }

    var icon: String {
        switch self {
        case .contentCreator: return "video.fill"
        case .fitnessInfluencer: return "figure.strengthtraining.traditional"
        case .entrepreneur: return "lightbulb.fill"
        case .softwareEngineer: return "chevron.left.forwardslash.chevron.right"
        case .investor: return "chart.line.uptrend.xyaxis"
        case .healthWellness: return "heart.fill"
        case .creative: return "paintbrush.fill"
        case .student: return "book.fill"
        case .musician: return "music.note"
        case .actor: return "theatermasks.fill"
        case .doctor: return "stethoscope"
        case .athlete: return "trophy.fill"
        case .gameDeveloper: return "gamecontroller.fill"
        case .writer: return "pencil.line"
        case .parent: return "figure.and.child.holdinghands"
        case .digitalNomad: return "airplane"
        case .custom: return "star.fill"
        }
    }

    var color: Color {
        switch self {
        case .contentCreator: return .red
        case .fitnessInfluencer: return .orange
        case .entrepreneur: return .yellow
        case .softwareEngineer: return .blue
        case .investor: return .green
        case .healthWellness: return .pink
        case .creative: return .purple
        case .student: return .cyan
        case .musician: return Color(red: 0.6, green: 0.2, blue: 0.8) // Deep purple
        case .actor: return Color(red: 0.9, green: 0.3, blue: 0.5) // Magenta
        case .doctor: return Color(red: 0.2, green: 0.6, blue: 0.9) // Medical blue
        case .athlete: return Color(red: 1.0, green: 0.6, blue: 0.0) // Gold
        case .gameDeveloper: return Color(red: 0.4, green: 0.8, blue: 0.4) // Neon green
        case .writer: return Color(red: 0.6, green: 0.4, blue: 0.2) // Sepia
        case .parent: return Color(red: 0.9, green: 0.7, blue: 0.5) // Warm peach
        case .digitalNomad: return Color(red: 0.2, green: 0.8, blue: 0.8) // Teal
        case .custom: return .gray
        }
    }

    var tagline: String {
        switch self {
        case .contentCreator: return "Build your audience, one video at a time"
        case .fitnessInfluencer: return "Transform your body, inspire others"
        case .entrepreneur: return "Build something that matters"
        case .softwareEngineer: return "Code your future"
        case .investor: return "Grow your wealth strategically"
        case .healthWellness: return "Become the best version of yourself"
        case .creative: return "Express yourself, create beauty"
        case .student: return "Master your craft, ace your goals"
        case .musician: return "Make music that moves the world"
        case .actor: return "Bring stories to life"
        case .doctor: return "Heal others, master medicine"
        case .athlete: return "Train like a champion"
        case .gameDeveloper: return "Build worlds, create experiences"
        case .writer: return "Write your story, inspire millions"
        case .parent: return "Raise amazing humans"
        case .digitalNomad: return "Work anywhere, live everywhere"
        case .custom: return "Design your own journey"
        }
    }

    var motivationalQuotes: [String] {
        switch self {
        case .contentCreator:
            return [
                "Every creator you admire started with zero followers.",
                "Consistency beats perfection. Post today.",
                "Your unique perspective is your superpower.",
                "The algorithm rewards those who show up.",
                "One viral video can change everything."
            ]
        case .fitnessInfluencer:
            return [
                "Your body can do it. It's your mind you need to convince.",
                "Sweat now, shine later.",
                "Every workout is a step toward your best self.",
                "Discipline is choosing what you want most over what you want now.",
                "Your transformation inspires others."
            ]
        case .entrepreneur:
            return [
                "The best time to start was yesterday. The next best time is now.",
                "Every empire started with a single decision.",
                "Solve problems, create value, wealth follows.",
                "Rejection is just redirection.",
                "Your network is your net worth."
            ]
        case .softwareEngineer:
            return [
                "Every expert was once a beginner.",
                "Debug your life like you debug your code.",
                "Ship it. Iterate later.",
                "The best code is code that ships.",
                "Learn something new every day."
            ]
        case .investor:
            return [
                "Compound interest is the eighth wonder of the world.",
                "Time in the market beats timing the market.",
                "Knowledge is the best investment.",
                "Rich people stay rich by living like they're broke.",
                "Your future self will thank you."
            ]
        case .healthWellness:
            return [
                "Take care of your body. It's the only place you have to live.",
                "Small daily improvements lead to stunning results.",
                "You don't have to be extreme, just consistent.",
                "Health is wealth.",
                "Rest is productive."
            ]
        case .creative:
            return [
                "Create something today, even if it's imperfect.",
                "Your art matters. The world needs your voice.",
                "Creativity is intelligence having fun.",
                "Done is better than perfect.",
                "Every master was once a disaster."
            ]
        case .student:
            return [
                "Education is the passport to the future.",
                "Study hard now, live easier later.",
                "Knowledge is power.",
                "Consistency beats cramming.",
                "You're building your future right now."
            ]
        case .musician:
            return [
                "Every hit song started as a rough idea.",
                "Practice today, perform tomorrow.",
                "Your sound is unique. Own it.",
                "Music is the language of the soul.",
                "One song can change someone's life."
            ]
        case .actor:
            return [
                "Every audition is practice for the one that matters.",
                "Your next role could be your breakthrough.",
                "Great actors never stop learning.",
                "Rejection is redirection to the right role.",
                "The stage is waiting for you."
            ]
        case .doctor:
            return [
                "Every hour of study is a life you might save.",
                "Medicine is a marathon, not a sprint.",
                "Your dedication will heal thousands.",
                "Today's sacrifice is tomorrow's expertise.",
                "Be the doctor you'd want to have."
            ]
        case .athlete:
            return [
                "Champions are made when no one is watching.",
                "Pain is temporary, glory is forever.",
                "Your competition is yesterday's you.",
                "Rest is part of the training.",
                "Every rep counts."
            ]
        case .gameDeveloper:
            return [
                "Every game you love started as an idea.",
                "Ship it. Players will tell you what to fix.",
                "Your game could be someone's favorite memory.",
                "Debug, iterate, improve.",
                "The next indie hit could be yours."
            ]
        case .writer:
            return [
                "Write one page today. That's a book in a year.",
                "Your words have power. Use them.",
                "Every bestseller started with a blank page.",
                "Write badly. Edit brilliantly.",
                "Someone out there needs your story."
            ]
        case .parent:
            return [
                "You're shaping the future, one day at a time.",
                "Present beats perfect.",
                "Small moments become big memories.",
                "You're doing better than you think.",
                "They won't remember perfect. They'll remember love."
            ]
        case .digitalNomad:
            return [
                "Your office is wherever you want it to be.",
                "Work hard, explore harder.",
                "Freedom requires discipline.",
                "The world is your workplace.",
                "Adventure and income can coexist."
            ]
        case .custom:
            return [
                "Your path is uniquely yours.",
                "Progress, not perfection.",
                "Every step forward counts.",
                "You're closer than you think.",
                "Keep going."
            ]
        }
    }

    // Suggested habits for each path
    var suggestedHabits: [HabitTemplate] {
        switch self {
        case .contentCreator:
            return [
                HabitTemplate(name: "Create Content", icon: "video.fill", color: "#FF6B6B", description: "Film, write, or produce something"),
                HabitTemplate(name: "Post Content", icon: "arrow.up.circle.fill", color: "#4ECDC4", description: "Share your work with the world"),
                HabitTemplate(name: "Engage Community", icon: "bubble.left.and.bubble.right.fill", color: "#45B7D1", description: "Reply to comments, DMs, engage"),
                HabitTemplate(name: "Learn Platform", icon: "lightbulb.fill", color: "#96CEB4", description: "Study trends, algorithm, competitors"),
                HabitTemplate(name: "Batch Content", icon: "square.stack.3d.up.fill", color: "#FFEAA7", description: "Prepare content in advance"),
                HabitTemplate(name: "Networking", icon: "person.3.fill", color: "#DDA0DD", description: "Connect with other creators")
            ]
        case .fitnessInfluencer:
            return [
                HabitTemplate(name: "Morning Workout", icon: "figure.run", color: "#FF6B6B", description: "Get your body moving"),
                HabitTemplate(name: "Track Macros", icon: "fork.knife", color: "#4ECDC4", description: "Log your nutrition"),
                HabitTemplate(name: "Post Fitness Content", icon: "camera.fill", color: "#45B7D1", description: "Share your journey"),
                HabitTemplate(name: "Meal Prep", icon: "refrigerator.fill", color: "#96CEB4", description: "Prepare healthy meals"),
                HabitTemplate(name: "Recovery/Stretch", icon: "figure.yoga", color: "#FFEAA7", description: "Take care of your body"),
                HabitTemplate(name: "10K Steps", icon: "figure.walk", color: "#DDA0DD", description: "Stay active throughout the day")
            ]
        case .entrepreneur:
            return [
                HabitTemplate(name: "Revenue Activity", icon: "dollarsign.circle.fill", color: "#4ECDC4", description: "Do something that makes money"),
                HabitTemplate(name: "Sales Outreach", icon: "phone.fill", color: "#FF6B6B", description: "Contact potential customers"),
                HabitTemplate(name: "Product Work", icon: "hammer.fill", color: "#45B7D1", description: "Build or improve your product"),
                HabitTemplate(name: "Learn Business", icon: "book.fill", color: "#96CEB4", description: "Read, listen, or watch business content"),
                HabitTemplate(name: "Network", icon: "person.3.fill", color: "#FFEAA7", description: "Meet or connect with someone new"),
                HabitTemplate(name: "Review Metrics", icon: "chart.bar.fill", color: "#DDA0DD", description: "Check your numbers")
            ]
        case .softwareEngineer:
            return [
                HabitTemplate(name: "Code", icon: "chevron.left.forwardslash.chevron.right", color: "#45B7D1", description: "Write code for projects"),
                HabitTemplate(name: "Learn New Tech", icon: "book.fill", color: "#4ECDC4", description: "Study documentation, tutorials"),
                HabitTemplate(name: "LeetCode/Practice", icon: "brain.head.profile", color: "#FF6B6B", description: "Solve coding problems"),
                HabitTemplate(name: "Side Project", icon: "hammer.fill", color: "#96CEB4", description: "Build something for yourself"),
                HabitTemplate(name: "Read Tech News", icon: "newspaper.fill", color: "#FFEAA7", description: "Stay current with industry"),
                HabitTemplate(name: "Contribute OSS", icon: "arrow.triangle.branch", color: "#DDA0DD", description: "Open source contributions")
            ]
        case .investor:
            return [
                HabitTemplate(name: "Market Research", icon: "magnifyingglass", color: "#4ECDC4", description: "Analyze markets and trends"),
                HabitTemplate(name: "Review Portfolio", icon: "chart.pie.fill", color: "#45B7D1", description: "Check your investments"),
                HabitTemplate(name: "Read Financial News", icon: "newspaper.fill", color: "#FF6B6B", description: "Stay informed on markets"),
                HabitTemplate(name: "Learn Investing", icon: "book.fill", color: "#96CEB4", description: "Study strategies, read books"),
                HabitTemplate(name: "Track Expenses", icon: "dollarsign.circle.fill", color: "#FFEAA7", description: "Monitor your spending"),
                HabitTemplate(name: "Savings Contribution", icon: "banknote.fill", color: "#DDA0DD", description: "Add to investments")
            ]
        case .healthWellness:
            return [
                HabitTemplate(name: "Exercise", icon: "figure.run", color: "#FF6B6B", description: "Move your body"),
                HabitTemplate(name: "Meditate", icon: "brain.head.profile", color: "#4ECDC4", description: "Practice mindfulness"),
                HabitTemplate(name: "Drink Water", icon: "drop.fill", color: "#45B7D1", description: "Stay hydrated (8 glasses)"),
                HabitTemplate(name: "Healthy Eating", icon: "leaf.fill", color: "#96CEB4", description: "Eat nutritious food"),
                HabitTemplate(name: "Sleep 8 Hours", icon: "moon.fill", color: "#FFEAA7", description: "Get quality rest"),
                HabitTemplate(name: "No Phone Morning", icon: "iphone.slash", color: "#DDA0DD", description: "Phone-free first hour")
            ]
        case .creative:
            return [
                HabitTemplate(name: "Create Art", icon: "paintbrush.fill", color: "#DDA0DD", description: "Make something creative"),
                HabitTemplate(name: "Practice Craft", icon: "pencil.tip", color: "#FF6B6B", description: "Deliberate practice"),
                HabitTemplate(name: "Consume Inspiration", icon: "eye.fill", color: "#4ECDC4", description: "Study other artists"),
                HabitTemplate(name: "Share Work", icon: "square.and.arrow.up", color: "#45B7D1", description: "Put your work out there"),
                HabitTemplate(name: "Learn Technique", icon: "book.fill", color: "#96CEB4", description: "Study tutorials, classes"),
                HabitTemplate(name: "Journal/Reflect", icon: "text.book.closed.fill", color: "#FFEAA7", description: "Document your journey")
            ]
        case .student:
            return [
                HabitTemplate(name: "Study Session", icon: "book.fill", color: "#45B7D1", description: "Focused study time"),
                HabitTemplate(name: "Review Notes", icon: "doc.text.fill", color: "#4ECDC4", description: "Review what you learned"),
                HabitTemplate(name: "Practice Problems", icon: "pencil.and.list.clipboard", color: "#FF6B6B", description: "Apply your knowledge"),
                HabitTemplate(name: "Read Ahead", icon: "arrow.right.doc.on.clipboard", color: "#96CEB4", description: "Preview upcoming material"),
                HabitTemplate(name: "Ask Questions", icon: "questionmark.circle.fill", color: "#FFEAA7", description: "Clarify what you don't understand"),
                HabitTemplate(name: "Teach Someone", icon: "person.2.fill", color: "#DDA0DD", description: "Explain concepts to others")
            ]
        case .musician:
            return [
                HabitTemplate(name: "Practice Instrument", icon: "music.note", color: "#9933FF", description: "Dedicated practice time"),
                HabitTemplate(name: "Write Music", icon: "pencil.and.list.clipboard", color: "#FF6B6B", description: "Compose or write lyrics"),
                HabitTemplate(name: "Record/Produce", icon: "waveform", color: "#4ECDC4", description: "Work on recordings"),
                HabitTemplate(name: "Learn Music Theory", icon: "book.fill", color: "#45B7D1", description: "Study theory or technique"),
                HabitTemplate(name: "Listen Actively", icon: "headphones", color: "#96CEB4", description: "Study music you admire"),
                HabitTemplate(name: "Promote Your Music", icon: "megaphone.fill", color: "#FFEAA7", description: "Share on social media, reach out")
            ]
        case .actor:
            return [
                HabitTemplate(name: "Rehearse/Practice", icon: "theatermasks.fill", color: "#E64980", description: "Run lines, practice scenes"),
                HabitTemplate(name: "Audition Prep", icon: "doc.text.fill", color: "#FF6B6B", description: "Prepare for upcoming auditions"),
                HabitTemplate(name: "Watch & Study", icon: "play.tv.fill", color: "#4ECDC4", description: "Study performances, films, shows"),
                HabitTemplate(name: "Voice/Body Work", icon: "figure.yoga", color: "#45B7D1", description: "Voice exercises, movement"),
                HabitTemplate(name: "Self-Tape", icon: "video.fill", color: "#96CEB4", description: "Record yourself, review performance"),
                HabitTemplate(name: "Network", icon: "person.3.fill", color: "#FFEAA7", description: "Connect with industry people")
            ]
        case .doctor:
            return [
                HabitTemplate(name: "Study/Review", icon: "book.fill", color: "#3399FF", description: "Medical studies and review"),
                HabitTemplate(name: "Clinical Practice", icon: "stethoscope", color: "#FF6B6B", description: "Patient care or simulation"),
                HabitTemplate(name: "Research", icon: "magnifyingglass", color: "#4ECDC4", description: "Read journals, stay current"),
                HabitTemplate(name: "Self-Care", icon: "heart.fill", color: "#45B7D1", description: "Rest, exercise, mental health"),
                HabitTemplate(name: "Flashcards/ANKI", icon: "rectangle.stack.fill", color: "#96CEB4", description: "Active recall practice"),
                HabitTemplate(name: "Teaching/Explaining", icon: "person.2.fill", color: "#FFEAA7", description: "Teach others to solidify knowledge")
            ]
        case .athlete:
            return [
                HabitTemplate(name: "Training Session", icon: "figure.run", color: "#FF9900", description: "Main workout or practice"),
                HabitTemplate(name: "Skill Drills", icon: "target", color: "#FF6B6B", description: "Sport-specific skill work"),
                HabitTemplate(name: "Recovery", icon: "bed.double.fill", color: "#4ECDC4", description: "Stretching, massage, rest"),
                HabitTemplate(name: "Nutrition", icon: "fork.knife", color: "#45B7D1", description: "Eat for performance"),
                HabitTemplate(name: "Film Study", icon: "play.rectangle.fill", color: "#96CEB4", description: "Watch game tape, learn"),
                HabitTemplate(name: "Mental Training", icon: "brain.head.profile", color: "#FFEAA7", description: "Visualization, focus work")
            ]
        case .gameDeveloper:
            return [
                HabitTemplate(name: "Code/Build", icon: "chevron.left.forwardslash.chevron.right", color: "#66CC66", description: "Work on your game"),
                HabitTemplate(name: "Design/Plan", icon: "pencil.and.ruler.fill", color: "#FF6B6B", description: "Game design, documentation"),
                HabitTemplate(name: "Art/Assets", icon: "paintbrush.fill", color: "#4ECDC4", description: "Create or source game assets"),
                HabitTemplate(name: "Playtest", icon: "gamecontroller.fill", color: "#45B7D1", description: "Test your game, find bugs"),
                HabitTemplate(name: "Learn Engine", icon: "book.fill", color: "#96CEB4", description: "Unity, Unreal, Godot tutorials"),
                HabitTemplate(name: "Community", icon: "bubble.left.and.bubble.right.fill", color: "#FFEAA7", description: "Share progress, get feedback")
            ]
        case .writer:
            return [
                HabitTemplate(name: "Write", icon: "pencil.line", color: "#996633", description: "Put words on the page"),
                HabitTemplate(name: "Read", icon: "book.fill", color: "#FF6B6B", description: "Read in your genre"),
                HabitTemplate(name: "Edit/Revise", icon: "pencil.and.outline", color: "#4ECDC4", description: "Polish your work"),
                HabitTemplate(name: "Outline/Plan", icon: "list.bullet", color: "#45B7D1", description: "Plot, structure, plan"),
                HabitTemplate(name: "Submit/Pitch", icon: "paperplane.fill", color: "#96CEB4", description: "Send to agents, publishers, markets"),
                HabitTemplate(name: "Writing Craft", icon: "graduationcap.fill", color: "#FFEAA7", description: "Study craft, take courses")
            ]
        case .parent:
            return [
                HabitTemplate(name: "Quality Time", icon: "figure.and.child.holdinghands", color: "#FFBB88", description: "Focused time with kids"),
                HabitTemplate(name: "Read Together", icon: "book.fill", color: "#FF6B6B", description: "Read to/with your children"),
                HabitTemplate(name: "Self-Care", icon: "heart.fill", color: "#4ECDC4", description: "Take care of yourself too"),
                HabitTemplate(name: "Family Meal", icon: "fork.knife", color: "#45B7D1", description: "Eat together as a family"),
                HabitTemplate(name: "Active Play", icon: "figure.play", color: "#96CEB4", description: "Physical activity with kids"),
                HabitTemplate(name: "Learning Activity", icon: "brain.head.profile", color: "#FFEAA7", description: "Educational games, homework help")
            ]
        case .digitalNomad:
            return [
                HabitTemplate(name: "Deep Work", icon: "laptopcomputer", color: "#33CCCC", description: "Focused work session"),
                HabitTemplate(name: "Client/Project Work", icon: "briefcase.fill", color: "#FF6B6B", description: "Billable work or main project"),
                HabitTemplate(name: "Explore Local", icon: "map.fill", color: "#4ECDC4", description: "Discover your current location"),
                HabitTemplate(name: "Language Learning", icon: "character.bubble.fill", color: "#45B7D1", description: "Learn the local language"),
                HabitTemplate(name: "Exercise", icon: "figure.run", color: "#96CEB4", description: "Stay fit on the road"),
                HabitTemplate(name: "Connect Home", icon: "phone.fill", color: "#FFEAA7", description: "Call friends, family back home")
            ]
        case .custom:
            return []
        }
    }
}

// MARK: - Habit Template

struct HabitTemplate: Identifiable, Codable {
    var id = UUID()
    let name: String
    let icon: String
    let color: String
    let description: String

    func toHabit() -> Habit {
        let habit = Habit(name: name, icon: icon, colorHex: color)
        return habit
    }
}

// MARK: - User's Life Path

struct UserLifePath: Codable {
    var selectedPath: LifePathCategory
    var customGoalName: String?
    var selectedDate: Date // When they want to achieve this
    var milestones: [Milestone]
    var dailyQuote: String?

    init(path: LifePathCategory, goalName: String? = nil) {
        self.selectedPath = path
        self.customGoalName = goalName
        self.selectedDate = Calendar.current.date(byAdding: .year, value: 1, to: Date()) ?? Date()
        self.milestones = []
    }
}

// MARK: - Milestones

struct Milestone: Identifiable, Codable {
    var id = UUID()
    var title: String
    var description: String
    var targetDate: Date
    var isCompleted: Bool = false
    var completedDate: Date?
}

// MARK: - Path Progress

struct PathProgress {
    let daysOnPath: Int
    let currentStreak: Int
    let totalCheckIns: Int
    let averageScore: Double
    let habitsCompleted: Int

    var level: Int {
        // Level up every 7 days of consistent tracking
        return max(1, daysOnPath / 7 + 1)
    }

    var levelTitle: String {
        switch level {
        case 1: return "Beginner"
        case 2...3: return "Apprentice"
        case 4...6: return "Practitioner"
        case 7...10: return "Expert"
        case 11...15: return "Master"
        case 16...25: return "Grandmaster"
        default: return "Legend"
        }
    }

    var progressToNextLevel: Double {
        let daysInCurrentLevel = daysOnPath % 7
        return Double(daysInCurrentLevel) / 7.0
    }
}

// MARK: - App Settings Extension for Life Path

extension AppSettings {
    private static let lifePathKey = "userLifePath"
    private static let onboardingCompleteKey = "onboardingComplete"
    private static let pathStartDateKey = "pathStartDate"

    var userLifePath: UserLifePath? {
        get {
            guard let data = UserDefaults.standard.data(forKey: Self.lifePathKey) else { return nil }
            return try? JSONDecoder().decode(UserLifePath.self, from: data)
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(data, forKey: Self.lifePathKey)
            }
        }
    }

    var isOnboardingComplete: Bool {
        get { UserDefaults.standard.bool(forKey: Self.onboardingCompleteKey) }
        set { UserDefaults.standard.set(newValue, forKey: Self.onboardingCompleteKey) }
    }

    var pathStartDate: Date? {
        get { UserDefaults.standard.object(forKey: Self.pathStartDateKey) as? Date }
        set { UserDefaults.standard.set(newValue, forKey: Self.pathStartDateKey) }
    }
}
