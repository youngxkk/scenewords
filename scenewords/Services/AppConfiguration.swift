import Foundation

struct AppConfiguration {
    let apiBaseURL: URL?
    let apiToken: String?

    static func current(bundle: Bundle = .main) -> AppConfiguration {
        let infoURL = (bundle.object(forInfoDictionaryKey: "SCENEWORDS_API_BASE_URL") as? String)?.swTrimmed
        let infoToken = (bundle.object(forInfoDictionaryKey: "SCENEWORDS_API_TOKEN") as? String)?.swTrimmed

        // Fallback for cases where custom INFOPLIST_KEY_* is not emitted into Info.plist.
        let envURL = ProcessInfo.processInfo.environment["SCENEWORDS_API_BASE_URL"]?.swTrimmed
        let envToken = ProcessInfo.processInfo.environment["SCENEWORDS_API_TOKEN"]?.swTrimmed

        let rawURL = nonEmpty(infoURL) ?? nonEmpty(envURL) ?? nonEmpty(DeveloperAPISecrets.apiBaseURL.swTrimmed)
        let rawToken = nonEmpty(infoToken) ?? nonEmpty(envToken) ?? nonEmpty(DeveloperAPISecrets.apiToken.swTrimmed)

        let url = rawURL.flatMap { value -> URL? in
            guard !value.isEmpty else { return nil }
            return URL(string: value)
        }

        let token = rawToken.flatMap { value -> String? in
            value.isEmpty ? nil : value
        }

        return AppConfiguration(apiBaseURL: url, apiToken: token)
    }

    private static func nonEmpty(_ value: String?) -> String? {
        guard let value, !value.isEmpty else { return nil }
        return value
    }
}
