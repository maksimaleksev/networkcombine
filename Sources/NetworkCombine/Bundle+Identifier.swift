//
//  File.swift
//  
//
//  Created by Maxim Alekseev on 30.08.2024.
//

import Foundation
extension Bundle {
	enum PlistKey: String {
		case identifier = "CFBundleIdentifier"
	}

	/// Application identifier
	public var identifier: String { getInfoStringValue(.identifier) }

	private func getInfoStringValue(_ key: PlistKey) -> String { infoDictionary?[key.rawValue] as? String ?? "⚠️" }
}
