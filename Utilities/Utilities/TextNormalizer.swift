import Foundation

/// Replaces typographic (smart) characters with their plain ASCII equivalents
enum TextNormalizer {

    private static let replacements: [(String, String)] = [
        ("\u{2018}", "'"),  // left single quote  -> apostrophe
        ("\u{2019}", "'"),  // right single quote  -> apostrophe
        ("\u{201C}", "\""), // left double quote   -> quotation mark
        ("\u{201D}", "\""), // right double quote   -> quotation mark
        ("\u{2014}", "--"), // em dash             -> double hyphen
        ("\u{2013}", "-"),  // en dash             -> hyphen
    ]

    static func normalize(_ text: String) -> String {
        var result = text
        for (from, to) in replacements {
            result = result.replacingOccurrences(of: from, with: to)
        }
        return result
    }
}
