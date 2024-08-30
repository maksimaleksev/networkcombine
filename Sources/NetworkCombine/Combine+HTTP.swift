//
//  Combine+HTTP.swift
//  DohodMobileLK
//
//  Created by Maxim Alekseev on 19.08.2024.
//  Copyright © 2024 ДОХОДЪ. All rights reserved.
//

import Foundation
import Combine

// swiftlint:disable missing_docs

public extension Publisher where Output == (data: Data, response: URLResponse) {

	func assumeHTTP() -> AnyPublisher<(data: Data, response: HTTPURLResponse), HTTPError> {
		tryMap { (data: Data, response: URLResponse) -> (Data, HTTPURLResponse) in
			guard let http = response as? HTTPURLResponse else {
				throw HTTPError.nonHTTPResponse
			}
			return (data, http)
		}
		.mapError { error in
			if error is HTTPError {
				return error as! HTTPError // swiftlint:disable:this force_cast
			} else {
				return HTTPError.networkError(error)
			}
		}
		.eraseToAnyPublisher()
	}
}

public extension Publisher where Output == (data: Data, response: HTTPURLResponse), Failure == HTTPError {

	func responseData() -> AnyPublisher<Data, HTTPError> {
		tryMap { (data: Data, response: HTTPURLResponse) -> Data in
			switch response.statusCode {
			case 200...299:
				return data
			case 400...499:
				throw HTTPError.requestFailed(code: response.statusCode, description: response.debugDescription)
			case 500...599:
				throw HTTPError.serverError(code: response.statusCode, description: response.debugDescription)
			default:
				throw HTTPError.unknown(description: "Unknown network error")
			}
		}
		.mapError { $0 as! HTTPError } // swiftlint:disable:this force_cast
		.eraseToAnyPublisher()
	}
}

public extension Publisher where Output == Data, Failure == HTTPError {

	func decoding<Item, Coder>(type: Item.Type, decoder: Coder) -> AnyPublisher<Item, HTTPError>
	where
Item: Decodable,
Coder: TopLevelDecoder,
	Self.Output == Coder.Input {
		decode(type: type, decoder: decoder)
			. mapError { error in
				if error is DecodingError {
					HTTPError.decodingError(error as! DecodingError) // swiftlint:disable:this force_cast
				} else {
					error as! HTTPError // swiftlint:disable:this force_cast
				}
			}
			.eraseToAnyPublisher()
	}
}
// swiftlint:enable missing_docs
