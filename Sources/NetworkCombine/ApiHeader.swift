//
//  ApiHeader.swift
//  DohodMobileLK
//
//  Created by Maxim Alekseev on 20.03.2024.
//  Copyright © 2024 ДОХОДЪ. All rights reserved.
//

import Foundation

/// Часто используемые ключи для заголовка сетевых запросов
public enum ApiHeaderKey: String {
	case accept = "Accept"
	case acceptEncoding = "Accept-Encoding"
	case contentType = "Content-Type"
	case authorization = "Authorization"
	case xSecret = "X-Secret"
	case connection = "Connection"
}

/// Часто используемые значения заголовка сетевых запросов
public enum ApiHeaderValue: String {
	case applicationJSON = "application/json"
	case multiPartForm = "multipart/form-data; boundary="
	case acceptType = "*/*"
	case acceptEncodingValue = "gzip,deflate, br"
	case connectionValue = "keep-alive"
	case bearer = "Bearer"
}
