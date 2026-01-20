import Foundation
import HealthKit

@MainActor
final class HealthKitManager: ObservableObject {
    static let shared = HealthKitManager()

    private let healthStore = HKHealthStore()

    @Published var isAuthorized = false
    @Published var todayExerciseMinutes: Int = 0
    @Published var todaySleepHours: Double = 0
    @Published var lastNightSleepQuality: SleepQuality = .unknown

    enum SleepQuality: String {
        case poor = "Poor"
        case fair = "Fair"
        case good = "Good"
        case excellent = "Excellent"
        case unknown = "Unknown"

        init(hours: Double) {
            switch hours {
            case 0..<5: self = .poor
            case 5..<6: self = .fair
            case 6..<7.5: self = .good
            case 7.5...: self = .excellent
            default: self = .unknown
            }
        }
    }

    private let readTypes: Set<HKObjectType> = {
        var types: Set<HKObjectType> = []

        if let exerciseTime = HKObjectType.quantityType(forIdentifier: .appleExerciseTime) {
            types.insert(exerciseTime)
        }
        if let sleepAnalysis = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) {
            types.insert(sleepAnalysis)
        }
        types.insert(HKObjectType.workoutType())

        return types
    }()

    private init() {}

    var isHealthKitAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    func requestAuthorization() async -> Bool {
        guard isHealthKitAvailable else { return false }

        do {
            try await healthStore.requestAuthorization(toShare: [], read: readTypes)
            isAuthorized = true
            return true
        } catch {
            print("HealthKit authorization error: \(error)")
            return false
        }
    }

    func fetchTodayExerciseMinutes() async -> Int {
        guard isHealthKitAvailable else { return 0 }

        let exerciseType = HKQuantityType.quantityType(forIdentifier: .appleExerciseTime)!
        let today = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: today, end: Date(), options: .strictStartDate)

        return await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: exerciseType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, error in
                guard let result = result, let sum = result.sumQuantity() else {
                    continuation.resume(returning: 0)
                    return
                }

                let minutes = Int(sum.doubleValue(for: .minute()))
                Task { @MainActor in
                    self.todayExerciseMinutes = minutes
                }
                continuation.resume(returning: minutes)
            }

            healthStore.execute(query)
        }
    }

    func fetchTodayWorkouts() async -> [HKWorkout] {
        guard isHealthKitAvailable else { return [] }

        let today = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: today, end: Date(), options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)

        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: .workoutType(),
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [sortDescriptor]
            ) { _, samples, error in
                let workouts = samples as? [HKWorkout] ?? []
                continuation.resume(returning: workouts)
            }

            healthStore.execute(query)
        }
    }

    func fetchLastNightSleep() async -> Double {
        guard isHealthKitAvailable else { return 0 }

        guard let sleepType = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis) else {
            return 0
        }

        // Get last night (yesterday evening to this morning)
        let calendar = Calendar.current
        let now = Date()
        let todayStart = calendar.startOfDay(for: now)
        let yesterdayEvening = calendar.date(byAdding: .hour, value: -12, to: todayStart)!

        let predicate = HKQuery.predicateForSamples(withStart: yesterdayEvening, end: now, options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)

        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: sleepType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [sortDescriptor]
            ) { _, samples, error in
                guard let samples = samples as? [HKCategorySample] else {
                    continuation.resume(returning: 0)
                    return
                }

                // Calculate total asleep time (excluding in-bed but awake)
                var totalSleepSeconds: TimeInterval = 0

                for sample in samples {
                    // Only count actual sleep states
                    let sleepValue = HKCategoryValueSleepAnalysis(rawValue: sample.value)
                    if sleepValue == .asleepCore || sleepValue == .asleepDeep || sleepValue == .asleepREM || sleepValue == .asleepUnspecified {
                        totalSleepSeconds += sample.endDate.timeIntervalSince(sample.startDate)
                    }
                }

                let hours = totalSleepSeconds / 3600
                Task { @MainActor in
                    self.todaySleepHours = hours
                    self.lastNightSleepQuality = SleepQuality(hours: hours)
                }
                continuation.resume(returning: hours)
            }

            healthStore.execute(query)
        }
    }

    // Get completion level for exercise (0, 1, or 2)
    func exerciseCompletionLevel(minutes: Int, goal: Int = 30) -> Int {
        switch minutes {
        case 0..<(goal / 2): return 0
        case (goal / 2)..<goal: return 1
        default: return 2
        }
    }

    // Get completion level for sleep (0, 1, or 2)
    func sleepCompletionLevel(hours: Double, goal: Double = 7) -> Int {
        switch hours {
        case 0..<(goal * 0.7): return 0
        case (goal * 0.7)..<goal: return 1
        default: return 2
        }
    }

    // Refresh all health data
    func refreshAll() async {
        _ = await fetchTodayExerciseMinutes()
        _ = await fetchLastNightSleep()
    }
}

// HealthKit observer for background updates
extension HealthKitManager {
    func enableBackgroundDelivery() {
        guard isHealthKitAvailable else { return }

        let exerciseType = HKQuantityType.quantityType(forIdentifier: .appleExerciseTime)!

        healthStore.enableBackgroundDelivery(for: exerciseType, frequency: .hourly) { success, error in
            if let error = error {
                print("Background delivery error: \(error)")
            }
        }
    }
}
