//%attributes = {"folder":"Developer Quick Open","lang":"en"}
/* This method builds the master list of items used by the Quick Open module. Rather than use built in
commands, we simply scan the file system for what is needed. The idea is to build a collection that
has a list of classes, methods, forms, database methods, and triggers with knowledge about what
folder each one is in and whether each has documentation (i.e. a .md file) associated with it.

In addition to these 4D items, the code checks to see if there is a DevDocs folder located at the
same level as 4D's Documentation folder. This folder can be used to store a hierarchy of .md files
which describe a project in ways that aren't easily directly associated with a method, class, or form.

The following is built:
- masterList (a collection of objects, each of which has the following keys)
  - type (Class, Method, Form, DB Method, Trigger, DevDoc)
  - name
  - folder (just the folder it is in—not the hierarchy. For DevDocs, this will be the relative path
    to the .md file. It is relative to the DevDocs folder and always starts with a "/". Examples:
    index.md at the top level of DevDocs: "/". example.md in a subfolder: "/subfolder/".
  - hasDocs (True if the item already has an associated .md file)

4D documentation on a project's file structure can be found in these places:
  - https://developer.4d.com/docs/en/Project/architecture.html
  - https://developer.4d.com/docs/en/Project/documentation.html

Note that table forms are not included in the list. Why? Well, because I don't use them. If anyone
still does, they can add them to the code as desired.
*/

C_COLLECTION($0; $cMasterList)

$cMasterList:=New collection

C_LONGINT($x; $lFind; $lTableNumber; $lBasePathLength)
C_TEXT($tBasePath; $tSourcesPath; $tDocumentationPath; $tItemsPath; $tDocsPath; $tFolderName; $tFoldersPath)
C_TEXT($tJSONString; $tName; $tDocName; $tItem; $tDevDocsPath; $tDocPath)
C_OBJECT($oItem; $oFolders; $oThisFolder; $oFoldersJSON; $oFile)
C_COLLECTION($cMasterList)
ARRAY TEXT($atItems; 0)
ARRAY TEXT($atDocs; 0)


/* Calculate paths to where all the sources and the documentation will be. This code allows for a
DevDocs folder to be at the same level as the Documentation folder in case the developer has a series
of developer documentation as .md files that are organized a different way than direct association
with methods, forms, classes, etc.
*/
$tBasePath:=Get 4D folder(Database folder)
$tSourcesPath:=$tBasePath+"Project"+Folder separator+"Sources"+Folder separator
$tDocumentationPath:=$tBasePath+"Documentation"+Folder separator
$tDevDocsPath:=$tBasePath+"DevDocs"+Folder separator

/* We want to show what folder methods, classes, and forms are in. To do this we first parse the folders.json
file and sort of invert it into a new object so we can do very fast lookups later on to see what folder at
item is in. The resulting object looks like this:
- $oFolders
  - classes (an object which has a subobject for each class where the key is the class name and the value is
    the folder.
  - methods (same as classes, except for methods)
  - forms (same as classes, except for forms)

The folders.json file is organized as a large object with each folder as a top level object, the key name
the same as the folder name. Even if a folder is a sub-folder in the 4D Explorer, it will be in this file
at the top level. Within each folder object are potentially several objects. We care about the following,
each of which is a value collection of method/class/form names that belong to the folder:
  - classes
  - methods
  - forms
*/
$oFolders:=New object  //Prepare the object
$oFolders.classes:=New object
$oFolders.methods:=New object
$oFolders.forms:=New object

//Now we can load the folders.json file and loop through each folder, adding info to the inverted object
$tFoldersPath:=$tSourcesPath+"folders.json"
If (Test path name($tFoldersPath)=Is a document)
	$tJSONString:=Document to text($tFoldersPath)
	$oFoldersJSON:=JSON Parse($tJSONString)
	For each ($tFolderName; $oFoldersJSON)
		
		$oThisFolder:=$oFoldersJSON[$tFolderName]
		
		If ($oThisFolder.methods#Null)
			For each ($tName; $oThisFolder.methods)
				$oFolders.methods[$tName]:=$tFolderName
			End for each 
		End if 
		
		If ($oThisFolder.classes#Null)
			For each ($tName; $oThisFolder.classes)
				$oFolders.classes[$tName]:=$tFolderName
			End for each 
		End if 
		
		If ($oThisFolder.forms#Null)
			For each ($tName; $oThisFolder.forms)
				$oFolders.forms[$tName]:=$tFolderName
			End for each 
		End if 
		
	End for each 
End if 


/* Parse the classes and add them to the collection. File names are:
- className.4dm for the method
- className.md for the documentation
It could be interesting to parse out the function names in the future and add them to the search results...
*/
$tItemsPath:=$tSourcesPath+"Classes"+Folder separator
$tDocsPath:=$tDocumentationPath+"Classes"+Folder separator
If (Test path name($tItemsPath)=Is a folder)  //No point in parsing if no methods exist
	DOCUMENT LIST($tItemsPath; $atItems; Ignore invisible)
	If (Test path name($tDocsPath)=Is a folder)
		DOCUMENT LIST($tDocsPath; $atDocs; Ignore invisible)
	Else 
		DELETE FROM ARRAY($atDocs; 1; Size of array($atDocs))
	End if 
	For ($x; 1; Size of array($atItems))
		$oItem:=New object
		$oItem.type:="Class"
		$oItem.name:=Replace string($atItems{$x}; ".4dm"; "")  //Remove the .4dm file extension for the name
		$oItem.folder:=String($oFolders.classes[$oItem.name])
		$tDocName:=$oItem.name+".md"
		$lFind:=Find in array($atDocs; $tDocName)
		$oItem.hasDocs:=Choose($lFind=-1; False; True)
		$cMasterList.push($oItem)
	End for 
End if 


/* Parse the Database methods and add them to the collection. File names are:
- dbMethodName.4dm for the method
- dbMethodName.md for the documentation
*/
$tItemsPath:=$tSourcesPath+"DatabaseMethods"+Folder separator
$tDocsPath:=$tDocumentationPath+"DatabaseMethods"+Folder separator
If (Test path name($tItemsPath)=Is a folder)  //No point in parsing if no methods exist
	DOCUMENT LIST($tItemsPath; $atItems; Ignore invisible)
	If (Test path name($tDocsPath)=Is a folder)
		DOCUMENT LIST($tDocsPath; $atDocs; Ignore invisible)
	Else 
		DELETE FROM ARRAY($atDocs; 1; Size of array($atDocs))
	End if 
	For ($x; 1; Size of array($atItems))
		$oItem:=New object
		$oItem.type:="DB Method"
		$oItem.name:=Replace string($atItems{$x}; ".4dm"; "")  //Remove the .4dm file extension for the name
		$oItem.folder:=""  //Aren't put in folders
		$tDocName:=$oItem.name+".md"
		$lFind:=Find in array($atDocs; $tDocName)
		$oItem.hasDocs:=Choose($lFind=-1; False; True)
		$cMasterList.push($oItem)
	End for 
End if 



/* Parse the methods and add them to the collection. File names are:
- methodName.4dm for the method
- methodName.md for the documentation
*/
$tItemsPath:=$tSourcesPath+"Methods"+Folder separator
$tDocsPath:=$tDocumentationPath+"Methods"+Folder separator
If (Test path name($tItemsPath)=Is a folder)  //No point in parsing if no methods exist
	DOCUMENT LIST($tItemsPath; $atItems; Ignore invisible)
	If (Test path name($tDocsPath)=Is a folder)
		DOCUMENT LIST($tDocsPath; $atDocs; Ignore invisible)
	Else 
		DELETE FROM ARRAY($atDocs; 1; Size of array($atDocs))
	End if 
	For ($x; 1; Size of array($atItems))
		$oItem:=New object
		$oItem.type:="Method"
		$oItem.name:=Replace string($atItems{$x}; ".4dm"; "")  //Remove the .4dm file extension for the name
		$oItem.folder:=String($oFolders.methods[$oItem.name])
		$tDocName:=$oItem.name+".md"
		$lFind:=Find in array($atDocs; $tDocName)
		$oItem.hasDocs:=Choose($lFind=-1; False; True)
		$cMasterList.push($oItem)
	End for 
End if 


/* Parse the forms and add them to the collection. Forms are actually folders:
- formName is the folder name
- formName.md for the documentation (still a file)
*/
$tItemsPath:=$tSourcesPath+"Forms"+Folder separator
$tDocsPath:=$tDocumentationPath+"Forms"+Folder separator
If (Test path name($tItemsPath)=Is a folder)  //No point in parsing if no methods exist
	FOLDER LIST($tItemsPath; $atItems)  //Note we are getting a list of folders, not files here!
	If (Test path name($tDocsPath)=Is a folder)
		DOCUMENT LIST($tDocsPath; $atDocs; Ignore invisible)
	Else 
		DELETE FROM ARRAY($atDocs; 1; Size of array($atDocs))
	End if 
	For ($x; 1; Size of array($atItems))
		$oItem:=New object
		$oItem.type:="Form"
		$oItem.name:=$atItems{$x}
		$oItem.folder:=String($oFolders.forms[$oItem.name])
		$tDocName:=$oItem.name+".md"
		$lFind:=Find in array($atDocs; $tDocName)
		$oItem.hasDocs:=Choose($lFind=-1; False; True)
		$cMasterList.push($oItem)
	End for 
End if 


/* Parse the triggers and add them to the collection. File names are based on table number:
- table_1.4dm for the trigger
- table1.md for the documentation
*/
$tItemsPath:=$tSourcesPath+"Triggers"+Folder separator
$tDocsPath:=$tDocumentationPath+"Triggers"+Folder separator
If (Test path name($tItemsPath)=Is a folder)  //No point in parsing if no methods exist
	DOCUMENT LIST($tItemsPath; $atItems; Ignore invisible)
	If (Test path name($tDocsPath)=Is a folder)
		DOCUMENT LIST($tDocsPath; $atDocs; Ignore invisible)
	Else 
		DELETE FROM ARRAY($atDocs; 1; Size of array($atDocs))
	End if 
	For ($x; 1; Size of array($atItems))
		$tItem:=Replace string($atItems{$x}; ".4dm"; "")  //Remove the .4dm file extension for the name
		$lTableNumber:=Num(Replace string($tItem; "table_"; ""))
		If ($lTableNumber>0)
			$oItem:=New object
			$oItem.type:="Trigger"
			$oItem.name:=Table name($lTableNumber)
			$oItem.folder:=""  //Not put in folders
			$tDocName:="table"+String($lTableNumber)+".md"
			$lFind:=Find in array($atDocs; $tDocName)
			$oItem.hasDocs:=Choose($lFind=-1; False; True)
			$cMasterList.push($oItem)
		End if 
	End for 
End if 


/* Parse the DevDocs and add them to the collection. This can be a hierarchal set of .md files (and other
file types, but they will be ignored). All files will still be presented in a flat list, but the folder
will contain the relative path. We look only for files with a .md extension.
- filename.md
*/
If (Test path name($tDevDocsPath)=Is a folder)
	DOCUMENT LIST($tDevDocsPath; $atDocs; Ignore invisible+Absolute path+Recursive parsing)
	$lBasePathLength:=Length($tDevDocsPath)
	For ($x; 1; Size of array($atDocs))
		
		$oFile:=File($atDocs{$x}; fk platform path)
		
		//Remove the base path and the file name and convert to standard path, including a "/" at the beginning
		$tDocPath:=Substring($atDocs{$x}; $lBasePathLength+1)
		$tDocPath:=Replace string($tDocPath; $oFile.fullName; "")
		$tDocPath:="/"+Replace string($tDocPath; Folder separator; "/")
		
		$oItem:=New object
		$oItem.type:="DevDoc"
		$oItem.name:=$oFile.fullName
		$oItem.folder:=$tDocPath
		$oItem.hasDocs:=True  //Always true
		$cMasterList.push($oItem)
	End for 
	
End if 


/* Now that the list is built, let's sort it so it only has to be done once
*/
$cMasterList:=$cMasterList.orderBy("folder asc, name asc, type asc")


$0:=$cMasterList
