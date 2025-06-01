import WidgetKit
import Foundation // For Date, DateFormatter, Calendar

struct ConferenceTimelineProvider: TimelineProvider {
    typealias Entry = SimpleEntry // Assuming SimpleEntry and DisplayState are defined elsewhere

    // Static DateFormatter for parsing deadline strings.
    // "Etc/GMT+12" is used for "Anywhere on Earth" (AoE) timezone.
    // This means deadlines like "2024-12-31 23:59" AoE will end when it's 23:59 at GMT-12.
    static let deadlineDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        formatter.timeZone = TimeZone(identifier: "Etc/GMT+12") // AoE
        // Note: If deadlines can have *different* timezones specified in the JSON,
        // this single static formatter would not be sufficient. Parsing logic would
        // need to adjust the formatter's timezone per deadline string or use ISO8601DateFormatter
        // if the timezone is part of the string. For this iteration, we assume all
        // deadlines use the AoE convention if not otherwise specified and are parsed as such.
        return formatter
    }()

    private func parseDeadlineString(_ deadlineString: String) -> Date? {
        // Handle "TBA" or other non-date strings gracefully
        if deadlineString.uppercased() == "TBA" {
            return nil
        }
        return Self.deadlineDateFormatter.date(from: deadlineString)
    }

    func placeholder(in context: Context) -> SimpleEntry {
        let placeholderConference = ConferenceDeadline(
            name: "Sample Conference",
            description: "A sample tech conference.",
            year: Calendar.current.component(.year, from: Date()),
            link: "https://example.com",
            deadline: ["\(Calendar.current.component(.year, from: Date()))-12-31 23:59"],
            date: "Next Year",
            place: "Anytown, USA",
            note: "This is a placeholder.",
            tags: ["Tech", "Sample"]
        )
        return SimpleEntry(date: Date(), displayState: .placeholder, conference: placeholderConference, relevantDeadline: Date().addingTimeInterval(86400 * 30)) // Approx 30 days from now
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        if context.isPreview {
            completion(placeholder(in: context))
            return
        }

        let conferences = DataManager.loadConferences()
        if let firstConference = conferences.first {
            // Attempt to find the first valid future deadline for the snapshot
            var nextDeadlineDate: Date? = nil
            if let deadlines = firstConference.deadline {
                for deadlineStr in deadlines {
                    if let parsedDate = parseDeadlineString(deadlineStr), parsedDate > Date() {
                        nextDeadlineDate = parsedDate
                        break // Found the first future deadline for this conference
                    }
                }
            }

            if let relevantDate = nextDeadlineDate {
                let entry = SimpleEntry(date: Date(), displayState: .showConference, conference: firstConference, relevantDeadline: relevantDate)
                completion(entry)
            } else {
                // No future deadline for the first conference, or no deadlines at all
                let entry = SimpleEntry(date: Date(), displayState: .showConference, conference: firstConference, relevantDeadline: nil, customMessage: "No upcoming deadline for this one.")
                completion(entry)
            }
        } else {
            let entry = SimpleEntry(date: Date(), displayState: .noUpcomingDeadlines, conference: nil, relevantDeadline: nil)
            completion(entry)
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let conferences = DataManager.loadConferences()
        let currentDate = Date()
        let refreshDate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)! // Refresh every hour

        if conferences.isEmpty {
            if DataManager.loadConferences(from: "conferences_nonexistent", fileExtension: "json").isEmpty && Bundle.main.url(forResource: "conferences", withExtension: "json") == nil {
                 // This check is a bit convoluted; ideally DataManager would throw specific errors
                let entry = SimpleEntry(date: currentDate, displayState: .error, conference: nil, relevantDeadline: nil, customMessage: "Error: conferences.json not found.")
                let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
                completion(timeline)
                return
            }
            // File found but might be empty or all items filtered out later
        }

        var nextUpcomingConference: ConferenceDeadline? = nil
        var soonestDeadlineDate: Date? = nil

        for conference in conferences {
            guard let deadlineStrings = conference.deadline, !deadlineStrings.isEmpty else {
                continue // Skip conferences with no deadline array or empty deadline array
            }

            for deadlineStr in deadlineStrings {
                if let parsedDate = parseDeadlineString(deadlineStr) {
                    if parsedDate > currentDate { // Deadline is in the future
                        if soonestDeadlineDate == nil || parsedDate < soonestDeadlineDate! {
                            soonestDeadlineDate = parsedDate
                            nextUpcomingConference = conference
                        }
                    }
                }
            }
        }

        let entry: SimpleEntry
        if let conference = nextUpcomingConference, let deadline = soonestDeadlineDate {
            entry = SimpleEntry(date: currentDate, displayState: .showConference, conference: conference, relevantDeadline: deadline)
        } else {
            // No future deadlines found across all conferences
            entry = SimpleEntry(date: currentDate, displayState: .noUpcomingDeadlines, conference: nil, relevantDeadline: nil)
        }

        let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
        completion(timeline)
    }
}
