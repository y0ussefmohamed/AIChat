//
//  FirebaseImageUploadService.swift
//  AIChat
//
//  Created by Youssef Mohamed on 16/04/2026.
//

import Foundation
import SwiftUI
@preconcurrency import UIKit
@preconcurrency import FirebaseStorage

protocol ImageUploadDataService: Sendable {
    func uploadImage(image: UIImage, path: String) async throws -> URL
    func deleteImage(path: String) async throws
}

struct FirebaseImageUploadService: ImageUploadDataService {

    func uploadImage(image: UIImage, path: String) async throws -> URL {
        guard let data = image.jpegData(compressionQuality: 1.0) else {
            throw URLError(.dataNotAllowed)
        }

        // Upload
        try await Self.saveImage(data: data, path: path)

        // Get Download Url
        let url = try await Self.imageReference(for: path).downloadURL()

        return url
    }

    private static func imageReference(for path: String) -> StorageReference {
        let fileName = "\(path).jpg"
        return Storage.storage().reference(withPath: fileName)
    }

    @discardableResult
    private static func saveImage(data: Data, path: String) async throws -> URL {
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        let returnedMetadata = try await imageReference(for: path).putDataAsync(data, metadata: metadata)

        guard let returnedPath = returnedMetadata.path, let url = URL(string: returnedPath) else {
            throw URLError(.badServerResponse)
        }

        return url
    }

    func deleteImage(path: String) async throws {
        try await Self.imageReference(for: path).delete()
    }
}
