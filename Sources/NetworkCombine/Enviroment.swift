//
//  Enviroment.swift
//  MPBroker
//
//  Created by Maxim Alekseev on 17.10.2022.
//

import Foundation

/// Enum для получения url в зависимости от окружения
public enum Environment: String, CaseIterable {
	case development
	case production

	public static func getEnviroment(isTestMode: Bool) -> Environment {
		isTestMode ? .development : production
	}
}
