import Foundation
import UIKit
import Testing
@testable import AIChat

@MainActor
struct AIManagerTests {

    @Test("Generating text forwards the exact prompt and returns the service response", arguments: ["Hello", "", "Hello 👋 مرحباً\nSecond line"])
    func generateText_forwardsInputAndReturnsResult(input: String) async throws {
        let text = RecordingAITextService()
        text.output = "Generated response"
        let image = RecordingAIImageService()
        let manager = AIManager(aiServices: TestAIServices(imageService: image, textService: text))

        let result = try await manager.generateText(input: input)

        #expect(result == "Generated response")
        #expect(text.inputs == [input])
        #expect(image.inputs.isEmpty)
    }

    @Test("Generating text preserves an empty service response")
    func generateText_preservesEmptyResponse() async throws {
        let text = RecordingAITextService()
        text.output = ""
        let manager = AIManager(aiServices: TestAIServices(imageService: RecordingAIImageService(), textService: text))

        #expect(try await manager.generateText(input: "prompt") == "")
    }

    @Test("Generating an image forwards the prompt and returns the same image instance")
    func generateImage_forwardsInputAndReturnsResult() async throws {
        let image = RecordingAIImageService()
        let text = RecordingAITextService()
        let manager = AIManager(aiServices: TestAIServices(imageService: image, textService: text))

        let result = try await manager.generateImage(input: "An alien in the park")

        #expect(result === image.output)
        #expect(image.inputs == ["An alien in the park"])
        #expect(text.inputs.isEmpty)
    }

    @Test("Text generation propagates the service error without calling the image service")
    func generateText_propagatesError() async {
        let text = RecordingAITextService()
        text.error = ManagerTestError.requested
        let image = RecordingAIImageService()
        let manager = AIManager(aiServices: TestAIServices(imageService: image, textService: text))

        await #expect(throws: ManagerTestError.requested) {
            try await manager.generateText(input: "prompt")
        }
        #expect(text.inputs == ["prompt"])
        #expect(image.inputs.isEmpty)
    }

    @Test("Image generation propagates the service error without calling the text service")
    func generateImage_propagatesError() async {
        let image = RecordingAIImageService()
        image.error = ManagerTestError.requested
        let text = RecordingAITextService()
        let manager = AIManager(aiServices: TestAIServices(imageService: image, textService: text))

        await #expect(throws: ManagerTestError.requested) {
            try await manager.generateImage(input: "prompt")
        }
        #expect(image.inputs == ["prompt"])
        #expect(text.inputs.isEmpty)
    }
}

@MainActor
private struct TestAIServices: AIServicesContainer {
    let imageService: any AIImageService
    let textService: any AITextService
}

@MainActor
private final class RecordingAITextService: AITextService {
    var inputs: [String] = []
    var output = "response"
    var error: Error?

    func generateText(input: String) async throws -> String {
        inputs.append(input)
        if let error { throw error }
        return output
    }
}

@MainActor
private final class RecordingAIImageService: AIImageService {
    var inputs: [String] = []
    let output = UIImage()
    var error: Error?

    func generateImage(input: String) async throws -> UIImage {
        inputs.append(input)
        if let error { throw error }
        return output
    }
}
