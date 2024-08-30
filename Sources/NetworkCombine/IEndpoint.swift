//
//  EndpointProtocol.swift
//  DohodMobileLK
//
//  Created by Maxim Alekseev on 17.08.2023.
//  Copyright © 2023 ДОХОДЪ. All rights reserved.
//

import Foundation

public protocol IEndpoint {
	/// Таймаут сетевого запроса в секундах
	var requestTimeOut: Int { get }
	var httpMethod: HTTPMethod { get }
	var requestBody: Encodable? { get }
	var headers: [String: String] { get }

	/// Метод создает NetworkRequest без access token
	/// - Parameter enviroment: Enviroment среда (тестовая/промышленная)
	/// - Parameter parameters: [String: String] - параметры запроса
	/// - Returns NetworkRequest: Сетевой запрос
	func getURL(enviroment: Environment) -> String
}

public extension IEndpoint {

	/// Таймаут сетевого запроса в секундах
	var requestTimeOut: Int {
		return 30
	}

	var headers: [String: String] {
		return [
			ApiHeaderKey.accept.rawValue: ApiHeaderValue.acceptType.rawValue,
			ApiHeaderKey.acceptEncoding.rawValue: ApiHeaderValue.acceptEncodingValue.rawValue,
			ApiHeaderKey.contentType.rawValue: ApiHeaderValue.applicationJSON.rawValue,
			ApiHeaderKey.connection.rawValue: ApiHeaderValue.connectionValue.rawValue
		]
	}

	/// Метод создает NetworkRequest без access token
	/// - Parameter enviroment: Enviroment среда (тестовая/промышленная)
	/// - Parameter parameters: [String: String] - параметры запроса
	/// - Returns NetworkRequest: Сетевой запрос
	func createRequest(enviroment: Environment, parameters: [String: String] = [:]) -> NetworkRequest {

		let request = NetworkRequest(
			url: getURL(enviroment: enviroment),
			headers: headers,
			parameters: parameters,
			reqBody: requestBody,
			httpMethod: httpMethod
		)
		return request
	}
}

public protocol IEndpointProtected: IEndpoint {
	/// Метод создает NetworkRequest с access token
	/// - Parameter enviroment: Enviroment среда (тестовая/промышленная)
	/// - Parameter parameters: [String: String] - параметры запроса
	/// - Parameter tokenAccess: String - access token
	/// - Returns NetworkRequest: Сетевой запрос
	func createRequest(enviroment: Environment, parameters: [String: String], tokenAccess: String) -> NetworkRequest

	/// Метод создает NetworkRequest с access token
	/// - Parameter enviroment: Enviroment среда (тестовая/промышленная)
	/// - Parameter parameters: [String: String] - параметры запроса
	/// - Parameter tokenAccess: String - access token
	/// - Parameter textData: текстовые данные
	/// - Parameter file: IFile данные файла для запроса
	/// - Returns NetworkRequest: Сетевой запрос
	func createMultipartRequest( // swiftlint: disable:this function_parameter_count
		enviroment: Environment,
		parameters: [String: String],
		tokenAccess: String,
		textData: [String: String],
		file: IFile?,
		fileFieldKey: FileFieldKey
	) -> NetworkRequest
}

public extension IEndpointProtected {
	/// Метод создает NetworkRequest с access token
	/// - Parameter enviroment: Enviroment среда (тестовая/промышленная)
	/// - Parameter parameters: [String: String] - параметры запроса
	/// - Parameter tokenAccess: String - access token
	/// - Returns NetworkRequest: Сетевой запрос
	func createRequest(
		enviroment: Environment, parameters: [String: String] = [:], tokenAccess: String
	) -> NetworkRequest {
		let headersProtected: [String: String] = getHeader(enviroment: enviroment, tokenAccess: tokenAccess)

		let request = NetworkRequest(
			url: getURL(enviroment: enviroment),
			headers: headersProtected,
			parameters: parameters,
			reqBody: requestBody,
			httpMethod: httpMethod
		)
		return request
	}

	/// Метод создает NetworkRequest с access token
	/// - Parameter enviroment: Enviroment среда (тестовая/промышленная)
	/// - Parameter parameters: [String: String] - параметры запроса
	/// - Parameter tokenAccess: String - access token
	/// - Parameter textData: текстовые данные
	/// - Parameter file: IFile данные файла для запроса
	/// - Parameter fileFieldKey: FileFieldKey ключ для поля с данными
	/// - Returns NetworkRequest: Сетевой запрос
	func createMultipartRequest( // swiftlint: disable:this function_parameter_count
		enviroment: Environment,
		parameters: [String: String],
		tokenAccess: String,
		textData: [String: String],
		file: IFile?,
		fileFieldKey: FileFieldKey
	) -> NetworkRequest {
		let boundary = UUID().uuidString
		let headerFields = [
			ApiHeaderKey.accept.rawValue: ApiHeaderValue.acceptType.rawValue,
			ApiHeaderKey.acceptEncoding.rawValue: ApiHeaderValue.acceptEncodingValue.rawValue,
			ApiHeaderKey.connection.rawValue: ApiHeaderValue.connectionValue.rawValue,
			ApiHeaderKey.contentType.rawValue:
				ApiHeaderValue.multiPartForm.rawValue + boundary,
			ApiHeaderKey.authorization.rawValue: ApiHeaderValue.bearer.rawValue + " " + "\(tokenAccess)"
		]
		let mutableData = NSMutableData()
		if !textData.isEmpty {
			for (key, value) in textData {
				makeTextField(key: key, value: value, in: mutableData, boundary: boundary)
			}
		}
		if let file {
			makeFileField(file: file, in: mutableData, boundary: boundary, fieldKey: fileFieldKey)
		}
		close(mutableData: mutableData, boundary: boundary)
		return NetworkRequest(
			url: getURL(enviroment: enviroment),
			headers: headerFields,
			parameters: parameters,
			multipartData: mutableData as Data,
			reqTimeout: Float(requestTimeOut),
			httpMethod: httpMethod
		)
	}

	private func getHeader(enviroment: Environment, tokenAccess: String) -> [String: String] {
		return [
			ApiHeaderKey.accept.rawValue: ApiHeaderValue.applicationJSON.rawValue,
			ApiHeaderKey.contentType.rawValue: ApiHeaderValue.applicationJSON.rawValue,
			ApiHeaderKey.authorization.rawValue: ApiHeaderValue.bearer.rawValue + " " + "\(tokenAccess)"
		]
	}
}
