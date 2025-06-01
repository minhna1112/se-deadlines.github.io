import Foundation

struct ConferenceDeadline: Codable, Identifiable {
    let name: String
    let description: String? // Made optional to handle potential null/missing
    let year: Int?          // Made optional to handle potential null/missing
    let link: String?
    let deadline: [String]? // Array of deadline strings
    let date: String?       // Made optional to handle potential null/missing
    let place: String?      // Made optional to handle potential null/missing
    let note: String?
    let tags: [String]?     // Made optional to handle potential null/missing

    // Computed property for Identifiable
    // Using a combination of name and year for a more robust ID.
    // If year can be null, consider a fallback or ensure name is unique enough.
    var id: String {
        return "\(name)-\(year ?? 0)" // Using 0 as a fallback for year if nil
    }

    // Custom CodingKeys to map JSON keys to struct properties if they differ
    // and to handle the id not being in the JSON.
    // In this case, the names match the JSON, so it's straightforward.
    // If 'id' was a stored property to be decoded, it would be listed here.
    // Since 'id' is computed, it's not part of the decoding process.
    enum CodingKeys: String, CodingKey {
        case name
        case description
        case year
        case link
        case deadline
        case date
        case place
        case note
        case tags
    }
}
