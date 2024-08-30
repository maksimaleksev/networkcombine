//
//  NetworkError.swift
//  DohodMobileLK
//
//  Created by Maxim Alekseev on 27.10.2023.
//  Copyright © 2023 ДОХОДЪ. All rights reserved.
//

import Foundation

/// Enum c сетевыми  ошибками
public enum HTTPError: LocalizedError {
	case badURL(_ error: String)
	case expiredRefreshToken
	case unauthorized(code: Int, description: String)
	case serverError(code: Int, description: String)
	case unknown(description: String)
	case decodingError(DecodingError)

	case nonHTTPResponse
	case requestFailed(code: Int, description: String)
	case networkError(Error)

	public var code: Int? {
		switch self {
		case .badURL, .unknown, .decodingError, .nonHTTPResponse, .networkError:
			nil
		case .expiredRefreshToken:
			401
		case .unauthorized(let code, _):
			code
		case .serverError(let code, _):
			code
		case .requestFailed(code: let code, _):
			code
		}
	}

	public var errorDescription: String? {
		switch self {
		case .badURL(let description):
			description
		case .expiredRefreshToken:
			"Refresh token expired"
		case .unauthorized(_, let description):
			description
		case .serverError(_, let description):
			description
		case .unknown(let description):
			description
		case .decodingError(let decodingError):
			decodingError.localizedDescription
		case .nonHTTPResponse:
			"Non HTTP Response"
		case .requestFailed(_, let description):
			description
		case .networkError(let error):
			error.localizedDescription
		}
	}

	public var isRetriable: Bool {
		switch self {
		case .decodingError, .badURL, .expiredRefreshToken, .unauthorized, .unknown:
			return false
		case .requestFailed(let status, _):
			let timeoutStatus = 408
			let rateLimitStatus = 429
			return [timeoutStatus, rateLimitStatus].contains(status)
		case .serverError, .networkError, .nonHTTPResponse:
			return true
		}
	}
}
