//
//  BaseExporter.swift
//  SwiftDTO
//
//  Created by Alex da Franca on 08.06.17.
//  Copyright © 2017 Farbflash. All rights reserved.
//

import Foundation

protocol DTOFileGenerator {
    func generateFiles(inFolder folderPath: String?)
}

class BaseExporter {
    let parser: WSDLDefinitionParser
    let protocolInitializerLookup: [String: [String]]

    init(parser: WSDLDefinitionParser, protocolInitializerLookup: [String: [String]]) {
        self.parser = parser
        self.protocolInitializerLookup = protocolInitializerLookup
    }

    let indent = "    "

    final func generateFiles(inFolder folderPath: String? = nil) {
        let info = ProcessInfo.processInfo
        let workingDirectory = info.environment["PWD"]
        let pwd = (folderPath ?? workingDirectory)!

        if let content = generateServiceCode() {
            writeContent(content, toFileAtPath: pathForClassName(parser.serviceName, inFolder: pwd, outputType: fileTypeExtension()))
        }
    }

    func generateServiceCode() -> String? {
        return "Override 'generateServiceCode()' in your concrete subclass of BaseExporter!"
    }

    func fileTypeExtension() -> OutputType {
        // Override 'fileTypeExtension()' in your concrete subclass of BaseExporter!
        // default type is swift
        return .swift
    }
}
