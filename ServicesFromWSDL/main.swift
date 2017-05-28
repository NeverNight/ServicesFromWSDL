//
//  main.swift
//  ServicesFromWSDL
//
//  Created by Alex Apprime on 28.05.17.
//  Copyright © 2017 Farbflash. All rights reserved.
//

import Foundation


/// adjust it for your needs, it is used for the header of each swift file
let copyRightString = "Copyright (c) 2016 Farbflash. All rights reserved."
let dtoModuleName = "DLRModels"

if CommandLine.arguments.count < 3 {
    // Expecting a string but didn't receive it
    writeToStdError("Expected string argument defining the output folder and at least one path to an XML file!\n")
    writeToStdError("Usage: \(CommandLine.arguments[0]) [target directory] [xml file(s)...]\n")
    exit(EXIT_FAILURE)
}

let path = CommandLine.arguments[2]

let url = URL(fileURLWithPath: path)

// Check if the file exists, exit if not
var error: NSError?
if !(url as NSURL).checkResourceIsReachableAndReturnError(&error) {
    exit(EXIT_FAILURE)
}

let targetFolder: String? = CommandLine.arguments[1]

do {
    let xml = try XMLDocument(contentsOf: url, options: 0)

    if let parser = WSDLDefinitionParser(xmlData: xml) {
        let generator = XML2SwiftFiles(parser: parser)
        generator.generateFiles(inFolder: targetFolder)
    }
    // if there is more than one xml file specified
    // add them now to the array of elements:
    var i = 3
    while CommandLine.arguments.count > i {
        let thisPath = CommandLine.arguments[i]
        i += 1
        let thisUrl = URL(fileURLWithPath: thisPath)
        if let thisXML = try? XMLDocument(contentsOf: thisUrl, options: 0) {
            if let subparser = WSDLDefinitionParser(xmlData: thisXML) {
                let generator = XML2SwiftFiles(parser: subparser)
                generator.generateFiles(inFolder: targetFolder)
            }
        }
    }
}
catch let err as NSError {
    writeToStdError(err.localizedDescription)
    exit(EXIT_FAILURE)
}

// Finally, exit
exit(EXIT_SUCCESS)


