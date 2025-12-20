import Foundation

/// Utility for converting between LLVM MC encoding and SP3 encoding
enum LLVMEncodingConverter {

    /// Converts LLVM MC encoding to SP3 encoding
    /// - Parameter input: LLVM MC encoding string, e.g., "0xff,0xfe,0xff,0x65,0x0b,0xfe,0x00,0x00"
    /// - Returns: SP3 encoding string, e.g., "0x65fffeff 0x0000fe0b"
    static func llvmMcToSp3(_ input: String) -> String {
        // Process each line
        input.split(separator: "\n", omittingEmptySubsequences: false)
            .map { convertLineToSp3(String($0)) }
            .joined(separator: "\n")
    }

    /// Converts SP3 encoding to LLVM MC encoding
    /// - Parameter input: SP3 encoding string, e.g., "0x65fffeff 0x0000fe0b"
    /// - Returns: LLVM MC encoding string, e.g., "0xff,0xfe,0xff,0x65,0x0b,0xfe,0x00,0x00"
    static func sp3ToLlvmMc(_ input: String) -> String {
        // Process each line
        input.split(separator: "\n", omittingEmptySubsequences: false)
            .map { convertLineToLlvmMc(String($0)) }
            .joined(separator: "\n")
    }

    // MARK: - Private Helpers

    private static func convertLineToSp3(_ line: String) -> String {
        let trimmed = line.trimmingCharacters(in: .whitespaces)

        // Skip empty lines and comments
        if trimmed.isEmpty || trimmed.hasPrefix("//") {
            return line
        }

        // Parse comma-separated hex bytes
        let bytes = trimmed
            .split(separator: ",")
            .compactMap { parseHexByte(String($0)) }

        // Need at least 4 bytes and must be multiple of 4
        guard !bytes.isEmpty, bytes.count % 4 == 0 else {
            return line // Return original if invalid
        }

        // Convert each group of 4 bytes to a 32-bit word (little-endian to big-endian display)
        var words: [String] = []
        for i in stride(from: 0, to: bytes.count, by: 4) {
            let word = UInt32(bytes[i]) |
                      (UInt32(bytes[i + 1]) << 8) |
                      (UInt32(bytes[i + 2]) << 16) |
                      (UInt32(bytes[i + 3]) << 24)
            words.append(String(format: "0x%08x", word))
        }

        return words.joined(separator: " ")
    }

    private static func convertLineToLlvmMc(_ line: String) -> String {
        let trimmed = line.trimmingCharacters(in: .whitespaces)

        // Skip empty lines and comments
        if trimmed.isEmpty || trimmed.hasPrefix("//") {
            return line
        }

        // Parse space-separated 32-bit hex words
        let words = trimmed
            .split(separator: " ")
            .compactMap { parseHexWord(String($0)) }

        guard !words.isEmpty else {
            return line // Return original if invalid
        }

        // Convert each 32-bit word to 4 bytes (big-endian display to little-endian bytes)
        var bytes: [String] = []
        for word in words {
            bytes.append(String(format: "0x%02x", word & 0xFF))
            bytes.append(String(format: "0x%02x", (word >> 8) & 0xFF))
            bytes.append(String(format: "0x%02x", (word >> 16) & 0xFF))
            bytes.append(String(format: "0x%02x", (word >> 24) & 0xFF))
        }

        return bytes.joined(separator: ",")
    }

    private static func parseHexByte(_ string: String) -> UInt8? {
        let trimmed = string.trimmingCharacters(in: .whitespaces).lowercased()
        let hex = trimmed.hasPrefix("0x") ? String(trimmed.dropFirst(2)) : trimmed
        return UInt8(hex, radix: 16)
    }

    private static func parseHexWord(_ string: String) -> UInt32? {
        let trimmed = string.trimmingCharacters(in: .whitespaces).lowercased()
        let hex = trimmed.hasPrefix("0x") ? String(trimmed.dropFirst(2)) : trimmed
        return UInt32(hex, radix: 16)
    }
}

