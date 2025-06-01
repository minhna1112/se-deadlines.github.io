import WidgetKit
import Foundation // For Date

struct SimpleEntry: TimelineEntry {
    let date: Date // Time for this entry to be displayed
    let displayState: DisplayState
    let conference: ConferenceDeadline?
    let relevantDeadline: Date? // The specific deadline date being displayed/counted down to
    let customMessage: String? // For errors or specific messages not tied to a conference

    // Enum to define the widget's current content state
    enum DisplayState {
        case showConference       // Display a specific conference and its deadline
        case noUpcomingDeadlines  // No future deadlines are available
        case error                // An error occurred (e.g., data loading)
        case placeholder          // Entry is for placeholder/gallery view
    }

    // Initializer with a default nil for customMessage
    init(date: Date,
         displayState: DisplayState,
         conference: ConferenceDeadline?,
         relevantDeadline: Date?,
         customMessage: String? = nil) {
        self.date = date
        self.displayState = displayState
        self.conference = conference
        self.relevantDeadline = relevantDeadline
        self.customMessage = customMessage
    }
}
