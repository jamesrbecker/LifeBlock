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
    // Trade School Paths
    case electrician = "electrician"
    case plumber = "plumber"
    case welder = "welder"
    case construction = "construction"
    case hvacTech = "hvac_tech"
    case carpenter = "carpenter"
    case mechanic = "mechanic"
    case truckDriver = "truck_driver"
    // Healthcare Paths
    case nurse = "nurse"
    case emt = "emt"
    case physicalTherapist = "physical_therapist"
    case dentalPro = "dental_pro"
    // Professional Paths
    case teacher = "teacher"
    case lawyer = "lawyer"
    case realEstate = "real_estate"
    case chef = "chef"
    case pilot = "pilot"
    case military = "military"
    case firstResponder = "first_responder"
    case sales = "sales"
    case exploring = "exploring"  // For users who want to explore before committing
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
        case .electrician: return "Electrician"
        case .plumber: return "Plumber"
        case .welder: return "Welder"
        case .construction: return "Construction"
        case .hvacTech: return "HVAC Technician"
        case .carpenter: return "Carpenter"
        case .mechanic: return "Mechanic"
        case .truckDriver: return "Truck Driver"
        case .nurse: return "Nurse"
        case .emt: return "EMT / Paramedic"
        case .physicalTherapist: return "Physical Therapist"
        case .dentalPro: return "Dental Professional"
        case .teacher: return "Teacher"
        case .lawyer: return "Lawyer"
        case .realEstate: return "Real Estate Agent"
        case .chef: return "Chef"
        case .pilot: return "Pilot"
        case .military: return "Military"
        case .firstResponder: return "First Responder"
        case .sales: return "Sales Professional"
        case .exploring: return "Just Exploring"
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
        case .electrician: return "bolt.fill"
        case .plumber: return "wrench.and.screwdriver.fill"
        case .welder: return "flame.fill"
        case .construction: return "hammer.fill"
        case .hvacTech: return "thermometer.snowflake"
        case .carpenter: return "ruler.fill"
        case .mechanic: return "car.fill"
        case .truckDriver: return "truck.box.fill"
        case .nurse: return "cross.case.fill"
        case .emt: return "staroflife.fill"
        case .physicalTherapist: return "figure.walk"
        case .dentalPro: return "mouth.fill"
        case .teacher: return "graduationcap.fill"
        case .lawyer: return "building.columns.fill"
        case .realEstate: return "house.fill"
        case .chef: return "frying.pan.fill"
        case .pilot: return "airplane"
        case .military: return "shield.fill"
        case .firstResponder: return "light.beacon.max.fill"
        case .sales: return "person.badge.shield.checkmark.fill"
        case .exploring: return "magnifyingglass"
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
        case .electrician: return Color(red: 1.0, green: 0.8, blue: 0.0) // Electric yellow
        case .plumber: return Color(red: 0.0, green: 0.5, blue: 0.8) // Pipe blue
        case .welder: return Color(red: 1.0, green: 0.4, blue: 0.0) // Welding orange
        case .construction: return Color(red: 0.8, green: 0.5, blue: 0.2) // Hard hat orange
        case .hvacTech: return Color(red: 0.3, green: 0.7, blue: 0.9) // Cool blue
        case .carpenter: return Color(red: 0.6, green: 0.4, blue: 0.2) // Wood brown
        case .mechanic: return Color(red: 0.3, green: 0.3, blue: 0.3) // Steel gray
        case .truckDriver: return Color(red: 0.4, green: 0.2, blue: 0.6) // Highway purple
        case .nurse: return Color(red: 0.9, green: 0.4, blue: 0.5) // Scrubs pink
        case .emt: return Color(red: 1.0, green: 0.2, blue: 0.2) // Emergency red
        case .physicalTherapist: return Color(red: 0.4, green: 0.7, blue: 0.5) // Healing green
        case .dentalPro: return Color(red: 0.6, green: 0.8, blue: 0.9) // Clinical blue
        case .teacher: return Color(red: 0.8, green: 0.4, blue: 0.4) // Apple red
        case .lawyer: return Color(red: 0.3, green: 0.3, blue: 0.5) // Navy
        case .realEstate: return Color(red: 0.0, green: 0.6, blue: 0.4) // Money green
        case .chef: return Color(red: 0.9, green: 0.5, blue: 0.1) // Flame orange
        case .pilot: return Color(red: 0.2, green: 0.4, blue: 0.7) // Sky blue
        case .military: return Color(red: 0.3, green: 0.4, blue: 0.3) // Army green
        case .firstResponder: return Color(red: 0.8, green: 0.1, blue: 0.1) // Fire red
        case .sales: return Color(red: 0.2, green: 0.7, blue: 0.3) // Success green
        case .exploring: return Color(red: 0.5, green: 0.5, blue: 0.6) // Neutral gray-purple
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
        case .electrician: return "Power the world, build your future"
        case .plumber: return "Essential skills, essential income"
        case .welder: return "Forge your path with fire and steel"
        case .construction: return "Build something that lasts"
        case .hvacTech: return "Keep the world comfortable"
        case .carpenter: return "Craft with your hands, build with pride"
        case .mechanic: return "Master the machines"
        case .truckDriver: return "Keep America moving"
        case .nurse: return "Care for others, change lives"
        case .emt: return "Be the calm in the chaos"
        case .physicalTherapist: return "Help others move through life"
        case .dentalPro: return "Create healthy smiles"
        case .teacher: return "Shape the future, one student at a time"
        case .lawyer: return "Fight for what's right"
        case .realEstate: return "Help people find home"
        case .chef: return "Create experiences through food"
        case .pilot: return "See the world from above"
        case .military: return "Serve something greater than yourself"
        case .firstResponder: return "When seconds count, you're there"
        case .sales: return "Solve problems, close deals"
        case .exploring: return "Build habits first, find your path later"
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
                "Write one page today. That's a screenplay in three months.",
                "Every great film started as words on a page.",
                "Your story deserves to be told. Write it.",
                "Write badly. Rewrite brilliantly.",
                "Someone out there needs to see your story.",
                "The blank page is where magic begins.",
                "Every writer you admire was once where you are now."
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
        case .electrician:
            return [
                "Electricians light up the world.",
                "Master the code, master the trade.",
                "Every circuit you wire builds your future.",
                "High demand means high pay. Stay sharp.",
                "Safety first, excellence always."
            ]
        case .plumber:
            return [
                "Plumbers keep civilization running.",
                "No one questions your rates when the water's off.",
                "Master your trade, own your future.",
                "Every call is a chance to build your reputation.",
                "Essential work means essential income."
            ]
        case .welder:
            return [
                "Welders build the backbone of industry.",
                "Your welds hold the world together.",
                "Master your craft, name your price.",
                "Every bead you lay is a step toward mastery.",
                "Precision today, prosperity tomorrow."
            ]
        case .construction:
            return [
                "You build what others only dream of.",
                "Every structure started with someone like you.",
                "Hard work builds hard assets.",
                "Show up, work hard, get ahead.",
                "The world needs builders. Be the best."
            ]
        case .hvacTech:
            return [
                "Everyone needs comfort. You provide it.",
                "Hot summers and cold winters mean year-round work.",
                "Master the systems, master your income.",
                "Certifications open doors. Keep learning.",
                "You're essential when the AC breaks in July."
            ]
        case .carpenter:
            return [
                "Measure twice, cut once. Excellence in everything.",
                "Your hands create what CAD can only design.",
                "Every piece you craft is a signature.",
                "Carpentry is where art meets function.",
                "Build your skills, build your wealth."
            ]
        case .mechanic:
            return [
                "Master the machines that move the world.",
                "Every problem you solve builds your reputation.",
                "Diagnostics is detective work. Stay curious.",
                "Cars will always need fixing. You'll always have work.",
                "Your skills are your security."
            ]
        case .truckDriver:
            return [
                "The open road is your office.",
                "Every mile builds your paycheck.",
                "Reliability is everything in trucking.",
                "Owner-operators build real wealth.",
                "Keep moving, keep earning."
            ]
        case .nurse:
            return [
                "You make the difference in someone's worst day.",
                "Compassion is your superpower.",
                "Every shift, you save lives.",
                "Nursing opens doors everywhere.",
                "Your care matters more than you know."
            ]
        case .emt:
            return [
                "You are the first hope in an emergency.",
                "Stay calm, save lives.",
                "Every call makes you stronger.",
                "Your training is someone's lifeline.",
                "Heroes don't always wear capes."
            ]
        case .physicalTherapist:
            return [
                "You help people reclaim their lives.",
                "Every rep you guide is progress.",
                "Patience and skill heal together.",
                "Movement is medicine.",
                "Your hands restore independence."
            ]
        case .dentalPro:
            return [
                "Healthy smiles change lives.",
                "Precision and care in every procedure.",
                "Your skills are always in demand.",
                "Prevention is the best treatment.",
                "Build trust, build your practice."
            ]
        case .teacher:
            return [
                "You shape the future every day.",
                "One lesson can change a life.",
                "The best teachers never stop learning.",
                "Your impact lasts generations.",
                "Education is the great equalizer."
            ]
        case .lawyer:
            return [
                "Words are your weapon. Use them wisely.",
                "Every case sharpens your skills.",
                "Justice requires persistence.",
                "Preparation wins cases.",
                "Your voice matters in the courtroom."
            ]
        case .realEstate:
            return [
                "Every closed deal builds your empire.",
                "Relationships are your real inventory.",
                "Hustle today, passive income tomorrow.",
                "The market rewards the prepared.",
                "Your network is your net worth."
            ]
        case .chef:
            return [
                "Every dish is a chance to create joy.",
                "Master the basics, then innovate.",
                "Your kitchen, your rules.",
                "Taste everything, learn everything.",
                "Great food brings people together."
            ]
        case .pilot:
            return [
                "The sky is your office.",
                "Precision and calm under pressure.",
                "Every flight hour builds your career.",
                "See the world while you work.",
                "Safety first, adventure always."
            ]
        case .military:
            return [
                "Discipline is freedom.",
                "You're part of something bigger.",
                "Train hard, stay ready.",
                "Honor, courage, commitment.",
                "Your service matters."
            ]
        case .firstResponder:
            return [
                "When others run away, you run toward.",
                "Your courage saves lives.",
                "Every call is a chance to help.",
                "The community depends on you.",
                "Train like lives depend on it—they do."
            ]
        case .sales:
            return [
                "Every no gets you closer to yes.",
                "Solve problems, earn trust, close deals.",
                "Your income has no ceiling.",
                "Rejection is just redirection.",
                "Top performers never stop prospecting."
            ]
        case .exploring:
            return [
                "Every journey starts with a single step.",
                "You don't have to have it all figured out.",
                "Build the habit of showing up first.",
                "Clarity comes from action, not thought.",
                "Small wins lead to big discoveries."
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
                HabitTemplate(name: "Monetization", icon: "dollarsign.circle.fill", color: "#FFEAA7", description: "Work on sponsors, brand deals, products"),
                HabitTemplate(name: "Track Revenue", icon: "chart.bar.fill", color: "#DDA0DD", description: "Review earnings, analytics, growth")
            ]
        case .fitnessInfluencer:
            return [
                HabitTemplate(name: "Morning Workout", icon: "figure.run", color: "#FF6B6B", description: "Get your body moving"),
                HabitTemplate(name: "Track Macros", icon: "fork.knife", color: "#4ECDC4", description: "Log your nutrition"),
                HabitTemplate(name: "Post Fitness Content", icon: "camera.fill", color: "#45B7D1", description: "Share your journey"),
                HabitTemplate(name: "Meal Prep", icon: "refrigerator.fill", color: "#96CEB4", description: "Prepare healthy meals"),
                HabitTemplate(name: "Brand Outreach", icon: "dollarsign.circle.fill", color: "#FFEAA7", description: "Contact sponsors, brands, collabs"),
                HabitTemplate(name: "Track Revenue", icon: "chart.bar.fill", color: "#DDA0DD", description: "Monitor income streams, affiliate sales")
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
                HabitTemplate(name: "Side Project", icon: "hammer.fill", color: "#96CEB4", description: "Build income-generating projects"),
                HabitTemplate(name: "Freelance/Contracts", icon: "dollarsign.circle.fill", color: "#FFEAA7", description: "Find clients, side gigs, contracts"),
                HabitTemplate(name: "Career Growth", icon: "chart.line.uptrend.xyaxis", color: "#DDA0DD", description: "Negotiate raises, job hunt, network")
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
                HabitTemplate(name: "Sell/Commission", icon: "dollarsign.circle.fill", color: "#96CEB4", description: "List work, take commissions, sell prints"),
                HabitTemplate(name: "Track Art Income", icon: "chart.bar.fill", color: "#FFEAA7", description: "Monitor sales, pricing, markets")
            ]
        case .student:
            return [
                HabitTemplate(name: "Study Session", icon: "book.fill", color: "#45B7D1", description: "Focused study time"),
                HabitTemplate(name: "Review Notes", icon: "doc.text.fill", color: "#4ECDC4", description: "Review what you learned"),
                HabitTemplate(name: "Practice Problems", icon: "pencil.and.list.clipboard", color: "#FF6B6B", description: "Apply your knowledge"),
                HabitTemplate(name: "Scholarship/Aid", icon: "dollarsign.circle.fill", color: "#96CEB4", description: "Apply for scholarships, grants, aid"),
                HabitTemplate(name: "Part-Time Income", icon: "briefcase.fill", color: "#FFEAA7", description: "Work, tutoring, freelance gigs"),
                HabitTemplate(name: "Budget/Save", icon: "banknote.fill", color: "#DDA0DD", description: "Track spending, save for goals")
            ]
        case .musician:
            return [
                HabitTemplate(name: "Practice Instrument", icon: "music.note", color: "#9933FF", description: "Dedicated practice time"),
                HabitTemplate(name: "Write Music", icon: "pencil.and.list.clipboard", color: "#FF6B6B", description: "Compose or write lyrics"),
                HabitTemplate(name: "Record/Produce", icon: "waveform", color: "#4ECDC4", description: "Work on recordings"),
                HabitTemplate(name: "Gig/Performance", icon: "music.mic", color: "#45B7D1", description: "Book shows, play live, perform"),
                HabitTemplate(name: "Music Income", icon: "dollarsign.circle.fill", color: "#96CEB4", description: "Streaming royalties, merch, licensing"),
                HabitTemplate(name: "Promote & Grow", icon: "chart.line.uptrend.xyaxis", color: "#FFEAA7", description: "Marketing, playlists, fan growth")
            ]
        case .actor:
            return [
                HabitTemplate(name: "Rehearse/Practice", icon: "theatermasks.fill", color: "#E64980", description: "Run lines, practice scenes"),
                HabitTemplate(name: "Audition Prep", icon: "doc.text.fill", color: "#FF6B6B", description: "Prepare for upcoming auditions"),
                HabitTemplate(name: "Self-Tape/Reel", icon: "video.fill", color: "#4ECDC4", description: "Record auditions, update demo reel"),
                HabitTemplate(name: "Agent/Casting", icon: "person.crop.circle.badge.checkmark", color: "#45B7D1", description: "Agent calls, casting director outreach"),
                HabitTemplate(name: "Booking Income", icon: "dollarsign.circle.fill", color: "#96CEB4", description: "Track bookings, residuals, pay"),
                HabitTemplate(name: "Side Hustle", icon: "briefcase.fill", color: "#FFEAA7", description: "Flexible income between roles")
            ]
        case .doctor:
            return [
                HabitTemplate(name: "Study/Review", icon: "book.fill", color: "#3399FF", description: "Medical studies and review"),
                HabitTemplate(name: "Clinical Practice", icon: "stethoscope", color: "#FF6B6B", description: "Patient care or simulation"),
                HabitTemplate(name: "Research", icon: "magnifyingglass", color: "#4ECDC4", description: "Read journals, stay current"),
                HabitTemplate(name: "Self-Care", icon: "heart.fill", color: "#45B7D1", description: "Rest, exercise, mental health"),
                HabitTemplate(name: "Loan Payoff", icon: "dollarsign.circle.fill", color: "#96CEB4", description: "Track student loans, pay extra"),
                HabitTemplate(name: "Financial Plan", icon: "chart.bar.fill", color: "#FFEAA7", description: "Investing, retirement, wealth building")
            ]
        case .athlete:
            return [
                HabitTemplate(name: "Training Session", icon: "figure.run", color: "#FF9900", description: "Main workout or practice"),
                HabitTemplate(name: "Skill Drills", icon: "target", color: "#FF6B6B", description: "Sport-specific skill work"),
                HabitTemplate(name: "Recovery", icon: "bed.double.fill", color: "#4ECDC4", description: "Stretching, massage, rest"),
                HabitTemplate(name: "Nutrition", icon: "fork.knife", color: "#45B7D1", description: "Eat for performance"),
                HabitTemplate(name: "Sponsorships", icon: "dollarsign.circle.fill", color: "#96CEB4", description: "Brand deals, endorsements, NIL"),
                HabitTemplate(name: "Contract/Career", icon: "doc.text.fill", color: "#FFEAA7", description: "Agent talks, contract negotiations")
            ]
        case .gameDeveloper:
            return [
                HabitTemplate(name: "Code/Build", icon: "chevron.left.forwardslash.chevron.right", color: "#66CC66", description: "Work on your game"),
                HabitTemplate(name: "Design/Plan", icon: "pencil.and.ruler.fill", color: "#FF6B6B", description: "Game design, documentation"),
                HabitTemplate(name: "Art/Assets", icon: "paintbrush.fill", color: "#4ECDC4", description: "Create or source game assets"),
                HabitTemplate(name: "Playtest", icon: "gamecontroller.fill", color: "#45B7D1", description: "Test your game, find bugs"),
                HabitTemplate(name: "Monetization", icon: "dollarsign.circle.fill", color: "#96CEB4", description: "Pricing, IAPs, Steam page, publisher talks"),
                HabitTemplate(name: "Marketing", icon: "megaphone.fill", color: "#FFEAA7", description: "Wishlists, devlogs, social media")
            ]
        case .writer:
            return [
                HabitTemplate(name: "Write Pages", icon: "pencil.line", color: "#996633", description: "Write screenplay, novel, or blog pages"),
                HabitTemplate(name: "Read/Watch", icon: "book.fill", color: "#FF6B6B", description: "Study scripts, books, films in your genre"),
                HabitTemplate(name: "Edit/Revise", icon: "pencil.and.outline", color: "#4ECDC4", description: "Rewrite and polish your drafts"),
                HabitTemplate(name: "Submit/Pitch", icon: "paperplane.fill", color: "#45B7D1", description: "Query agents, enter contests, pitch producers"),
                HabitTemplate(name: "Study Craft", icon: "theatermasks.fill", color: "#9B59B6", description: "Learn structure, dialogue, character arcs"),
                HabitTemplate(name: "Network", icon: "person.3.fill", color: "#FFEAA7", description: "Connect with writers, agents, industry")
            ]
        case .parent:
            return [
                HabitTemplate(name: "Quality Time", icon: "figure.and.child.holdinghands", color: "#FFBB88", description: "Focused time with kids"),
                HabitTemplate(name: "Read Together", icon: "book.fill", color: "#FF6B6B", description: "Read to/with your children"),
                HabitTemplate(name: "Self-Care", icon: "heart.fill", color: "#4ECDC4", description: "Take care of yourself too"),
                HabitTemplate(name: "Family Meal", icon: "fork.knife", color: "#45B7D1", description: "Eat together as a family"),
                HabitTemplate(name: "Family Budget", icon: "dollarsign.circle.fill", color: "#96CEB4", description: "Track expenses, save for kids' future"),
                HabitTemplate(name: "College Fund", icon: "banknote.fill", color: "#FFEAA7", description: "529 contribution, education savings")
            ]
        case .digitalNomad:
            return [
                HabitTemplate(name: "Deep Work", icon: "laptopcomputer", color: "#33CCCC", description: "Focused work session"),
                HabitTemplate(name: "Client/Project Work", icon: "briefcase.fill", color: "#FF6B6B", description: "Billable work or main project"),
                HabitTemplate(name: "Explore Local", icon: "map.fill", color: "#4ECDC4", description: "Discover your current location"),
                HabitTemplate(name: "Track Income", icon: "dollarsign.circle.fill", color: "#45B7D1", description: "Monitor client payments, invoices"),
                HabitTemplate(name: "Savings/Emergency", icon: "banknote.fill", color: "#96CEB4", description: "Save for emergencies, travel fund"),
                HabitTemplate(name: "Find New Clients", icon: "person.badge.plus", color: "#FFEAA7", description: "Outreach, proposals, networking")
            ]
        case .electrician:
            return [
                HabitTemplate(name: "Study NEC Code", icon: "book.fill", color: "#FFCC00", description: "Review electrical codes and standards"),
                HabitTemplate(name: "Practice Wiring", icon: "bolt.fill", color: "#FF6B6B", description: "Hands-on electrical work"),
                HabitTemplate(name: "Tool Maintenance", icon: "wrench.fill", color: "#4ECDC4", description: "Clean and organize tools"),
                HabitTemplate(name: "Safety Training", icon: "exclamationmark.shield.fill", color: "#45B7D1", description: "Review safety procedures"),
                HabitTemplate(name: "Certification Study", icon: "checkmark.seal.fill", color: "#96CEB4", description: "Work toward journeyman/master license"),
                HabitTemplate(name: "Track Jobs/Income", icon: "dollarsign.circle.fill", color: "#FFEAA7", description: "Log completed work and earnings")
            ]
        case .plumber:
            return [
                HabitTemplate(name: "Study Plumbing Code", icon: "book.fill", color: "#0080CC", description: "Review IPC/UPC codes"),
                HabitTemplate(name: "Practice Installations", icon: "wrench.and.screwdriver.fill", color: "#FF6B6B", description: "Hands-on pipe work"),
                HabitTemplate(name: "Tool Inventory", icon: "archivebox.fill", color: "#4ECDC4", description: "Maintain and stock tools"),
                HabitTemplate(name: "Customer Service", icon: "person.fill.checkmark", color: "#45B7D1", description: "Follow up with clients"),
                HabitTemplate(name: "License Prep", icon: "checkmark.seal.fill", color: "#96CEB4", description: "Study for journeyman/master exam"),
                HabitTemplate(name: "Track Jobs/Income", icon: "dollarsign.circle.fill", color: "#FFEAA7", description: "Log jobs and earnings")
            ]
        case .welder:
            return [
                HabitTemplate(name: "Practice Welds", icon: "flame.fill", color: "#FF6600", description: "MIG, TIG, or stick welding practice"),
                HabitTemplate(name: "Blueprint Reading", icon: "doc.text.fill", color: "#FF6B6B", description: "Study welding symbols and drawings"),
                HabitTemplate(name: "Safety Check", icon: "exclamationmark.shield.fill", color: "#4ECDC4", description: "Inspect PPE and equipment"),
                HabitTemplate(name: "Certification Prep", icon: "checkmark.seal.fill", color: "#45B7D1", description: "AWS certification study"),
                HabitTemplate(name: "Metal Prep Skills", icon: "hammer.fill", color: "#96CEB4", description: "Grinding, cutting, fitting practice"),
                HabitTemplate(name: "Track Jobs/Income", icon: "dollarsign.circle.fill", color: "#FFEAA7", description: "Log projects and pay")
            ]
        case .construction:
            return [
                HabitTemplate(name: "Jobsite Work", icon: "hammer.fill", color: "#CC8833", description: "On-site construction tasks"),
                HabitTemplate(name: "Blueprint Study", icon: "doc.text.fill", color: "#FF6B6B", description: "Read and understand plans"),
                HabitTemplate(name: "Tool Maintenance", icon: "wrench.fill", color: "#4ECDC4", description: "Care for your equipment"),
                HabitTemplate(name: "Safety Training", icon: "exclamationmark.shield.fill", color: "#45B7D1", description: "OSHA compliance and best practices"),
                HabitTemplate(name: "Physical Fitness", icon: "figure.strengthtraining.traditional", color: "#96CEB4", description: "Stay strong for the job"),
                HabitTemplate(name: "Track Hours/Pay", icon: "dollarsign.circle.fill", color: "#FFEAA7", description: "Log hours and earnings")
            ]
        case .hvacTech:
            return [
                HabitTemplate(name: "System Diagnostics", icon: "thermometer.snowflake", color: "#4DB8E8", description: "Practice troubleshooting"),
                HabitTemplate(name: "EPA Certification", icon: "checkmark.seal.fill", color: "#FF6B6B", description: "Study for 608/609 certification"),
                HabitTemplate(name: "Tool Calibration", icon: "gauge.with.needle.fill", color: "#4ECDC4", description: "Maintain measuring equipment"),
                HabitTemplate(name: "Code Study", icon: "book.fill", color: "#45B7D1", description: "HVAC codes and refrigerant handling"),
                HabitTemplate(name: "Customer Calls", icon: "phone.fill", color: "#96CEB4", description: "Service calls and follow-ups"),
                HabitTemplate(name: "Track Jobs/Income", icon: "dollarsign.circle.fill", color: "#FFEAA7", description: "Log service calls and pay")
            ]
        case .carpenter:
            return [
                HabitTemplate(name: "Build/Practice", icon: "ruler.fill", color: "#996633", description: "Hands-on carpentry work"),
                HabitTemplate(name: "Blueprint Reading", icon: "doc.text.fill", color: "#FF6B6B", description: "Study construction drawings"),
                HabitTemplate(name: "Tool Sharpening", icon: "scissors", color: "#4ECDC4", description: "Maintain cutting tools"),
                HabitTemplate(name: "Measure & Layout", icon: "ruler.fill", color: "#45B7D1", description: "Practice precision measuring"),
                HabitTemplate(name: "Finish Work", icon: "paintbrush.fill", color: "#96CEB4", description: "Trim, molding, detail work"),
                HabitTemplate(name: "Track Projects/Pay", icon: "dollarsign.circle.fill", color: "#FFEAA7", description: "Log projects and income")
            ]
        case .mechanic:
            return [
                HabitTemplate(name: "Diagnostic Practice", icon: "car.fill", color: "#4D4D4D", description: "Troubleshoot vehicle issues"),
                HabitTemplate(name: "ASE Study", icon: "book.fill", color: "#FF6B6B", description: "Certification exam prep"),
                HabitTemplate(name: "Tool Organization", icon: "wrench.fill", color: "#4ECDC4", description: "Maintain your toolbox"),
                HabitTemplate(name: "Technical Reading", icon: "doc.text.fill", color: "#45B7D1", description: "Study service manuals"),
                HabitTemplate(name: "Hands-On Repair", icon: "wrench.and.screwdriver.fill", color: "#96CEB4", description: "Practice repairs and maintenance"),
                HabitTemplate(name: "Track Jobs/Income", icon: "dollarsign.circle.fill", color: "#FFEAA7", description: "Log repairs and flat rate hours")
            ]
        case .truckDriver:
            return [
                HabitTemplate(name: "Pre-Trip Inspection", icon: "checklist", color: "#663399", description: "Safety check before driving"),
                HabitTemplate(name: "Drive Hours", icon: "truck.box.fill", color: "#FF6B6B", description: "Log driving time"),
                HabitTemplate(name: "CDL Study", icon: "book.fill", color: "#4ECDC4", description: "Endorsement and renewal prep"),
                HabitTemplate(name: "Health & Fitness", icon: "heart.fill", color: "#45B7D1", description: "Stay healthy on the road"),
                HabitTemplate(name: "Route Planning", icon: "map.fill", color: "#96CEB4", description: "Plan efficient routes"),
                HabitTemplate(name: "Track Miles/Pay", icon: "dollarsign.circle.fill", color: "#FFEAA7", description: "Log loads and earnings")
            ]
        case .nurse:
            return [
                HabitTemplate(name: "Clinical Skills", icon: "cross.case.fill", color: "#E6667A", description: "Practice nursing procedures"),
                HabitTemplate(name: "Study/CEUs", icon: "book.fill", color: "#FF6B6B", description: "Continuing education"),
                HabitTemplate(name: "Self-Care", icon: "heart.fill", color: "#4ECDC4", description: "Rest and recovery"),
                HabitTemplate(name: "Patient Notes", icon: "doc.text.fill", color: "#45B7D1", description: "Documentation practice"),
                HabitTemplate(name: "Certification Prep", icon: "checkmark.seal.fill", color: "#96CEB4", description: "Specialty certifications"),
                HabitTemplate(name: "Track Shifts/Pay", icon: "dollarsign.circle.fill", color: "#FFEAA7", description: "Log hours and overtime")
            ]
        case .emt:
            return [
                HabitTemplate(name: "Protocol Review", icon: "staroflife.fill", color: "#FF3333", description: "Study emergency protocols"),
                HabitTemplate(name: "Skills Practice", icon: "heart.fill", color: "#FF6B6B", description: "CPR, IVs, intubation"),
                HabitTemplate(name: "Physical Fitness", icon: "figure.run", color: "#4ECDC4", description: "Stay in shape for the job"),
                HabitTemplate(name: "Equipment Check", icon: "checklist", color: "#45B7D1", description: "Inspect and stock gear"),
                HabitTemplate(name: "Paramedic Study", icon: "book.fill", color: "#96CEB4", description: "Advance your certification"),
                HabitTemplate(name: "Track Shifts", icon: "dollarsign.circle.fill", color: "#FFEAA7", description: "Log hours and calls")
            ]
        case .physicalTherapist:
            return [
                HabitTemplate(name: "Patient Sessions", icon: "figure.walk", color: "#66B380", description: "Therapy appointments"),
                HabitTemplate(name: "Treatment Planning", icon: "doc.text.fill", color: "#FF6B6B", description: "Design recovery programs"),
                HabitTemplate(name: "CEU Courses", icon: "book.fill", color: "#4ECDC4", description: "Continuing education"),
                HabitTemplate(name: "Manual Techniques", icon: "hand.raised.fill", color: "#45B7D1", description: "Practice hands-on skills"),
                HabitTemplate(name: "Documentation", icon: "pencil.and.list.clipboard", color: "#96CEB4", description: "Patient notes and billing"),
                HabitTemplate(name: "Track Revenue", icon: "dollarsign.circle.fill", color: "#FFEAA7", description: "Monitor billing and income")
            ]
        case .dentalPro:
            return [
                HabitTemplate(name: "Patient Care", icon: "mouth.fill", color: "#99CCE6", description: "Cleanings and procedures"),
                HabitTemplate(name: "Study/CEUs", icon: "book.fill", color: "#FF6B6B", description: "Continuing education"),
                HabitTemplate(name: "Instrument Care", icon: "wrench.fill", color: "#4ECDC4", description: "Sterilization and maintenance"),
                HabitTemplate(name: "Patient Education", icon: "person.fill.questionmark", color: "#45B7D1", description: "Teach oral hygiene"),
                HabitTemplate(name: "Practice Skills", icon: "hand.raised.fill", color: "#96CEB4", description: "Improve technique"),
                HabitTemplate(name: "Track Production", icon: "dollarsign.circle.fill", color: "#FFEAA7", description: "Log procedures and revenue")
            ]
        case .teacher:
            return [
                HabitTemplate(name: "Lesson Planning", icon: "doc.text.fill", color: "#CC6666", description: "Prepare engaging lessons"),
                HabitTemplate(name: "Grading", icon: "checkmark.circle.fill", color: "#FF6B6B", description: "Assess student work"),
                HabitTemplate(name: "Professional Development", icon: "book.fill", color: "#4ECDC4", description: "Learn new teaching methods"),
                HabitTemplate(name: "Student Check-ins", icon: "person.2.fill", color: "#45B7D1", description: "Connect with students"),
                HabitTemplate(name: "Classroom Prep", icon: "desktopcomputer", color: "#96CEB4", description: "Organize materials"),
                HabitTemplate(name: "Side Income", icon: "dollarsign.circle.fill", color: "#FFEAA7", description: "Tutoring, summer work")
            ]
        case .lawyer:
            return [
                HabitTemplate(name: "Case Research", icon: "magnifyingglass", color: "#4D4D80", description: "Legal research and prep"),
                HabitTemplate(name: "Client Work", icon: "person.fill", color: "#FF6B6B", description: "Client calls and meetings"),
                HabitTemplate(name: "Brief Writing", icon: "doc.text.fill", color: "#4ECDC4", description: "Draft legal documents"),
                HabitTemplate(name: "CLE Credits", icon: "book.fill", color: "#45B7D1", description: "Continuing legal education"),
                HabitTemplate(name: "Court Prep", icon: "building.columns.fill", color: "#96CEB4", description: "Prepare for appearances"),
                HabitTemplate(name: "Track Billables", icon: "dollarsign.circle.fill", color: "#FFEAA7", description: "Log billable hours")
            ]
        case .realEstate:
            return [
                HabitTemplate(name: "Prospecting", icon: "phone.fill", color: "#009966", description: "Lead generation calls"),
                HabitTemplate(name: "Showings", icon: "house.fill", color: "#FF6B6B", description: "Property tours"),
                HabitTemplate(name: "Follow-Ups", icon: "envelope.fill", color: "#4ECDC4", description: "Client communication"),
                HabitTemplate(name: "Market Research", icon: "chart.bar.fill", color: "#45B7D1", description: "Study local market trends"),
                HabitTemplate(name: "CE Courses", icon: "book.fill", color: "#96CEB4", description: "License renewal education"),
                HabitTemplate(name: "Track Deals", icon: "dollarsign.circle.fill", color: "#FFEAA7", description: "Pipeline and commissions")
            ]
        case .chef:
            return [
                HabitTemplate(name: "Prep Work", icon: "frying.pan.fill", color: "#E68019", description: "Kitchen prep and mise en place"),
                HabitTemplate(name: "Recipe Development", icon: "doc.text.fill", color: "#FF6B6B", description: "Create and test dishes"),
                HabitTemplate(name: "Skill Practice", icon: "flame.fill", color: "#4ECDC4", description: "Master techniques"),
                HabitTemplate(name: "Inventory/Ordering", icon: "cart.fill", color: "#45B7D1", description: "Manage supplies"),
                HabitTemplate(name: "Food Cost Review", icon: "chart.bar.fill", color: "#96CEB4", description: "Track food costs"),
                HabitTemplate(name: "Revenue/Tips", icon: "dollarsign.circle.fill", color: "#FFEAA7", description: "Track earnings")
            ]
        case .pilot:
            return [
                HabitTemplate(name: "Flight Hours", icon: "airplane", color: "#3366B3", description: "Log flight time"),
                HabitTemplate(name: "Ground School", icon: "book.fill", color: "#FF6B6B", description: "Study regulations and procedures"),
                HabitTemplate(name: "Simulator Practice", icon: "desktopcomputer", color: "#4ECDC4", description: "Sim time for proficiency"),
                HabitTemplate(name: "Medical/Fitness", icon: "heart.fill", color: "#45B7D1", description: "Maintain flight medical"),
                HabitTemplate(name: "Checkride Prep", icon: "checkmark.seal.fill", color: "#96CEB4", description: "Certificate advancement"),
                HabitTemplate(name: "Track Income", icon: "dollarsign.circle.fill", color: "#FFEAA7", description: "Log pay and per diem")
            ]
        case .military:
            return [
                HabitTemplate(name: "PT/Fitness", icon: "figure.run", color: "#4D664D", description: "Physical training"),
                HabitTemplate(name: "MOS Training", icon: "shield.fill", color: "#FF6B6B", description: "Job-specific skills"),
                HabitTemplate(name: "Leadership Study", icon: "book.fill", color: "#4ECDC4", description: "Professional development"),
                HabitTemplate(name: "Gear Maintenance", icon: "wrench.fill", color: "#45B7D1", description: "Equipment readiness"),
                HabitTemplate(name: "Career Planning", icon: "chart.line.uptrend.xyaxis", color: "#96CEB4", description: "Promotion and transition"),
                HabitTemplate(name: "Savings/TSP", icon: "dollarsign.circle.fill", color: "#FFEAA7", description: "Financial planning")
            ]
        case .firstResponder:
            return [
                HabitTemplate(name: "Training Drills", icon: "flame.fill", color: "#CC1A1A", description: "Practice emergency response"),
                HabitTemplate(name: "Physical Fitness", icon: "figure.run", color: "#FF6B6B", description: "Stay in peak condition"),
                HabitTemplate(name: "Equipment Check", icon: "checklist", color: "#4ECDC4", description: "Inspect and maintain gear"),
                HabitTemplate(name: "Certification", icon: "checkmark.seal.fill", color: "#45B7D1", description: "Maintain required certs"),
                HabitTemplate(name: "Mental Health", icon: "brain.head.profile", color: "#96CEB4", description: "Self-care and wellness"),
                HabitTemplate(name: "Track OT/Pay", icon: "dollarsign.circle.fill", color: "#FFEAA7", description: "Log shifts and overtime")
            ]
        case .sales:
            return [
                HabitTemplate(name: "Prospecting", icon: "phone.fill", color: "#33B34D", description: "Cold calls and outreach"),
                HabitTemplate(name: "Follow-Ups", icon: "envelope.fill", color: "#FF6B6B", description: "Nurture leads"),
                HabitTemplate(name: "Demos/Meetings", icon: "person.2.fill", color: "#4ECDC4", description: "Present to prospects"),
                HabitTemplate(name: "CRM Updates", icon: "doc.text.fill", color: "#45B7D1", description: "Pipeline management"),
                HabitTemplate(name: "Product Knowledge", icon: "book.fill", color: "#96CEB4", description: "Know what you sell"),
                HabitTemplate(name: "Track Deals/Commission", icon: "dollarsign.circle.fill", color: "#FFEAA7", description: "Monitor pipeline and earnings")
            ]
        case .exploring:
            return [
                HabitTemplate(name: "Morning Routine", icon: "sunrise.fill", color: "#FFB347", description: "Start your day with intention"),
                HabitTemplate(name: "Exercise", icon: "figure.run", color: "#FF6B6B", description: "Move your body daily"),
                HabitTemplate(name: "Read/Learn", icon: "book.fill", color: "#4ECDC4", description: "Learn something new"),
                HabitTemplate(name: "Reflect/Journal", icon: "pencil.line", color: "#45B7D1", description: "Write down your thoughts"),
                HabitTemplate(name: "Connect", icon: "person.2.fill", color: "#96CEB4", description: "Reach out to someone"),
                HabitTemplate(name: "Plan Tomorrow", icon: "checklist", color: "#FFEAA7", description: "Set intentions for the next day")
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

// MARK: - Exploration Mode Habits

/// Generic habits for users who haven't chosen a path yet
struct ExplorationHabits {
    static let habits: [HabitTemplate] = [
        HabitTemplate(name: "Morning Routine", icon: "sunrise.fill", color: "#FFB347", description: "Start your day with intention"),
        HabitTemplate(name: "Exercise", icon: "figure.run", color: "#FF6B6B", description: "Move your body"),
        HabitTemplate(name: "Read/Learn", icon: "book.fill", color: "#4ECDC4", description: "Invest in your mind"),
        HabitTemplate(name: "Hydrate", icon: "drop.fill", color: "#45B7D1", description: "Drink enough water"),
        HabitTemplate(name: "Meditate", icon: "brain.head.profile", color: "#9B59B6", description: "Clear your mind"),
        HabitTemplate(name: "Journal", icon: "pencil.line", color: "#96CEB4", description: "Reflect on your day"),
        HabitTemplate(name: "Sleep 7+ Hours", icon: "moon.fill", color: "#5D5FEF", description: "Rest and recover"),
        HabitTemplate(name: "No Phone Hour", icon: "iphone.slash", color: "#E74C3C", description: "Digital detox time"),
        HabitTemplate(name: "Gratitude", icon: "heart.fill", color: "#E91E63", description: "Appreciate what you have"),
        HabitTemplate(name: "Connect", icon: "person.2.fill", color: "#00BCD4", description: "Reach out to someone")
    ]
}
