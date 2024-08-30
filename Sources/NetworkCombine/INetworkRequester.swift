//
//  Requestable.swift
//  MPBroker
//
//  Created by Maxim Alekseev on 17.10.2022.
//

import Foundation
import Combine

/// Протокол для создания сетевых запросов
public protocol INetworkRequester: AnyObject {
	/// Таймаут соединения
	var requestTimeOut: Float { get }

	/// Сетевой запрос для получения данных в формате T, T может быть любым классом или структурой подписанной под
	/// протоколы Decodable и Encodable
	/// - Parameter req: INetworkRequest сетевой запрос
	/// - Parameter keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy стратегия, используемая для автоматического
	/// изменения значения ключей перед декодированием.
	/// - Returns AnyPublisher<T, NetworkError> Паблишер с данными типа Т или сетевой ошибкой
	func request<T: Codable>(
		_ req: INetworkRequest,
		keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy
	) -> AnyPublisher<T, HTTPError>

	/// Сетевой запрос для получения данных
	/// - Parameter req: INetworkRequest сетевой запрос
	/// - Returns AnyPublisher<Data, NetworkError> Паблишер с данными или сетевой ошибкой
	func requestData(_ req: INetworkRequest) -> AnyPublisher<Data, HTTPError>
}
