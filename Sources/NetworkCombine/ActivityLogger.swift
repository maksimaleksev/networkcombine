//
//  File.swift
//  
//
//  Created by Maxim Alekseev on 30.08.2024.
//

import Foundation
import OSLog

/// Логгер событий в проекте
internal enum ActivityLogger {

	/// Типы для логов
	enum LogType: String {
		case network = "NETWORK"
		case other = "OTHER"
	}

	// MARK: - Private properties

	private static let bundleIdentifier = Bundle.main.identifier

	// MARK: - Public methods

	/// Информационные сообщения в консоль
	/// - Parameter data: данные для сообщения
	/// - Parameter type: тип лога
	/// - Parameter file: имя файла в проекте в котором произошел вызов
	/// - Parameter line: номер строки вызова функции в файле
	static func info(_ data: @autoclosure () -> Any?, type: LogType = .other, file: String = #file, line: Int = #line) {
#if DEBUG

		let queue = Thread.isMainThread ? "UI" : "BG"

		var logContent = "ℹ️\n[START]:\n\n\(String(describing: data() ?? "nil"))\n"
		logContent += "\n[TYPE]: \(type.rawValue)"
		logContent += "\n[QUEUE]: \(queue)"
		logContent += "\n[LINE]: \(line)"
		logContent += "\n[FILE]: \(extractFileName(from: file))"
		logContent += "\n[END]\n"

		let logger = Logger(subsystem: bundleIdentifier, category: type.rawValue)
		logger.info("\(logContent)")
#endif
	}

	/// Сообщения для отладки в консоль
	/// - Parameter data: данные для сообщения
	/// - Parameter type: тип лога
	/// - Parameter file: имя файла в проекте в котором произошел вызов
	/// - Parameter line: номер строки вызова функции в файле
	static func debug(_ data: @autoclosure () -> Any?, type: LogType = .other, file: String = #file, line: Int = #line) {
#if DEBUG

		let queue = Thread.isMainThread ? "UI" : "BG"

		var logContent = "💊\n[START]:\n\n\(String(describing: data() ?? "nil"))\n"
		logContent += "\n[TYPE]: \(type.rawValue)"
		logContent += "\n[QUEUE]: \(queue)"
		logContent += "\n[LINE]: \(line)"
		logContent += "\n[FILE]: \(extractFileName(from: file))"
		logContent += "\n[END]\n"

		let logger = Logger(subsystem: bundleIdentifier, category: type.rawValue)
		logger.debug("\(logContent)")
#endif
	}

	/// Сообщения о предупреждениях в консоль
	/// - Parameter data: данные для сообщения
	/// - Parameter type: тип лога
	/// - Parameter file: имя файла в проекте в котором произошел вызов
	/// - Parameter line: номер строки вызова функции в файле
	static func warning(_ data: @autoclosure () -> Any?, type: LogType, file: String = #file, line: Int = #line) {
#if DEBUG
		let queue = Thread.isMainThread ? "UI" : "BG"

		var logContent = "⚠️\n[START]:\n\n\(String(describing: data() ?? "nil"))\n"
		logContent += "\n[TYPE]: \(type.rawValue)"
		logContent += "\n[QUEUE]: \(queue)"
		logContent += "\n[LINE]: \(line)"
		logContent += "\n[FILE]: \(extractFileName(from: file))"
		logContent += "\n[END]\n"

		let logger = Logger(subsystem: bundleIdentifier, category: type.rawValue)
		logger.warning("\(logContent)")
#endif
	}

	/// Сообщения об ошибках в консоль
	/// - Parameter data: данные для сообщения
	/// - Parameter type: тип лога
	/// - Parameter file: имя файла в проекте в котором произошел вызов
	/// - Parameter line: номер строки вызова функции в файле
	static func error(_ data: @autoclosure () -> Any?, type: LogType, file: String = #file, line: Int = #line) {
#if DEBUG
		let queue = Thread.isMainThread ? "UI" : "BG"

		var logContent = "❌\n[START]:\n\n\(String(describing: data() ?? "nil"))\n"
		logContent += "\n[TYPE]: \(type.rawValue)"
		logContent += "\n[QUEUE]: \(queue)"
		logContent += "\n[LINE]: \(line)"
		logContent += "\n[FILE]: \(extractFileName(from: file))"
		logContent += "\n[END]\n"

		let logger = Logger(subsystem: bundleIdentifier, category: type.rawValue)
		logger.error("\(logContent)")
#endif
	}

	// MARK: - Private methods

	private static func extractFileName(from path: String) -> String {
		return path.components(separatedBy: "/").last ?? ""
	}
}
