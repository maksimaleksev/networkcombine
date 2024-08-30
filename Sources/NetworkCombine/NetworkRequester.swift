//
//  NetworkRequester.swift
//  Created by Maxim Alekseev on 17.10.2022.
//

import Combine
import Foundation

/// Класс для создания сетевых запросов
public final class NetworkRequester: INetworkRequester {

	/// Таймаут соединения
	public let requestTimeOut: Float

	/// Инициализатор
	public init(requestTimeOut: Float = 30) {
		self.requestTimeOut = requestTimeOut
	}

	/// Сетевой запрос для получения данных в формате T, T может быть любым классом или структурой подписанной под
	/// протоколы Decodable и Encodable
	/// - Parameter req: INetworkRequest сетевой запрос
	/// - Parameter keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy стратегия, используемая для автоматического
	/// изменения значения ключей перед декодированием.
	/// - Returns AnyPublisher<T, NetworkError> Паблишер с данными типа Т или сетевой ошибкой
	public func request<T>(
		_ req: INetworkRequest, keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .convertFromSnakeCase
	) -> AnyPublisher<T, HTTPError>
	where T: Decodable, T: Encodable {

		let sessionConfig = URLSessionConfiguration.default
		sessionConfig.timeoutIntervalForRequest = TimeInterval(req.requestTimeOut ?? requestTimeOut)

		guard let request = req.buildURLRequest() else {
			// Return a fail publisher if the url is invalid
			return AnyPublisher(
				Fail<T, HTTPError>(error: HTTPError.badURL("Invalid Url"))
			)
		}

		let decoder = JSONDecoder()
		decoder.keyDecodingStrategy = keyDecodingStrategy

		// We use the dataTaskPublisher from the URLSession which gives us a publisher to play around with.
		return URLSession.shared
			.dataTaskPublisher(for: request)
			.assumeHTTP()
			.responseData()
			.decoding(type: T.self, decoder: decoder)
			.eraseToAnyPublisher()
	}

	/// Сетевой запрос для получения данных
	/// - Parameter req: INetworkRequest сетевой запрос
	/// - Returns AnyPublisher<Data, NetworkError> Паблишер с данными или сетевой ошибкой
	public func requestData(_ req: INetworkRequest) -> AnyPublisher<Data, HTTPError> {

		let sessionConfig = URLSessionConfiguration.default
		sessionConfig.timeoutIntervalForRequest = TimeInterval(req.requestTimeOut ?? requestTimeOut)

		guard let request = req.buildURLRequest()  else {
			// Return a fail publisher if the url is invalid
			return AnyPublisher(
				Fail<Data, HTTPError>(error: HTTPError.badURL("Invalid Url"))
			)
		}

		// We use the dataTaskPublisher from the URLSession which gives us a publisher to play around with.
		return URLSession.shared
			.dataTaskPublisher(for: request)
			.assumeHTTP()
			.responseData()
			.eraseToAnyPublisher()
	}
}
