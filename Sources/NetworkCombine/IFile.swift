//
//  File.swift
//  
//
//  Created by Maxim Alekseev on 30.08.2024.
//

import Foundation

public protocol IFile {
	var data: Data? { get }
	var name: String { get }
	var type: FileType? { get }
	var ext: String { get }
}

public enum FileType: String {
	case jpeg
	case png
	case pdf

	var mimeType: String {
		switch self {
		case .jpeg: return "image/jpeg"
		case .png: return "image/png"
		case .pdf: return "application/pdf"
		}
	}
}
