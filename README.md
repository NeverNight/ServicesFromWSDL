# ServicesFromWSDL

Generate swift or java classes, which provide methods defined by the WSDL of a soap service

A macOS command line tool that generates Swift or Java code to interface with a soap service.

Use it in conjunction with the other tool [SwiftDTO](https://github.com/a7ex/SwiftDTO), which creates the required model classes.

Written in Swift 3.

## Features

- Processes WSDL files and creates appropriate methods for each service
- Generates immutable Swift struct definitions

## What is code generation?

Using a code generator is very different from using a library API. If you have never worked with a code generator before, check out [this blog post](https://ijoshsmith.com/2016/11/03/swift-json-library-vs-code-generation/) for a quick overview.

## How to get it

- Download the `ServicesFromWSDL` app binary from the latest [release](https://github.com/a7ex/SwiftDTO/tree/master/release)
- Copy `ServicesFromWSDL` to your desktop
- Open a Terminal window and run this command to give the app permission to execute:

```
chmod +x ~/Desktop/ServicesFromWSDL
```

Or build the tool in Xcode yourself:

- Clone the repository / Download the source code
- Build the project
- Open a Finder window to the executable file
- Drag `ServicesFromWSDL` from the Finder window to your desktop

## How to install it

Assuming that the `ServicesFromWSDL` app is on your desktop…

Open a Terminal window and run this command:
```
cp ~/Desktop/ServicesFromWSDL /usr/local/bin/
```
Verify `ServicesFromWSDL` is in your search path by running this in Terminal:
```
ServicesFromWSDL
```
You should see the tool respond like this:
```
Expected string argument defining the output folder and at least one path to an XML file!
Usage: ServicesFromWSDL [options]
...
```
Now that a copy of `ServicesFromWSDL` is in your search path, delete it from your desktop.

You're ready to go! 🎉

## How to use it

Open a Terminal window and pass `ServicesFromWSDL` a "-d" switch followed by a path to the directory, you want to output the class files and one or more WSDL files:
```
ServicesFromWSDL -d /path/to/outputDirectory/ /path/to/some/service.wsdl
```
The tool creates the swift files in the directory specified with the "-d" switch.
