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

let options = CliArguments()
guard let firstInputFile = options.paths.first,
    let targetFolder = options.destination.nonEmptyString else {
        // Expecting a string but didn't receive it
        writeToStdError("Expected string argument defining the output folder and at least one path to an XML file!\n")
        options.printHelpText()
        exit(EXIT_FAILURE)
}

let url = URL(fileURLWithPath: firstInputFile)

// Check if the file exists, exit if not
var error: NSError?
if !(url as NSURL).checkResourceIsReachableAndReturnError(&error) {
    exit(EXIT_FAILURE)
}

let protocolParentLookup = readProtocolParentLookup(targetFolder: targetFolder)

do {
    let xml = try XMLDocument(contentsOf: url, options: 0)

    if let parser = WSDLDefinitionParser(xmlData: xml, serviceIdentifier: filename(for: url)) {
        let generator: DTOFileGenerator
        switch options.mode {
        case .swift:
            generator = XML2SwiftFiles(parser: parser,
                                       protocolInitializerLookup: protocolParentLookup)
        case .java:
            generator = XML2JavaFiles(parser: parser,
                                       protocolInitializerLookup: protocolParentLookup)
        }
        generator.generateFiles(inFolder: targetFolder)
    }
    // if there is more than one xml file specified
    // process them now:
    for thisPath in options.paths[1..<options.paths.count] {
        let thisUrl = URL(fileURLWithPath: thisPath)
        if let thisXML = try? XMLDocument(contentsOf: thisUrl, options: 0) {
            if let subparser = WSDLDefinitionParser(xmlData: thisXML, serviceIdentifier: filename(for: thisUrl)) {
                let generator: DTOFileGenerator
                switch options.mode {
                case .swift:
                    generator = XML2SwiftFiles(parser: subparser,
                                                   protocolInitializerLookup: protocolParentLookup)
                case .java:
                    generator = XML2JavaFiles(parser: subparser,
                                               protocolInitializerLookup: protocolParentLookup)
                }
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
