#if MOCK
import Foundation
import UIKit

struct UITestAIServices: AIServicesContainer {
    let imageService: AIImageService
    let textService: AITextService

    init(scenario: UITestScenario) {
        imageService = UITestImageService(scenario: scenario)
        textService = UITestTextService(scenario: scenario)
    }
}

struct UITestImageService: AIImageService {
    let scenario: UITestScenario

    func generateImage(input: String) async throws -> UIImage {
        try await Task.sleep(for: .seconds(scenario == .imageFailure ? 2 : 0.25))
        if scenario == .imageFailure { throw UITestFailure.requested }
        guard let image = UIImage(systemName: "star.fill") else { throw UITestFailure.requested }
        return image
    }
}

struct UITestTextService: AITextService {
    let scenario: UITestScenario

    func generateText(input: String) async throws -> String {
        if scenario == .slowReply { try await Task.sleep(for: .seconds(2)) }
        if scenario == .replyFailure { throw UITestFailure.requested }
        return UITestFixture.reply
    }
}
#endif
