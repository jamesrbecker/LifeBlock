import Foundation
import SwiftUI

// MARK: - Sprint (Short-term Goal Accelerator)

struct Sprint: Identifiable, Codable {
    var id = UUID()
    var name: String
    var description: String
    var targetDate: Date
    var startDate: Date
    var icon: String
    var colorHex: String
    var category: SprintCategory
    var targetMetrics: [SprintMetric]
    var linkedHabits: [UUID] // Habit IDs that contribute to this sprint
    var isActive: Bool = true
    var isCompleted: Bool = false
    var completedDate: Date?

    var color: Color {
        Color(hex: colorHex)
    }

    var daysRemaining: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: targetDate).day ?? 0
    }

    var totalDays: Int {
        Calendar.current.dateComponents([.day], from: startDate, to: targetDate).day ?? 1
    }

    var progress: Double {
        let elapsed = Calendar.current.dateComponents([.day], from: startDate, to: Date()).day ?? 0
        return min(1.0, Double(elapsed) / Double(totalDays))
    }

    var durationDescription: String {
        let days = totalDays
        if days <= 7 { return "1 Week Sprint" }
        if days <= 14 { return "2 Week Sprint" }
        if days <= 30 { return "30 Day Sprint" }
        if days <= 60 { return "60 Day Sprint" }
        if days <= 90 { return "90 Day Sprint" }
        return "\(days) Day Sprint"
    }
}

struct SprintMetric: Identifiable, Codable {
    var id = UUID()
    var name: String
    var targetValue: Double
    var currentValue: Double
    var unit: String
    var icon: String

    var progress: Double {
        guard targetValue > 0 else { return 0 }
        return min(1.0, currentValue / targetValue)
    }

    var displayValue: String {
        if unit == "GPA" {
            return String(format: "%.2f", currentValue)
        } else if unit == "%" {
            return "\(Int(currentValue))%"
        } else if currentValue == floor(currentValue) {
            return "\(Int(currentValue)) \(unit)"
        }
        return String(format: "%.1f %@", currentValue, unit)
    }
}

enum SprintCategory: String, Codable, CaseIterable {
    case college = "college_admission"
    case career = "career_advancement"
    case fitness = "fitness_transformation"
    case financial = "financial_goal"
    case creative = "creative_project"
    case learning = "skill_learning"
    case health = "health_improvement"
    case custom = "custom"

    var displayName: String {
        switch self {
        case .college: return "College Admission"
        case .career: return "Career Advancement"
        case .fitness: return "Fitness Goal"
        case .financial: return "Financial Goal"
        case .creative: return "Creative Project"
        case .learning: return "Learn a Skill"
        case .health: return "Health Goal"
        case .custom: return "Custom Goal"
        }
    }

    var icon: String {
        switch self {
        case .college: return "graduationcap.fill"
        case .career: return "briefcase.fill"
        case .fitness: return "figure.run"
        case .financial: return "dollarsign.circle.fill"
        case .creative: return "paintbrush.fill"
        case .learning: return "brain.head.profile"
        case .health: return "heart.fill"
        case .custom: return "star.fill"
        }
    }

    var color: Color {
        switch self {
        case .college: return .blue
        case .career: return .purple
        case .fitness: return .orange
        case .financial: return .green
        case .creative: return .pink
        case .learning: return .cyan
        case .health: return .red
        case .custom: return .gray
        }
    }
}

// MARK: - College Data

struct CollegeInfo: Identifiable, Codable {
    var id = UUID()
    let name: String
    let shortName: String
    let acceptanceRate: Double // 0-100
    let avgGPA: Double
    let avgSAT: Int // Combined score
    let avgACT: Int
    let location: String
    let type: CollegeType
    let ranking: Int? // US News ranking
    let tuition: Int // Annual in-state or private
    let strongPrograms: [String]

    var difficulty: AdmissionDifficulty {
        if acceptanceRate < 10 { return .mostSelective }
        if acceptanceRate < 20 { return .highlySelective }
        if acceptanceRate < 35 { return .verySelective }
        if acceptanceRate < 50 { return .selective }
        return .moderatelySelective
    }

    var gpaDescription: String {
        String(format: "%.2f+ GPA", avgGPA)
    }

    var satDescription: String {
        "\(avgSAT)+ SAT"
    }
}

enum CollegeType: String, Codable, CaseIterable {
    case ivyLeague = "ivy_league"
    case privateElite = "private_elite"
    case publicFlagship = "public_flagship"
    case liberalArts = "liberal_arts"
    case techFocused = "tech_focused"
    case stateSchool = "state_school"
    case communityCollege = "community_college"

    var displayName: String {
        switch self {
        case .ivyLeague: return "Ivy League"
        case .privateElite: return "Elite Private"
        case .publicFlagship: return "Public Flagship"
        case .liberalArts: return "Liberal Arts"
        case .techFocused: return "Tech-Focused"
        case .stateSchool: return "State School"
        case .communityCollege: return "Community College"
        }
    }
}

enum AdmissionDifficulty: String, Codable {
    case mostSelective = "most_selective"
    case highlySelective = "highly_selective"
    case verySelective = "very_selective"
    case selective = "selective"
    case moderatelySelective = "moderately_selective"

    var displayName: String {
        switch self {
        case .mostSelective: return "Most Selective"
        case .highlySelective: return "Highly Selective"
        case .verySelective: return "Very Selective"
        case .selective: return "Selective"
        case .moderatelySelective: return "Moderately Selective"
        }
    }

    var color: Color {
        switch self {
        case .mostSelective: return .red
        case .highlySelective: return .orange
        case .verySelective: return .yellow
        case .selective: return .green
        case .moderatelySelective: return .blue
        }
    }
}

// MARK: - College Database

struct CollegeDatabase {
    static let colleges: [CollegeInfo] = [
        // Ivy League
        CollegeInfo(name: "Harvard University", shortName: "Harvard", acceptanceRate: 3.2, avgGPA: 4.18, avgSAT: 1530, avgACT: 34, location: "Cambridge, MA", type: .ivyLeague, ranking: 3, tuition: 57261, strongPrograms: ["Business", "Law", "Medicine", "Government"]),
        CollegeInfo(name: "Yale University", shortName: "Yale", acceptanceRate: 4.5, avgGPA: 4.14, avgSAT: 1530, avgACT: 34, location: "New Haven, CT", type: .ivyLeague, ranking: 5, tuition: 62250, strongPrograms: ["Law", "Drama", "History", "Political Science"]),
        CollegeInfo(name: "Princeton University", shortName: "Princeton", acceptanceRate: 4.0, avgGPA: 4.14, avgSAT: 1540, avgACT: 34, location: "Princeton, NJ", type: .ivyLeague, ranking: 1, tuition: 59710, strongPrograms: ["Engineering", "Economics", "Public Policy", "Mathematics"]),
        CollegeInfo(name: "Columbia University", shortName: "Columbia", acceptanceRate: 3.9, avgGPA: 4.12, avgSAT: 1520, avgACT: 34, location: "New York, NY", type: .ivyLeague, ranking: 12, tuition: 65524, strongPrograms: ["Journalism", "Business", "Law", "Film"]),
        CollegeInfo(name: "University of Pennsylvania", shortName: "Penn", acceptanceRate: 5.9, avgGPA: 4.10, avgSAT: 1520, avgACT: 34, location: "Philadelphia, PA", type: .ivyLeague, ranking: 6, tuition: 63452, strongPrograms: ["Business (Wharton)", "Nursing", "Engineering"]),
        CollegeInfo(name: "Brown University", shortName: "Brown", acceptanceRate: 5.1, avgGPA: 4.08, avgSAT: 1510, avgACT: 34, location: "Providence, RI", type: .ivyLeague, ranking: 9, tuition: 65146, strongPrograms: ["Computer Science", "Biology", "Economics"]),
        CollegeInfo(name: "Dartmouth College", shortName: "Dartmouth", acceptanceRate: 6.2, avgGPA: 4.07, avgSAT: 1510, avgACT: 34, location: "Hanover, NH", type: .ivyLeague, ranking: 18, tuition: 62658, strongPrograms: ["Economics", "Government", "Engineering"]),
        CollegeInfo(name: "Cornell University", shortName: "Cornell", acceptanceRate: 7.3, avgGPA: 4.05, avgSAT: 1500, avgACT: 34, location: "Ithaca, NY", type: .ivyLeague, ranking: 12, tuition: 63200, strongPrograms: ["Engineering", "Agriculture", "Hotel Administration", "Architecture"]),

        // Elite Private
        CollegeInfo(name: "Stanford University", shortName: "Stanford", acceptanceRate: 3.7, avgGPA: 4.18, avgSAT: 1540, avgACT: 35, location: "Stanford, CA", type: .privateElite, ranking: 3, tuition: 61731, strongPrograms: ["Computer Science", "Engineering", "Business", "Medicine"]),
        CollegeInfo(name: "Massachusetts Institute of Technology", shortName: "MIT", acceptanceRate: 3.9, avgGPA: 4.17, avgSAT: 1545, avgACT: 35, location: "Cambridge, MA", type: .techFocused, ranking: 2, tuition: 59750, strongPrograms: ["Engineering", "Computer Science", "Physics", "Mathematics"]),
        CollegeInfo(name: "California Institute of Technology", shortName: "Caltech", acceptanceRate: 2.7, avgGPA: 4.19, avgSAT: 1555, avgACT: 36, location: "Pasadena, CA", type: .techFocused, ranking: 7, tuition: 60864, strongPrograms: ["Physics", "Engineering", "Computer Science", "Chemistry"]),
        CollegeInfo(name: "Duke University", shortName: "Duke", acceptanceRate: 6.0, avgGPA: 4.10, avgSAT: 1520, avgACT: 34, location: "Durham, NC", type: .privateElite, ranking: 7, tuition: 63054, strongPrograms: ["Business", "Public Policy", "Engineering", "Basketball"]),
        CollegeInfo(name: "Northwestern University", shortName: "Northwestern", acceptanceRate: 7.0, avgGPA: 4.08, avgSAT: 1510, avgACT: 34, location: "Evanston, IL", type: .privateElite, ranking: 9, tuition: 63468, strongPrograms: ["Journalism", "Theater", "Engineering", "Business"]),
        CollegeInfo(name: "University of Chicago", shortName: "UChicago", acceptanceRate: 5.4, avgGPA: 4.12, avgSAT: 1530, avgACT: 34, location: "Chicago, IL", type: .privateElite, ranking: 12, tuition: 64260, strongPrograms: ["Economics", "Mathematics", "Physics", "Sociology"]),
        CollegeInfo(name: "Johns Hopkins University", shortName: "Johns Hopkins", acceptanceRate: 7.5, avgGPA: 4.05, avgSAT: 1520, avgACT: 34, location: "Baltimore, MD", type: .privateElite, ranking: 9, tuition: 60480, strongPrograms: ["Medicine", "Public Health", "Biomedical Engineering", "International Relations"]),
        CollegeInfo(name: "Vanderbilt University", shortName: "Vanderbilt", acceptanceRate: 6.7, avgGPA: 4.04, avgSAT: 1510, avgACT: 34, location: "Nashville, TN", type: .privateElite, ranking: 18, tuition: 60348, strongPrograms: ["Education", "Medicine", "Music", "Engineering"]),
        CollegeInfo(name: "Rice University", shortName: "Rice", acceptanceRate: 8.7, avgGPA: 4.03, avgSAT: 1520, avgACT: 34, location: "Houston, TX", type: .privateElite, ranking: 17, tuition: 56874, strongPrograms: ["Engineering", "Architecture", "Music", "Business"]),
        CollegeInfo(name: "University of Notre Dame", shortName: "Notre Dame", acceptanceRate: 12.9, avgGPA: 4.02, avgSAT: 1480, avgACT: 34, location: "Notre Dame, IN", type: .privateElite, ranking: 20, tuition: 60301, strongPrograms: ["Business", "Engineering", "Political Science", "Theology"]),

        // Tech-Focused
        CollegeInfo(name: "Carnegie Mellon University", shortName: "CMU", acceptanceRate: 11.0, avgGPA: 4.00, avgSAT: 1520, avgACT: 34, location: "Pittsburgh, PA", type: .techFocused, ranking: 22, tuition: 61344, strongPrograms: ["Computer Science", "Robotics", "Drama", "Business"]),
        CollegeInfo(name: "Georgia Institute of Technology", shortName: "Georgia Tech", acceptanceRate: 17.0, avgGPA: 4.07, avgSAT: 1450, avgACT: 33, location: "Atlanta, GA", type: .techFocused, ranking: 33, tuition: 32876, strongPrograms: ["Engineering", "Computer Science", "Business", "Design"]),

        // Public Flagships
        CollegeInfo(name: "University of California, Berkeley", shortName: "UC Berkeley", acceptanceRate: 11.6, avgGPA: 4.00, avgSAT: 1440, avgACT: 32, location: "Berkeley, CA", type: .publicFlagship, ranking: 15, tuition: 44066, strongPrograms: ["Engineering", "Computer Science", "Business", "Chemistry"]),
        CollegeInfo(name: "University of California, Los Angeles", shortName: "UCLA", acceptanceRate: 8.8, avgGPA: 4.00, avgSAT: 1420, avgACT: 32, location: "Los Angeles, CA", type: .publicFlagship, ranking: 15, tuition: 44830, strongPrograms: ["Film", "Medicine", "Engineering", "Psychology"]),
        CollegeInfo(name: "University of Michigan", shortName: "Michigan", acceptanceRate: 18.0, avgGPA: 3.92, avgSAT: 1440, avgACT: 33, location: "Ann Arbor, MI", type: .publicFlagship, ranking: 21, tuition: 57273, strongPrograms: ["Business", "Engineering", "Law", "Medicine"]),
        CollegeInfo(name: "University of Virginia", shortName: "UVA", acceptanceRate: 19.0, avgGPA: 4.00, avgSAT: 1420, avgACT: 33, location: "Charlottesville, VA", type: .publicFlagship, ranking: 24, tuition: 55914, strongPrograms: ["Business", "Law", "English", "History"]),
        CollegeInfo(name: "University of North Carolina at Chapel Hill", shortName: "UNC", acceptanceRate: 17.0, avgGPA: 4.00, avgSAT: 1380, avgACT: 31, location: "Chapel Hill, NC", type: .publicFlagship, ranking: 22, tuition: 37558, strongPrograms: ["Business", "Journalism", "Public Health", "Chemistry"]),
        CollegeInfo(name: "University of Texas at Austin", shortName: "UT Austin", acceptanceRate: 29.0, avgGPA: 3.85, avgSAT: 1360, avgACT: 30, location: "Austin, TX", type: .publicFlagship, ranking: 32, tuition: 40996, strongPrograms: ["Business", "Engineering", "Computer Science", "Communications"]),
        CollegeInfo(name: "University of Florida", shortName: "UF", acceptanceRate: 23.0, avgGPA: 4.00, avgSAT: 1380, avgACT: 31, location: "Gainesville, FL", type: .publicFlagship, ranking: 28, tuition: 28658, strongPrograms: ["Business", "Engineering", "Agriculture", "Journalism"]),
        CollegeInfo(name: "University of Wisconsin-Madison", shortName: "Wisconsin", acceptanceRate: 49.0, avgGPA: 3.85, avgSAT: 1380, avgACT: 30, location: "Madison, WI", type: .publicFlagship, ranking: 35, tuition: 39427, strongPrograms: ["Business", "Engineering", "Agriculture", "Political Science"]),
        CollegeInfo(name: "Ohio State University", shortName: "Ohio State", acceptanceRate: 53.0, avgGPA: 3.80, avgSAT: 1330, avgACT: 29, location: "Columbus, OH", type: .publicFlagship, ranking: 43, tuition: 35019, strongPrograms: ["Business", "Engineering", "Medicine", "Sports"]),
        CollegeInfo(name: "Penn State University", shortName: "Penn State", acceptanceRate: 55.0, avgGPA: 3.70, avgSAT: 1280, avgACT: 28, location: "State College, PA", type: .publicFlagship, ranking: 60, tuition: 36476, strongPrograms: ["Engineering", "Business", "Agriculture", "Education"]),

        // Liberal Arts
        CollegeInfo(name: "Williams College", shortName: "Williams", acceptanceRate: 9.0, avgGPA: 4.05, avgSAT: 1490, avgACT: 33, location: "Williamstown, MA", type: .liberalArts, ranking: 1, tuition: 62940, strongPrograms: ["Economics", "Art History", "English", "Political Science"]),
        CollegeInfo(name: "Amherst College", shortName: "Amherst", acceptanceRate: 7.3, avgGPA: 4.04, avgSAT: 1490, avgACT: 33, location: "Amherst, MA", type: .liberalArts, ranking: 2, tuition: 62840, strongPrograms: ["Economics", "Political Science", "English", "Mathematics"]),
        CollegeInfo(name: "Pomona College", shortName: "Pomona", acceptanceRate: 7.0, avgGPA: 4.02, avgSAT: 1480, avgACT: 33, location: "Claremont, CA", type: .liberalArts, ranking: 4, tuition: 60778, strongPrograms: ["Economics", "Computer Science", "Biology", "Politics"]),
        CollegeInfo(name: "Swarthmore College", shortName: "Swarthmore", acceptanceRate: 7.0, avgGPA: 4.00, avgSAT: 1480, avgACT: 33, location: "Swarthmore, PA", type: .liberalArts, ranking: 4, tuition: 60934, strongPrograms: ["Engineering", "Economics", "Political Science", "Biology"]),

        // State Schools (More Accessible)
        CollegeInfo(name: "Arizona State University", shortName: "ASU", acceptanceRate: 88.0, avgGPA: 3.50, avgSAT: 1210, avgACT: 25, location: "Tempe, AZ", type: .stateSchool, ranking: 105, tuition: 32227, strongPrograms: ["Business", "Engineering", "Journalism", "Education"]),
        CollegeInfo(name: "University of Arizona", shortName: "Arizona", acceptanceRate: 87.0, avgGPA: 3.40, avgSAT: 1200, avgACT: 25, location: "Tucson, AZ", type: .stateSchool, ranking: 105, tuition: 28217, strongPrograms: ["Astronomy", "Business", "Engineering", "Medicine"]),
        CollegeInfo(name: "San Diego State University", shortName: "SDSU", acceptanceRate: 39.0, avgGPA: 3.75, avgSAT: 1230, avgACT: 26, location: "San Diego, CA", type: .stateSchool, ranking: 151, tuition: 24396, strongPrograms: ["Business", "Engineering", "Psychology", "Criminal Justice"]),

        // Community College (Pathway)
        CollegeInfo(name: "Santa Monica College", shortName: "SMC", acceptanceRate: 100.0, avgGPA: 2.50, avgSAT: 0, avgACT: 0, location: "Santa Monica, CA", type: .communityCollege, ranking: nil, tuition: 9752, strongPrograms: ["Transfer to UC/CSU", "Business", "Nursing", "Film"]),
        CollegeInfo(name: "De Anza College", shortName: "De Anza", acceptanceRate: 100.0, avgGPA: 2.50, avgSAT: 0, avgACT: 0, location: "Cupertino, CA", type: .communityCollege, ranking: nil, tuition: 9200, strongPrograms: ["Transfer to UC/CSU", "Computer Science", "Business", "Biology"]),
    ]

    static func search(query: String) -> [CollegeInfo] {
        let lowercased = query.lowercased()
        return colleges.filter {
            $0.name.lowercased().contains(lowercased) ||
            $0.shortName.lowercased().contains(lowercased) ||
            $0.location.lowercased().contains(lowercased)
        }
    }

    static func byDifficulty(_ difficulty: AdmissionDifficulty) -> [CollegeInfo] {
        colleges.filter { $0.difficulty == difficulty }
    }

    static func byType(_ type: CollegeType) -> [CollegeInfo] {
        colleges.filter { $0.type == type }
    }

    static func recommended(forGPA gpa: Double, satScore: Int?) -> [CollegeInfo] {
        colleges.filter { college in
            let gpaMatch = gpa >= (college.avgGPA - 0.3)
            if let sat = satScore {
                let satMatch = sat >= (college.avgSAT - 100)
                return gpaMatch && satMatch
            }
            return gpaMatch
        }.sorted { $0.ranking ?? 999 < $1.ranking ?? 999 }
    }
}

// MARK: - Career Advancement Levels

struct CareerLevel: Identifiable, Codable {
    var id = UUID()
    let title: String
    let level: Int // 1-10
    let salaryRange: ClosedRange<Int>
    let yearsExperience: ClosedRange<Int>
    let skills: [String]
    let nextLevel: String?
    let habits: [HabitTemplate]
}

struct CareerPath: Identifiable, Codable {
    var id = UUID()
    let name: String
    let icon: String
    let colorHex: String
    let levels: [CareerLevel]

    var color: Color {
        Color(hex: colorHex)
    }
}

struct CareerDatabase {
    static let paths: [CareerPath] = [
        // Software Engineering
        CareerPath(
            name: "Software Engineering",
            icon: "chevron.left.forwardslash.chevron.right",
            colorHex: "#45B7D1",
            levels: [
                CareerLevel(title: "Junior Developer", level: 1, salaryRange: 60000...85000, yearsExperience: 0...2, skills: ["Basic coding", "Git", "Problem solving"], nextLevel: "Mid-Level Developer", habits: [
                    HabitTemplate(name: "Code Daily", icon: "chevron.left.forwardslash.chevron.right", color: "#45B7D1", description: "Write code every day"),
                    HabitTemplate(name: "LeetCode Problem", icon: "brain.head.profile", color: "#FF6B6B", description: "Solve one coding problem"),
                    HabitTemplate(name: "Read Tech Article", icon: "doc.text", color: "#4ECDC4", description: "Stay current with tech trends")
                ]),
                CareerLevel(title: "Mid-Level Developer", level: 2, salaryRange: 85000...120000, yearsExperience: 2...5, skills: ["System design", "Code review", "Mentoring"], nextLevel: "Senior Developer", habits: [
                    HabitTemplate(name: "System Design Study", icon: "square.grid.3x3", color: "#45B7D1", description: "Learn architecture patterns"),
                    HabitTemplate(name: "Code Review", icon: "eye", color: "#FF6B6B", description: "Review peer code"),
                    HabitTemplate(name: "Mentor Session", icon: "person.2", color: "#4ECDC4", description: "Help junior developers")
                ]),
                CareerLevel(title: "Senior Developer", level: 3, salaryRange: 120000...170000, yearsExperience: 5...8, skills: ["Architecture", "Leadership", "Cross-team collaboration"], nextLevel: "Staff Engineer", habits: [
                    HabitTemplate(name: "Architecture Work", icon: "building.2", color: "#45B7D1", description: "Design system architecture"),
                    HabitTemplate(name: "Cross-Team Collab", icon: "person.3", color: "#FF6B6B", description: "Work with other teams"),
                    HabitTemplate(name: "Technical Writing", icon: "doc.text", color: "#4ECDC4", description: "Document decisions")
                ]),
                CareerLevel(title: "Staff Engineer", level: 4, salaryRange: 170000...250000, yearsExperience: 8...12, skills: ["Technical strategy", "Org-wide impact", "Influence"], nextLevel: "Principal Engineer", habits: [
                    HabitTemplate(name: "Strategic Planning", icon: "map", color: "#45B7D1", description: "Plan technical direction"),
                    HabitTemplate(name: "Stakeholder Meeting", icon: "person.crop.circle.badge.checkmark", color: "#FF6B6B", description: "Align with leadership"),
                    HabitTemplate(name: "Industry Research", icon: "magnifyingglass", color: "#4ECDC4", description: "Research industry trends")
                ]),
                CareerLevel(title: "Principal Engineer", level: 5, salaryRange: 250000...400000, yearsExperience: 12...20, skills: ["Company-wide vision", "Industry influence", "Innovation"], nextLevel: "Distinguished Engineer / CTO", habits: [
                    HabitTemplate(name: "Vision Setting", icon: "eye.circle", color: "#45B7D1", description: "Define technical vision"),
                    HabitTemplate(name: "External Speaking", icon: "mic", color: "#FF6B6B", description: "Speak at conferences"),
                    HabitTemplate(name: "Innovation Time", icon: "lightbulb", color: "#4ECDC4", description: "Explore new technologies")
                ])
            ]
        ),

        // Business / Corporate
        CareerPath(
            name: "Business / Corporate",
            icon: "briefcase.fill",
            colorHex: "#9B59B6",
            levels: [
                CareerLevel(title: "Individual Contributor", level: 1, salaryRange: 50000...70000, yearsExperience: 0...2, skills: ["Communication", "Excel", "Presentation"], nextLevel: "Senior Associate", habits: [
                    HabitTemplate(name: "Skill Building", icon: "book", color: "#9B59B6", description: "Learn new business skills"),
                    HabitTemplate(name: "Network Event", icon: "person.3", color: "#FF6B6B", description: "Attend networking events"),
                    HabitTemplate(name: "Visibility Action", icon: "eye", color: "#4ECDC4", description: "Make your work visible")
                ]),
                CareerLevel(title: "Senior Associate", level: 2, salaryRange: 70000...100000, yearsExperience: 2...4, skills: ["Project management", "Client relations", "Analysis"], nextLevel: "Manager", habits: [
                    HabitTemplate(name: "Project Leadership", icon: "list.clipboard", color: "#9B59B6", description: "Lead project work"),
                    HabitTemplate(name: "Client Relationship", icon: "person.circle", color: "#FF6B6B", description: "Build client trust"),
                    HabitTemplate(name: "Upward Management", icon: "arrow.up.circle", color: "#4ECDC4", description: "Communicate with leadership")
                ]),
                CareerLevel(title: "Manager", level: 3, salaryRange: 100000...150000, yearsExperience: 4...7, skills: ["People management", "Strategy", "Budget"], nextLevel: "Senior Manager / Director", habits: [
                    HabitTemplate(name: "1:1 Meetings", icon: "person.2", color: "#9B59B6", description: "Meet with direct reports"),
                    HabitTemplate(name: "Strategic Planning", icon: "map", color: "#FF6B6B", description: "Plan team strategy"),
                    HabitTemplate(name: "Performance Review", icon: "chart.bar", color: "#4ECDC4", description: "Track team performance")
                ]),
                CareerLevel(title: "Director", level: 4, salaryRange: 150000...250000, yearsExperience: 7...12, skills: ["Department leadership", "P&L", "Executive presence"], nextLevel: "VP", habits: [
                    HabitTemplate(name: "Executive Alignment", icon: "person.crop.circle.badge.checkmark", color: "#9B59B6", description: "Align with executives"),
                    HabitTemplate(name: "Budget Management", icon: "dollarsign.circle", color: "#FF6B6B", description: "Manage department budget"),
                    HabitTemplate(name: "Talent Development", icon: "person.badge.plus", color: "#4ECDC4", description: "Develop leadership pipeline")
                ]),
                CareerLevel(title: "Vice President", level: 5, salaryRange: 250000...500000, yearsExperience: 12...18, skills: ["Org leadership", "Board relations", "Market strategy"], nextLevel: "C-Suite", habits: [
                    HabitTemplate(name: "Board Prep", icon: "rectangle.3.group", color: "#9B59B6", description: "Prepare board materials"),
                    HabitTemplate(name: "Industry Leadership", icon: "globe", color: "#FF6B6B", description: "Lead industry initiatives"),
                    HabitTemplate(name: "C-Suite Relationship", icon: "person.3.fill", color: "#4ECDC4", description: "Build executive relationships")
                ]),
                CareerLevel(title: "C-Suite Executive", level: 6, salaryRange: 500000...2000000, yearsExperience: 18...30, skills: ["Company vision", "Shareholder value", "Public representation"], nextLevel: nil, habits: [
                    HabitTemplate(name: "Vision & Strategy", icon: "eye.circle.fill", color: "#9B59B6", description: "Set company direction"),
                    HabitTemplate(name: "Investor Relations", icon: "chart.line.uptrend.xyaxis", color: "#FF6B6B", description: "Manage investor relationships"),
                    HabitTemplate(name: "Public Leadership", icon: "megaphone", color: "#4ECDC4", description: "Represent company publicly")
                ])
            ]
        ),

        // Sales
        CareerPath(
            name: "Sales",
            icon: "phone.fill",
            colorHex: "#27AE60",
            levels: [
                CareerLevel(title: "Sales Development Rep (SDR)", level: 1, salaryRange: 45000...65000, yearsExperience: 0...2, skills: ["Cold calling", "Email outreach", "CRM"], nextLevel: "Account Executive", habits: [
                    HabitTemplate(name: "Cold Calls", icon: "phone.arrow.up.right", color: "#27AE60", description: "Make outbound calls"),
                    HabitTemplate(name: "Email Sequences", icon: "envelope", color: "#FF6B6B", description: "Send prospecting emails"),
                    HabitTemplate(name: "Pipeline Update", icon: "list.bullet", color: "#4ECDC4", description: "Update CRM pipeline")
                ]),
                CareerLevel(title: "Account Executive", level: 2, salaryRange: 80000...150000, yearsExperience: 2...5, skills: ["Closing deals", "Negotiation", "Presentation"], nextLevel: "Senior AE / Team Lead", habits: [
                    HabitTemplate(name: "Discovery Calls", icon: "questionmark.circle", color: "#27AE60", description: "Run discovery meetings"),
                    HabitTemplate(name: "Demo/Presentation", icon: "play.rectangle", color: "#FF6B6B", description: "Present to prospects"),
                    HabitTemplate(name: "Close Deals", icon: "checkmark.seal", color: "#4ECDC4", description: "Work active opportunities")
                ]),
                CareerLevel(title: "Sales Manager", level: 3, salaryRange: 120000...200000, yearsExperience: 5...8, skills: ["Team leadership", "Forecasting", "Coaching"], nextLevel: "Director of Sales", habits: [
                    HabitTemplate(name: "Team Coaching", icon: "person.2.fill", color: "#27AE60", description: "Coach team members"),
                    HabitTemplate(name: "Forecast Review", icon: "chart.bar", color: "#FF6B6B", description: "Review sales forecast"),
                    HabitTemplate(name: "Deal Review", icon: "doc.text.magnifyingglass", color: "#4ECDC4", description: "Review key deals")
                ]),
                CareerLevel(title: "Director of Sales", level: 4, salaryRange: 180000...300000, yearsExperience: 8...12, skills: ["Sales strategy", "Revenue planning", "Org building"], nextLevel: "VP of Sales", habits: [
                    HabitTemplate(name: "Strategy Planning", icon: "map", color: "#27AE60", description: "Plan sales strategy"),
                    HabitTemplate(name: "Hiring/Recruiting", icon: "person.badge.plus", color: "#FF6B6B", description: "Build the team"),
                    HabitTemplate(name: "Executive Selling", icon: "person.crop.circle.badge.checkmark", color: "#4ECDC4", description: "Engage on key accounts")
                ]),
                CareerLevel(title: "VP / CRO", level: 5, salaryRange: 300000...700000, yearsExperience: 12...20, skills: ["GTM strategy", "Board relations", "Company growth"], nextLevel: nil, habits: [
                    HabitTemplate(name: "GTM Strategy", icon: "globe", color: "#27AE60", description: "Drive go-to-market"),
                    HabitTemplate(name: "Board Updates", icon: "rectangle.3.group", color: "#FF6B6B", description: "Report to board"),
                    HabitTemplate(name: "Market Expansion", icon: "arrow.up.right.circle", color: "#4ECDC4", description: "Expand market presence")
                ])
            ]
        )
    ]

    static func getPath(named name: String) -> CareerPath? {
        paths.first { $0.name.lowercased().contains(name.lowercased()) }
    }
}

// MARK: - Sprint Templates

struct SprintTemplates {

    // Create a college admission sprint
    static func collegeAdmissionSprint(targetCollege: CollegeInfo, currentGPA: Double, currentSAT: Int?, monthsUntilApplication: Int) -> Sprint {
        var metrics: [SprintMetric] = [
            SprintMetric(name: "GPA", targetValue: targetCollege.avgGPA, currentValue: currentGPA, unit: "GPA", icon: "a.circle.fill")
        ]

        if let sat = currentSAT {
            metrics.append(SprintMetric(name: "SAT Score", targetValue: Double(targetCollege.avgSAT), currentValue: Double(sat), unit: "pts", icon: "pencil.circle.fill"))
        }

        // Calculate study hours needed per week
        let gpaGap = max(0, targetCollege.avgGPA - currentGPA)
        let studyHoursPerWeek = 15.0 + (gpaGap * 10) // Base 15 + extra based on gap
        metrics.append(SprintMetric(name: "Study Hours/Week", targetValue: studyHoursPerWeek, currentValue: 0, unit: "hrs", icon: "clock.fill"))

        // Extracurricular activities
        metrics.append(SprintMetric(name: "Extracurriculars", targetValue: 3, currentValue: 0, unit: "activities", icon: "star.fill"))

        return Sprint(
            name: "Get into \(targetCollege.shortName)",
            description: "Focused sprint to maximize admission chances to \(targetCollege.name)",
            targetDate: Calendar.current.date(byAdding: .month, value: monthsUntilApplication, to: Date()) ?? Date(),
            startDate: Date(),
            icon: "graduationcap.fill",
            colorHex: "#3498DB",
            category: .college,
            targetMetrics: metrics,
            linkedHabits: []
        )
    }

    // Create a career advancement sprint
    static func careerAdvancementSprint(currentLevel: CareerLevel, targetLevel: CareerLevel, monthsToTarget: Int) -> Sprint {
        var metrics: [SprintMetric] = []

        // Skills to develop
        for skill in targetLevel.skills.prefix(3) {
            metrics.append(SprintMetric(name: skill, targetValue: 100, currentValue: 0, unit: "%", icon: "checkmark.circle.fill"))
        }

        // Networking targets
        metrics.append(SprintMetric(name: "Key Relationships", targetValue: 5, currentValue: 0, unit: "people", icon: "person.3.fill"))

        // Visibility actions
        metrics.append(SprintMetric(name: "Visibility Actions", targetValue: Double(monthsToTarget * 2), currentValue: 0, unit: "actions", icon: "eye.fill"))

        return Sprint(
            name: "\(currentLevel.title) → \(targetLevel.title)",
            description: "Accelerate your promotion from \(currentLevel.title) to \(targetLevel.title)",
            targetDate: Calendar.current.date(byAdding: .month, value: monthsToTarget, to: Date()) ?? Date(),
            startDate: Date(),
            icon: "arrow.up.circle.fill",
            colorHex: "#9B59B6",
            category: .career,
            targetMetrics: metrics,
            linkedHabits: []
        )
    }

    // 30-day fitness sprint
    static func fitnessTransformationSprint(goal: String, targetWeight: Double?, currentWeight: Double?) -> Sprint {
        var metrics: [SprintMetric] = []

        if let target = targetWeight, let current = currentWeight {
            let weightChange = target - current
            metrics.append(SprintMetric(name: weightChange > 0 ? "Weight Gain" : "Weight Loss", targetValue: abs(weightChange), currentValue: 0, unit: "lbs", icon: "scalemass.fill"))
        }

        metrics.append(SprintMetric(name: "Workout Days", targetValue: 24, currentValue: 0, unit: "days", icon: "figure.run"))
        metrics.append(SprintMetric(name: "Protein Target", targetValue: 30, currentValue: 0, unit: "days hit", icon: "fork.knife"))
        metrics.append(SprintMetric(name: "Sleep Quality", targetValue: 30, currentValue: 0, unit: "nights", icon: "moon.fill"))

        return Sprint(
            name: goal.isEmpty ? "30-Day Transform" : goal,
            description: "Intensive 30-day fitness transformation sprint",
            targetDate: Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date(),
            startDate: Date(),
            icon: "flame.fill",
            colorHex: "#E74C3C",
            category: .fitness,
            targetMetrics: metrics,
            linkedHabits: []
        )
    }

    // Financial goal sprint (90 days)
    static func financialSprint(targetAmount: Double, purpose: String) -> Sprint {
        let metrics: [SprintMetric] = [
            SprintMetric(name: "Amount Saved", targetValue: targetAmount, currentValue: 0, unit: "$", icon: "dollarsign.circle.fill"),
            SprintMetric(name: "Budget Days", targetValue: 90, currentValue: 0, unit: "days", icon: "chart.bar.fill"),
            SprintMetric(name: "No-Spend Days", targetValue: 30, currentValue: 0, unit: "days", icon: "xmark.circle.fill"),
            SprintMetric(name: "Income Boost", targetValue: targetAmount * 0.2, currentValue: 0, unit: "$", icon: "arrow.up.circle.fill")
        ]

        return Sprint(
            name: purpose.isEmpty ? "Save \(Int(targetAmount)) in 90 Days" : purpose,
            description: "Aggressive 90-day savings sprint",
            targetDate: Calendar.current.date(byAdding: .day, value: 90, to: Date()) ?? Date(),
            startDate: Date(),
            icon: "banknote.fill",
            colorHex: "#27AE60",
            category: .financial,
            targetMetrics: metrics,
            linkedHabits: []
        )
    }
}

// MARK: - High School Student Specialization

enum StudentType: String, Codable, CaseIterable {
    case highSchool = "high_school"
    case college = "college"
    case gradSchool = "grad_school"
    case bootcamp = "bootcamp"

    var displayName: String {
        switch self {
        case .highSchool: return "High School"
        case .college: return "College/University"
        case .gradSchool: return "Graduate School"
        case .bootcamp: return "Bootcamp/Certificate"
        }
    }

    var icon: String {
        switch self {
        case .highSchool: return "building.columns"
        case .college: return "graduationcap"
        case .gradSchool: return "book.closed"
        case .bootcamp: return "laptopcomputer"
        }
    }
}

enum StudentMajor: String, Codable, CaseIterable {
    // STEM
    case computerScience = "computer_science"
    case engineering = "engineering"
    case biology = "biology"
    case chemistry = "chemistry"
    case physics = "physics"
    case mathematics = "mathematics"
    case preMed = "pre_med"
    case nursing = "nursing"

    // Business
    case business = "business"
    case economics = "economics"
    case finance = "finance"
    case accounting = "accounting"
    case marketing = "marketing"

    // Arts & Humanities
    case english = "english"
    case history = "history"
    case psychology = "psychology"
    case communications = "communications"
    case art = "art"
    case music = "music"
    case film = "film"

    // Other
    case law = "law"
    case education = "education"
    case undecided = "undecided"

    var displayName: String {
        switch self {
        case .computerScience: return "Computer Science"
        case .engineering: return "Engineering"
        case .biology: return "Biology"
        case .chemistry: return "Chemistry"
        case .physics: return "Physics"
        case .mathematics: return "Mathematics"
        case .preMed: return "Pre-Med"
        case .nursing: return "Nursing"
        case .business: return "Business"
        case .economics: return "Economics"
        case .finance: return "Finance"
        case .accounting: return "Accounting"
        case .marketing: return "Marketing"
        case .english: return "English"
        case .history: return "History"
        case .psychology: return "Psychology"
        case .communications: return "Communications"
        case .art: return "Art & Design"
        case .music: return "Music"
        case .film: return "Film & Media"
        case .law: return "Pre-Law"
        case .education: return "Education"
        case .undecided: return "Undecided"
        }
    }

    var icon: String {
        switch self {
        case .computerScience: return "chevron.left.forwardslash.chevron.right"
        case .engineering: return "gearshape.2"
        case .biology: return "leaf.fill"
        case .chemistry: return "flask.fill"
        case .physics: return "atom"
        case .mathematics: return "function"
        case .preMed: return "stethoscope"
        case .nursing: return "cross.case.fill"
        case .business: return "briefcase.fill"
        case .economics: return "chart.line.uptrend.xyaxis"
        case .finance: return "dollarsign.circle.fill"
        case .accounting: return "dollarsign.square.fill"
        case .marketing: return "megaphone.fill"
        case .english: return "book.fill"
        case .history: return "clock.fill"
        case .psychology: return "brain.head.profile"
        case .communications: return "bubble.left.and.bubble.right.fill"
        case .art: return "paintbrush.fill"
        case .music: return "music.note"
        case .film: return "film.fill"
        case .law: return "building.columns.fill"
        case .education: return "person.3.fill"
        case .undecided: return "questionmark.circle.fill"
        }
    }

    var suggestedHabits: [HabitTemplate] {
        switch self {
        case .computerScience:
            return [
                HabitTemplate(name: "Code Practice", icon: "chevron.left.forwardslash.chevron.right", color: "#45B7D1", description: "Practice coding problems"),
                HabitTemplate(name: "CS Homework", icon: "doc.text.fill", color: "#4ECDC4", description: "Complete CS assignments"),
                HabitTemplate(name: "Side Project", icon: "hammer.fill", color: "#FF6B6B", description: "Work on personal projects"),
                HabitTemplate(name: "Tech Reading", icon: "book.fill", color: "#96CEB4", description: "Read tech articles/docs")
            ]
        case .engineering:
            return [
                HabitTemplate(name: "Problem Sets", icon: "function", color: "#45B7D1", description: "Complete engineering problems"),
                HabitTemplate(name: "Lab Work", icon: "gearshape.2", color: "#4ECDC4", description: "Lab assignments and projects"),
                HabitTemplate(name: "CAD/Design", icon: "square.and.pencil", color: "#FF6B6B", description: "Design and modeling work"),
                HabitTemplate(name: "Study Group", icon: "person.3.fill", color: "#96CEB4", description: "Collaborative study session")
            ]
        case .biology, .preMed:
            return [
                HabitTemplate(name: "Bio Study", icon: "leaf.fill", color: "#4ECDC4", description: "Study biology concepts"),
                HabitTemplate(name: "Lab Work", icon: "flask.fill", color: "#45B7D1", description: "Complete lab assignments"),
                HabitTemplate(name: "MCAT Prep", icon: "brain.head.profile", color: "#FF6B6B", description: "MCAT practice questions"),
                HabitTemplate(name: "Clinical Hours", icon: "stethoscope", color: "#96CEB4", description: "Volunteer/shadow hours")
            ]
        case .chemistry:
            return [
                HabitTemplate(name: "Chem Study", icon: "flask.fill", color: "#9B59B6", description: "Study chemistry concepts"),
                HabitTemplate(name: "Problem Sets", icon: "function", color: "#45B7D1", description: "Complete chem problems"),
                HabitTemplate(name: "Lab Report", icon: "doc.text.fill", color: "#4ECDC4", description: "Write lab reports"),
                HabitTemplate(name: "Office Hours", icon: "person.fill.questionmark", color: "#FF6B6B", description: "Attend office hours")
            ]
        case .business, .economics, .finance, .accounting, .marketing:
            return [
                HabitTemplate(name: "Case Study", icon: "briefcase.fill", color: "#9B59B6", description: "Analyze business cases"),
                HabitTemplate(name: "Market News", icon: "newspaper.fill", color: "#45B7D1", description: "Read business news"),
                HabitTemplate(name: "Networking", icon: "person.3.fill", color: "#4ECDC4", description: "Professional networking"),
                HabitTemplate(name: "Excel/Finance", icon: "chart.bar.fill", color: "#27AE60", description: "Financial modeling practice")
            ]
        case .english, .history, .communications:
            return [
                HabitTemplate(name: "Reading", icon: "book.fill", color: "#996633", description: "Required reading"),
                HabitTemplate(name: "Writing", icon: "pencil.line", color: "#45B7D1", description: "Essay and paper writing"),
                HabitTemplate(name: "Research", icon: "magnifyingglass", color: "#4ECDC4", description: "Research for papers"),
                HabitTemplate(name: "Discussion Prep", icon: "bubble.left.and.bubble.right.fill", color: "#FF6B6B", description: "Prepare for class discussion")
            ]
        case .psychology:
            return [
                HabitTemplate(name: "Psych Reading", icon: "brain.head.profile", color: "#E74C3C", description: "Read psychology texts"),
                HabitTemplate(name: "Research", icon: "magnifyingglass", color: "#45B7D1", description: "Research methods study"),
                HabitTemplate(name: "Case Analysis", icon: "person.fill.questionmark", color: "#4ECDC4", description: "Analyze case studies"),
                HabitTemplate(name: "Stats Practice", icon: "chart.bar.fill", color: "#96CEB4", description: "Statistics for psych")
            ]
        case .art, .music, .film:
            return [
                HabitTemplate(name: "Practice/Create", icon: "paintbrush.fill", color: "#DDA0DD", description: "Daily creative practice"),
                HabitTemplate(name: "Portfolio Work", icon: "photo.stack", color: "#45B7D1", description: "Build portfolio"),
                HabitTemplate(name: "Critique Prep", icon: "bubble.left.and.bubble.right.fill", color: "#4ECDC4", description: "Prepare for critiques"),
                HabitTemplate(name: "Industry Study", icon: "eye.fill", color: "#FF6B6B", description: "Study industry/masters")
            ]
        default:
            return [
                HabitTemplate(name: "Study Session", icon: "book.fill", color: "#45B7D1", description: "Focused study time"),
                HabitTemplate(name: "Homework", icon: "doc.text.fill", color: "#4ECDC4", description: "Complete assignments"),
                HabitTemplate(name: "Review Notes", icon: "note.text", color: "#FF6B6B", description: "Review class notes"),
                HabitTemplate(name: "Office Hours", icon: "person.fill.questionmark", color: "#96CEB4", description: "Get help from professors")
            ]
        }
    }
}

// MARK: - Life Goals (Long-term Vision)

enum GoalTimeframe: String, Codable, CaseIterable {
    case shortTerm = "short_term"      // 1-3 months
    case mediumTerm = "medium_term"    // 3-12 months
    case longTerm = "long_term"        // 1-5 years
    case lifelong = "lifelong"         // 5+ years / lifetime

    var displayName: String {
        switch self {
        case .shortTerm: return "Short Term"
        case .mediumTerm: return "This Year"
        case .longTerm: return "Long Term"
        case .lifelong: return "Lifetime"
        }
    }

    var subtitle: String {
        switch self {
        case .shortTerm: return "1-3 months"
        case .mediumTerm: return "3-12 months"
        case .longTerm: return "1-5 years"
        case .lifelong: return "5+ years"
        }
    }

    var icon: String {
        switch self {
        case .shortTerm: return "hare.fill"
        case .mediumTerm: return "calendar"
        case .longTerm: return "mountain.2.fill"
        case .lifelong: return "star.fill"
        }
    }

    var color: Color {
        switch self {
        case .shortTerm: return .blue
        case .mediumTerm: return .green
        case .longTerm: return .purple
        case .lifelong: return .orange
        }
    }
}

enum GoalCategory: String, Codable, CaseIterable {
    case career = "career"
    case health = "health"
    case financial = "financial"
    case relationships = "relationships"
    case personal = "personal"
    case education = "education"
    case creative = "creative"
    case adventure = "adventure"

    var displayName: String {
        switch self {
        case .career: return "Career"
        case .health: return "Health & Fitness"
        case .financial: return "Financial"
        case .relationships: return "Relationships"
        case .personal: return "Personal Growth"
        case .education: return "Education"
        case .creative: return "Creative"
        case .adventure: return "Adventure"
        }
    }

    var icon: String {
        switch self {
        case .career: return "briefcase.fill"
        case .health: return "heart.fill"
        case .financial: return "dollarsign.circle.fill"
        case .relationships: return "person.2.fill"
        case .personal: return "brain.head.profile"
        case .education: return "graduationcap.fill"
        case .creative: return "paintbrush.fill"
        case .adventure: return "airplane"
        }
    }

    var color: Color {
        switch self {
        case .career: return .purple
        case .health: return .red
        case .financial: return .green
        case .relationships: return .pink
        case .personal: return .cyan
        case .education: return .blue
        case .creative: return .orange
        case .adventure: return .teal
        }
    }
}

struct LifeGoal: Identifiable, Codable {
    var id = UUID()
    var title: String
    var description: String
    var timeframe: GoalTimeframe
    var category: GoalCategory
    var targetDate: Date?
    var createdAt: Date = Date()
    var isCompleted: Bool = false
    var completedDate: Date?
    var milestones: [GoalMilestone] = []
    var linkedHabitIds: [UUID] = []
    var notes: String = ""

    var progress: Double {
        guard !milestones.isEmpty else { return isCompleted ? 1.0 : 0.0 }
        let completed = milestones.filter { $0.isCompleted }.count
        return Double(completed) / Double(milestones.count)
    }

    var progressPercentage: Int {
        Int(progress * 100)
    }

    var daysRemaining: Int? {
        guard let targetDate = targetDate else { return nil }
        return Calendar.current.dateComponents([.day], from: Date(), to: targetDate).day
    }

    var isOverdue: Bool {
        guard let days = daysRemaining else { return false }
        return days < 0 && !isCompleted
    }
}

struct GoalMilestone: Identifiable, Codable {
    var id = UUID()
    var title: String
    var isCompleted: Bool = false
    var completedDate: Date?
    var targetDate: Date?
}

// MARK: - Life Goal Templates

struct LifeGoalTemplates {
    static let templates: [GoalCategory: [LifeGoal]] = [
        .career: [
            LifeGoal(title: "Get promoted", description: "Advance to the next level in my career", timeframe: .mediumTerm, category: .career),
            LifeGoal(title: "Start a business", description: "Launch my own company or side project", timeframe: .longTerm, category: .career),
            LifeGoal(title: "Switch careers", description: "Transition into a new field", timeframe: .longTerm, category: .career),
            LifeGoal(title: "Become an expert", description: "Master my craft and become a recognized expert", timeframe: .lifelong, category: .career),
        ],
        .health: [
            LifeGoal(title: "Run a marathon", description: "Complete a full 26.2 mile marathon", timeframe: .longTerm, category: .health),
            LifeGoal(title: "Reach ideal weight", description: "Achieve and maintain my target weight", timeframe: .mediumTerm, category: .health),
            LifeGoal(title: "Build consistent workout routine", description: "Exercise regularly for 6+ months", timeframe: .mediumTerm, category: .health),
            LifeGoal(title: "Live to 100", description: "Maintain health for a long, fulfilling life", timeframe: .lifelong, category: .health),
        ],
        .financial: [
            LifeGoal(title: "Build emergency fund", description: "Save 6 months of expenses", timeframe: .mediumTerm, category: .financial),
            LifeGoal(title: "Become debt-free", description: "Pay off all debts", timeframe: .longTerm, category: .financial),
            LifeGoal(title: "Buy a home", description: "Purchase my first home", timeframe: .longTerm, category: .financial),
            LifeGoal(title: "Achieve financial independence", description: "Have enough to live on without working", timeframe: .lifelong, category: .financial),
        ],
        .relationships: [
            LifeGoal(title: "Strengthen family bonds", description: "Build closer relationships with family", timeframe: .mediumTerm, category: .relationships),
            LifeGoal(title: "Find a life partner", description: "Build a meaningful romantic relationship", timeframe: .longTerm, category: .relationships),
            LifeGoal(title: "Build a supportive network", description: "Develop deep, lasting friendships", timeframe: .longTerm, category: .relationships),
            LifeGoal(title: "Be a great parent/mentor", description: "Guide and support the next generation", timeframe: .lifelong, category: .relationships),
        ],
        .personal: [
            LifeGoal(title: "Develop mindfulness practice", description: "Build a consistent meditation habit", timeframe: .mediumTerm, category: .personal),
            LifeGoal(title: "Overcome a fear", description: "Face and conquer a limiting fear", timeframe: .mediumTerm, category: .personal),
            LifeGoal(title: "Find my purpose", description: "Discover what truly drives me", timeframe: .longTerm, category: .personal),
            LifeGoal(title: "Live with no regrets", description: "Make choices aligned with my values", timeframe: .lifelong, category: .personal),
        ],
        .education: [
            LifeGoal(title: "Get into dream school", description: "Gain admission to my target college", timeframe: .mediumTerm, category: .education),
            LifeGoal(title: "Earn a degree", description: "Complete my educational program", timeframe: .longTerm, category: .education),
            LifeGoal(title: "Learn a new language", description: "Become fluent in another language", timeframe: .longTerm, category: .education),
            LifeGoal(title: "Never stop learning", description: "Continuously grow and develop", timeframe: .lifelong, category: .education),
        ],
        .creative: [
            LifeGoal(title: "Write a book", description: "Author and publish a book", timeframe: .longTerm, category: .creative),
            LifeGoal(title: "Learn an instrument", description: "Master playing a musical instrument", timeframe: .longTerm, category: .creative),
            LifeGoal(title: "Create an app/product", description: "Build something people use", timeframe: .longTerm, category: .creative),
            LifeGoal(title: "Leave a creative legacy", description: "Create work that outlasts me", timeframe: .lifelong, category: .creative),
        ],
        .adventure: [
            LifeGoal(title: "Visit 10 countries", description: "Explore different cultures", timeframe: .longTerm, category: .adventure),
            LifeGoal(title: "Learn to surf/ski", description: "Master an adventure sport", timeframe: .mediumTerm, category: .adventure),
            LifeGoal(title: "See the Northern Lights", description: "Experience this natural wonder", timeframe: .longTerm, category: .adventure),
            LifeGoal(title: "Live abroad", description: "Experience life in another country", timeframe: .longTerm, category: .adventure),
        ],
    ]
}

// MARK: - Sprint & Goals Storage Extension

extension AppSettings {
    private static let sprintsKey = "userSprints"
    private static let lifeGoalsKey = "userLifeGoals"
    private static let studentTypeKey = "studentType"
    private static let studentMajorKey = "studentMajor"
    private static let targetCollegeKey = "targetCollege"

    var lifeGoals: [LifeGoal] {
        get {
            guard let data = UserDefaults.standard.data(forKey: Self.lifeGoalsKey) else { return [] }
            return (try? JSONDecoder().decode([LifeGoal].self, from: data)) ?? []
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(data, forKey: Self.lifeGoalsKey)
            }
        }
    }

    func addLifeGoal(_ goal: LifeGoal) {
        var goals = lifeGoals
        goals.append(goal)
        lifeGoals = goals
    }

    func updateLifeGoal(_ goal: LifeGoal) {
        var goals = lifeGoals
        if let index = goals.firstIndex(where: { $0.id == goal.id }) {
            goals[index] = goal
            lifeGoals = goals
        }
    }

    func deleteLifeGoal(_ goal: LifeGoal) {
        var goals = lifeGoals
        goals.removeAll { $0.id == goal.id }
        lifeGoals = goals
    }

    var goalsByTimeframe: [GoalTimeframe: [LifeGoal]] {
        Dictionary(grouping: lifeGoals.filter { !$0.isCompleted }, by: { $0.timeframe })
    }

    var completedGoals: [LifeGoal] {
        lifeGoals.filter { $0.isCompleted }
    }

    var activeSprints: [Sprint] {
        get {
            guard let data = UserDefaults.standard.data(forKey: Self.sprintsKey) else { return [] }
            return (try? JSONDecoder().decode([Sprint].self, from: data)) ?? []
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(data, forKey: Self.sprintsKey)
            }
        }
    }

    var studentType: StudentType? {
        get {
            guard let raw = UserDefaults.standard.string(forKey: Self.studentTypeKey) else { return nil }
            return StudentType(rawValue: raw)
        }
        set {
            UserDefaults.standard.set(newValue?.rawValue, forKey: Self.studentTypeKey)
        }
    }

    var studentMajor: StudentMajor? {
        get {
            guard let raw = UserDefaults.standard.string(forKey: Self.studentMajorKey) else { return nil }
            return StudentMajor(rawValue: raw)
        }
        set {
            UserDefaults.standard.set(newValue?.rawValue, forKey: Self.studentMajorKey)
        }
    }

    var targetCollege: CollegeInfo? {
        get {
            guard let data = UserDefaults.standard.data(forKey: Self.targetCollegeKey) else { return nil }
            return try? JSONDecoder().decode(CollegeInfo.self, from: data)
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(data, forKey: Self.targetCollegeKey)
            }
        }
    }
}
