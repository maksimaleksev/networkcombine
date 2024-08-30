//
//  INetworkRequest.swift
//  DohodMobileLK
//
//  Created by Maxim Alekseev on 27.10.2023.
//  Copyright © 2023 ДОХОДЪ. All rights reserved.
//

import Foundation

/// Протокол сетевого запроса
public protocol INetworkRequest {
	/// Создать URLRequest
	var requestTimeOut: Float? { get }
	/// Таймаут
	func buildURLRequest() -> URLRequest?
}
