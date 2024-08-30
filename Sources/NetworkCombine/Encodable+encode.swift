//
//  File.swift
//  
//
//  Created by Maxim Alekseev on 30.08.2024.
//

import Foundation

internal extension Encodable {
	func encode() -> Data? {
		do {
			let encoder = JSONEncoder()
			return try encoder.encode(self)
		} catch {
			ActivityLogger.error("Error encoding data: \(error.localizedDescription)", type: .other)
			return nil
		}
	}
}
