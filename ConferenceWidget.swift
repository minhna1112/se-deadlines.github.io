import WidgetKit
import SwiftUI

struct ConferenceWidget: Widget {
    // A unique identifier for this widget kind.
    // Replace "com.yourbundleid.ConferenceWidget" with your actual bundle ID prefix
    // or a suitable unique string.
    static let kind: String = "com.example.ConferenceWidget" // IMPORTANT: Make this unique!

    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: ConferenceWidget.kind, // Use static let for kind
            provider: ConferenceTimelineProvider()
        ) { entry in // entry is of type SimpleEntry
            ConferenceWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Conference Deadlines")
        .description("View upcoming conference submission deadlines.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge]) // Supporting small, medium, and large sizes
    }
}

// Preview provider for Xcode Previews (Optional, but helpful)
// This requires ConferenceWidgetEntryView and SimpleEntry to be defined.
// If ConferenceWidgetEntryView is not yet created, this preview might error.
// You might need to add this later or ensure stubs for dependencies exist.
struct ConferenceWidget_Previews: PreviewProvider {
    static var previews: some View {
        // Create a sample entry for previewing
        let sampleConference = ConferenceDeadline(
            name: "Preview Conference",
            description: "This is a preview.",
            year: Calendar.current.component(.year, from: Date()),
            link: "https://example.com/preview",
            deadline: ["\(Calendar.current.component(.year, from: Date()))-12-25 23:59"],
            date: "Dec 25-27",
            place: "Preview City",
            note: "Preview note.",
            tags: ["Preview"]
        )
        let entry = SimpleEntry(
            date: Date(),
            displayState: .showConference,
            conference: sampleConference,
            relevantDeadline: ConferenceTimelineProvider.deadlineDateFormatter.date(from: sampleConference.deadline!.first!)
        )

        // Preview for different widget families
        // Ensure ConferenceWidgetEntryView can handle these previews.
        // If ConferenceWidgetEntryView is not yet available, this part will cause an error.
        // Group {
        //     ConferenceWidgetEntryView(entry: entry)
        //         .previewContext(WidgetPreviewContext(family: .systemSmall))
        //         .previewDisplayName("Small Widget")
        //
        //     ConferenceWidgetEntryView(entry: entry)
        //         .previewContext(WidgetPreviewContext(family: .systemMedium))
        //         .previewDisplayName("Medium Widget")
        //
        //     ConferenceWidgetEntryView(entry: entry)
        //         .previewContext(WidgetPreviewContext(family: .systemLarge))
        //         .previewDisplayName("Large Widget")
        // }
        // For now, as ConferenceWidgetEntryView is not defined in this step,
        // we'll just provide a simple Text view for the preview to avoid errors.
        Text("Widget Preview Placeholder")
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
