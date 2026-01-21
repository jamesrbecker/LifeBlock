import WidgetKit
import SwiftUI

@main
struct LifeBlocksWidgetBundle: WidgetBundle {
    var body: some Widget {
        LifeBlocksWidget()
        StandByWidget()
        StreakWidget()
        if #available(iOS 17.0, *) {
            InteractiveCheckInWidget()
        }
    }
}
