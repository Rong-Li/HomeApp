//
//  AppConfig.swift
//  HomeApp
//
//  Reads configuration from Config.xcconfig
//

import Foundation

enum AppConfig {
    static var apiBearerToken: String {
        guard let token = Bundle.main.object(forInfoDictionaryKey: "API_BEARER_TOKEN") as? String else {
            return ""
        }
        return token
    }
}
