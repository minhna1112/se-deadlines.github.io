import Foundation

struct DataManager {
    static func loadConferences(from fileName: String = "conferences", fileExtension: String = "json") -> [ConferenceDeadline] {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: fileExtension) else {
            print("Error: \(fileName).\(fileExtension) not found in the bundle.")
            #if DEBUG
            // In Debug mode, list bundle contents to help diagnose.
            if let bundlePath = Bundle.main.resourcePath {
                do {
                    let contents = try FileManager.default.contentsOfDirectory(atPath: bundlePath)
                    print("Bundle contents: \(contents)")
                } catch {
                    print("Error listing bundle contents: \(error)")
                }
            }
            #endif
            return []
        }

        let data: Data
        do {
            data = try Data(contentsOf: url)
        } catch {
            print("Error loading data from \(url): \(error)")
            return []
        }

        do {
            let decoder = JSONDecoder()
            // Optional: Add a date decoding strategy if your dates are in a specific format
            // and you want to decode them directly to Date objects.
            // For now, 'deadline' is [String]?, and 'date' is String?.
            // Example:
            // let dateFormatter = DateFormatter()
            // dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // Adjust to your date format
            // decoder.dateDecodingStrategy = .formatted(dateFormatter)

            let conferences = try decoder.decode([ConferenceDeadline].self, from: data)
            return conferences
        } catch let DecodingError.dataCorrupted(context) {
            print("Data corrupted error during decoding: \(context.debugDescription)")
            if let underlyingError = context.underlyingError {
                print("Underlying error: \(underlyingError)")
            }
        } catch let DecodingError.keyNotFound(key, context) {
            print("Key '\(key.stringValue)' not found: \(context.debugDescription)")
            print("codingPath: \(context.codingPath.map { $0.stringValue }.joined(separator: " -> "))")
        } catch let DecodingError.valueNotFound(value, context) {
            print("Value '\(value)' not found: \(context.debugDescription)")
            print("codingPath: \(context.codingPath.map { $0.stringValue }.joined(separator: " -> "))")
        } catch let DecodingError.typeMismatch(type, context) {
            print("Type '\(type)' mismatch: \(context.debugDescription)")
            print("codingPath: \(context.codingPath.map { $0.stringValue }.joined(separator: " -> "))")
            if let underlyingError = context.underlyingError {
                print("Underlying error: \(underlyingError)")
            }
        } catch {
            print("Error decoding \(fileName).\(fileExtension): \(error.localizedDescription)")
            print("Full error details: \(error)")
        }

        return []
    }
}
