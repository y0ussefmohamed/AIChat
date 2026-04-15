//
//  FileManager+EXT.swift
//  AIChat
//
//  Created by Youssef Mohamed on 15/04/2026.
//

import Foundation

extension FileManager {

    enum DocumentError: Error {
        case fileNotFound
        case encodingError
        case decodingError
    }

    private static var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    /// Saves a Codable object to a .txt file.
    /// - Parameters:
    ///   - key: The filename (without extension).
    ///   - value: The object to save. If nil, the file is deleted.
    static func saveDocument<T: Encodable>(key: String, value: T?) throws {
        let url = documentsDirectory.appendingPathComponent(key).appendingPathExtension("txt")

        // If value is nil, attempt to remove the existing file
        guard let value = value else {
            if FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.removeItem(at: url)
            }
            return
        }

        // Encode and write to disk
        do {
            let data = try JSONEncoder().encode(value)
            try data.write(to: url, options: .atomic)
        } catch {
            throw DocumentError.encodingError
        }
    }

    /// Retrieves a Codable object from a .txt file.
    /// - Parameter key: The filename (without extension).
    /// - Returns: The decoded object of type T.
    static func getDocument<T: Decodable>(key: String) throws -> T {
        let url = documentsDirectory.appendingPathComponent(key).appendingPathExtension("txt")

        guard FileManager.default.fileExists(atPath: url.path) else {
            throw DocumentError.fileNotFound
        }

        let data = try Data(contentsOf: url)

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw DocumentError.decodingError
        }
    }
}
