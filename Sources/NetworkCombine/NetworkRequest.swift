//
//  NetworkRequest.swift
//  MPBroker
//
//  Created by Maxim Alekseev on 17.10.2022.
//

import Foundation

public final class NetworkRequest: INetworkRequest {
	/// URL в формате строки
	public let url: String
	/// Заголовок запроса
	public let headers: [String: String]?
	/// Данные для тела запроса
	public var body: Data?
	/// Таймаут
	public var requestTimeOut: Float?
	/// HTTP Метод (GET, POST, PUT, DELETE)
	public let httpMethod: HTTPMethod
	/// Параметры запроса (query)
	public let parameters: [String: String]

	/// Инициализатор для JSON
	/// - Parameter url: String URL в формате строки
	/// - Parameter headers: [String: String] Заголовок запроса
	/// - Parameter parameters: [String: String] Параметры запроса (query)
	/// - Parameter reqBody: Encodable Данные для тела запроса
	/// - Parameter requestTimeOut: Float Таймаут
	/// - Parameter httpMethod: HTTPSMethod  HTTP Метод (GET, POST, PUT, DELETE)
	public init(
		url: String,
		headers: [String: String]? = nil,
		parameters: [String: String] = [:],
		reqBody: Encodable? = nil,
		reqTimeout: Float? = nil,
		httpMethod: HTTPMethod
	) {
		self.url = url
		self.headers = headers
		self.body = reqBody?.encode()
		self.requestTimeOut = reqTimeout
		self.httpMethod = httpMethod
		self.parameters = parameters
	}

	/// Инициализатор для multipart-form-data
	/// - Parameter url: String URL в формате строки
	/// - Parameter headers: [String: String] Заголовок запроса
	/// - Parameter parameters: [String: String] Параметры запроса (query)
	/// - Parameter multipartData: Data Данные для тела запроса
	/// - Parameter requestTimeOut: Float Таймаут
	/// - Parameter httpMethod: HTTPSMethod  HTTP Метод (GET, POST, PUT, DELETE)
	public init(
		url: String,
		headers: [String: String]? = nil,
		parameters: [String: String] = [:],
		multipartData: Data? = nil,
		reqTimeout: Float? = nil,
		httpMethod: HTTPMethod
	) {
		self.url = url
		self.headers = headers
		self.body = multipartData
		self.requestTimeOut = reqTimeout
		self.httpMethod = httpMethod
		self.parameters = parameters
	}

	/// Создать URLRequest
	public func buildURLRequest() -> URLRequest? {
		guard var urlComponents = URLComponents(string: url) else { return nil }
		if !parameters.isEmpty {
			let queryItems = parameters.map { key, value in URLQueryItem(name: key, value: value) }
			urlComponents.queryItems = queryItems
		}
		if let url = urlComponents.url {
			var urlRequest = URLRequest(url: url)
			urlRequest.httpMethod = httpMethod.rawValue
			urlRequest.allHTTPHeaderFields = headers ?? [:]
			urlRequest.httpBody = body
			return urlRequest
		}

		return nil
	}
}
