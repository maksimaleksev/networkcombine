//
//  IEndpoint+MultipartForm.swift
//  DohodMobileLK
//
//  Created by Maxim Alekseev on 23.05.2024.
//  Copyright © 2024 ДОХОДЪ. All rights reserved.
//

import Foundation

/// Создание запроса для отправки данных через multipart/form-data
public extension IEndpoint {
	/// Создать NetworkRequest с multipart/form-data
	/// - Parameters:
	/// - enviroment: Enviroment - среда тестовая/боевая
	/// - parameters: [String: String] - параметры query запроса
	/// - textData: [String: String] - текстовые даные для тела запроса
	/// - file: IFile данные файла для запроса
	/// - fileFieldKey: FileFieldKey ключ для поля с данными
	/// - Returns NetworkRequest
	func createMultipartFormRequest(
		enviroment: Environment,
		parameters: [String: String] = [:],
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
			ApiHeaderValue.multiPartForm.rawValue + boundary
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
}

internal extension IEndpoint {

	func makeTextField(key: String, value: String, in mutableData: NSMutableData, boundary: String) {
		guard let textData = value.data(using: .utf8),
			  let boundaryData = "\r\n--\(boundary)\r\n".data(using: .utf8),
			  let contentDispositionData = "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)
		else { return }
		mutableData.append(boundaryData)
		mutableData.append(contentDispositionData)
		mutableData.append(textData)
	}

	func makeFileField(file: IFile, in mutableData: NSMutableData, boundary: String, fieldKey: FileFieldKey) {
		guard let boundaryData = "\r\n--\(boundary)\r\n".data(using: .utf8),
			  let contentDispositionData =
				"Content-Disposition: form-data; name=\"\(fieldKey.rawValue)\"; filename=\"\(file.name)\"\r\n".data(using: .utf8),
			  let contentTypeData = "Content-Type: \(file.type?.mimeType ?? "")\r\n\r\n".data(using: .utf8),
			  let fileData = file.data
		else { return }
		mutableData.append(boundaryData)
		mutableData.append(contentDispositionData)
		mutableData.append(contentTypeData)
		mutableData.append(fileData)
	}

	func close(mutableData: NSMutableData, boundary: String) {
		guard let boundaryData = "\r\n--\(boundary)--\r\n".data(using: .utf8) else { return }
		mutableData.append(boundaryData)
	}
}
