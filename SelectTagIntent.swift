import AppIntents
import WidgetKit // Required for LocalizedStringResource in some Xcode versions/setups for intents

struct SelectTagIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Select Conference Tag"
    static var description: IntentDescription = IntentDescription("Choose a tag to filter the list of conferences.")

    // Parameter for the user to input a tag.
    // Making it optional allows for an "All Conferences" state if the string is nil or empty.
    @Parameter(title: "Tag", description: "Enter a tag to filter by (e.g., AI, Web, Mobile). Leave empty to show all.")
    var selectedTag: String?

    // Default initializer if needed by the system
    init(selectedTag: String?) {
        self.selectedTag = selectedTag
    }

    // Parameter-less initializer, often used by the system to create a default intent.
    // We can provide a default value here if desired, or leave it as nil.
    init() {
        self.selectedTag = nil
    }
}
