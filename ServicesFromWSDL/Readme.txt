Create services providers at AUTHORTIME(!) from one or more wsdl descriptions

In order to create services files from one or more wsdl definitions:
In the terminal change into this directory and execute:

./ServicesFromWSDL -d ../GeneratedFiles -m swift wsdlDefinitions/*.xml

That will read in the xml files <2 parameter>...<n parameter> and output the generated swift files into the folder <1nd parameter>

IMPORTANT NOTE:
This program will NOT change your Xcode project file! It won't remove nor add files to your project.

If you have ADDED a NEW wsdl definition:
- generate all files with ServicesFromWSDL (see above)
- in Xcode right click on the folder "GeneratedFiles" and choose "Add files to <project name>..."
and select the file corresponding to the entity, which you created, and add it to the project.

If you DELETED an existing entity:
- generate all files with ServicesFromWSDL (see above)
- delete the corresponding class file in Xcode (select "move to trash" in the confirmation dialog)

If you changed the name of an existing entity:
follow the steps above to ADD a new file AND follow the steps to remove the file with the old name


ALTERNATIVE:
If you have made a large number of changes, just move all contents of "GeneratedFiles" to the trash, from within Xcode, then generate all files with ServicesFromWSDL (see above) and then add all new files again in Xcode
