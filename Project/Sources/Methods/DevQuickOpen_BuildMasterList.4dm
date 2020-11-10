//%attributes = {}
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

C_COLLECTION:C1488($0;$cMasterList)

$cMasterList:=New collection:C1472

C_LONGINT:C283($x;$lFind;$lTableNumber;$lBasePathLength)
C_TEXT:C284($tBasePath;$tSourcesPath;$tDocumentationPath;$tItemsPath;$tDocsPath;$tFolderName;$tFoldersPath)
C_TEXT:C284($tJSONString;$tName;$tDocName;$tItem;$tDevDocsPath;$tDocPath)
C_OBJECT:C1216($oItem;$oFolders;$oThisFolder;$oFoldersJSON;$oFile)
C_COLLECTION:C1488($cMasterList)
ARRAY TEXT:C222($atItems;0)
ARRAY TEXT:C222($atDocs;0)


/* Calculate paths to where all the sources and the documentation will be. This code allows for a
DevDocs folder to be at the same level as the Documentation folder in case the developer has a series
of developer documentation as .md files that are organized a different way than direct association
with methods, forms, classes, etc.
*/
$tBasePath:=Get 4D folder:C485(Database folder:K5:14)
$tSourcesPath:=$tBasePath+"Project"+Folder separator:K24:12+"Sources"+Folder separator:K24:12
$tDocumentationPath:=$tBasePath+"Documentation"+Folder separator:K24:12
$tDevDocsPath:=$tBasePath+"DevDocs"+Folder separator:K24:12

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
$oFolders:=New object:C1471  //Prepare the object
$oFolders.classes:=New object:C1471
$oFolders.methods:=New object:C1471
$oFolders.forms:=New object:C1471

  //Now we can load the folders.json file and loop through each folder, adding info to the inverted object
$tFoldersPath:=$tSourcesPath+"folders.json"
If (Test path name:C476($tFoldersPath)=Is a document:K24:1)
	$tJSONString:=Document to text:C1236($tFoldersPath)
	$oFoldersJSON:=JSON Parse:C1218($tJSONString)
	For each ($tFolderName;$oFoldersJSON)
		
		$oThisFolder:=$oFoldersJSON[$tFolderName]
		
		If ($oThisFolder.methods#Null:C1517)
			For each ($tName;$oThisFolder.methods)
				$oFolders.methods[$tName]:=$tFolderName
			End for each 
		End if 
		
		If ($oThisFolder.classes#Null:C1517)
			For each ($tName;$oThisFolder.classes)
				$oFolders.classes[$tName]:=$tFolderName
			End for each 
		End if 
		
		If ($oThisFolder.forms#Null:C1517)
			For each ($tName;$oThisFolder.forms)
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
$tItemsPath:=$tSourcesPath+"Classes"+Folder separator:K24:12
$tDocsPath:=$tDocumentationPath+"Classes"+Folder separator:K24:12
If (Test path name:C476($tItemsPath)=Is a folder:K24:2)  //No point in parsing if no methods exist
	DOCUMENT LIST:C474($tItemsPath;$atItems;Ignore invisible:K24:16)
	If (Test path name:C476($tDocsPath)=Is a folder:K24:2)
		DOCUMENT LIST:C474($tDocsPath;$atDocs;Ignore invisible:K24:16)
	Else 
		DELETE FROM ARRAY:C228($atDocs;1;Size of array:C274($atDocs))
	End if 
	For ($x;1;Size of array:C274($atItems))
		$oItem:=New object:C1471
		$oItem.type:="Class"
		$oItem.name:=Replace string:C233($atItems{$x};".4dm";"")  //Remove the .4dm file extension for the name
		$oItem.folder:=String:C10($oFolders.classes[$oItem.name])
		$tDocName:=$oItem.name+".md"
		$lFind:=Find in array:C230($atDocs;$tDocName)
		$oItem.hasDocs:=Choose:C955($lFind=-1;False:C215;True:C214)
		$cMasterList.push($oItem)
	End for 
End if 


/* Parse the Database methods and add them to the collection. File names are:
- dbMethodName.4dm for the method
- dbMethodName.md for the documentation
*/
$tItemsPath:=$tSourcesPath+"DatabaseMethods"+Folder separator:K24:12
$tDocsPath:=$tDocumentationPath+"DatabaseMethods"+Folder separator:K24:12
If (Test path name:C476($tItemsPath)=Is a folder:K24:2)  //No point in parsing if no methods exist
	DOCUMENT LIST:C474($tItemsPath;$atItems;Ignore invisible:K24:16)
	If (Test path name:C476($tDocsPath)=Is a folder:K24:2)
		DOCUMENT LIST:C474($tDocsPath;$atDocs;Ignore invisible:K24:16)
	Else 
		DELETE FROM ARRAY:C228($atDocs;1;Size of array:C274($atDocs))
	End if 
	For ($x;1;Size of array:C274($atItems))
		$oItem:=New object:C1471
		$oItem.type:="DB Method"
		$oItem.name:=Replace string:C233($atItems{$x};".4dm";"")  //Remove the .4dm file extension for the name
		$oItem.folder:=""  //Aren't put in folders
		$tDocName:=$oItem.name+".md"
		$lFind:=Find in array:C230($atDocs;$tDocName)
		$oItem.hasDocs:=Choose:C955($lFind=-1;False:C215;True:C214)
		$cMasterList.push($oItem)
	End for 
End if 



/* Parse the methods and add them to the collection. File names are:
- methodName.4dm for the method
- methodName.md for the documentation
*/
$tItemsPath:=$tSourcesPath+"Methods"+Folder separator:K24:12
$tDocsPath:=$tDocumentationPath+"Methods"+Folder separator:K24:12
If (Test path name:C476($tItemsPath)=Is a folder:K24:2)  //No point in parsing if no methods exist
	DOCUMENT LIST:C474($tItemsPath;$atItems;Ignore invisible:K24:16)
	If (Test path name:C476($tDocsPath)=Is a folder:K24:2)
		DOCUMENT LIST:C474($tDocsPath;$atDocs;Ignore invisible:K24:16)
	Else 
		DELETE FROM ARRAY:C228($atDocs;1;Size of array:C274($atDocs))
	End if 
	For ($x;1;Size of array:C274($atItems))
		$oItem:=New object:C1471
		$oItem.type:="Method"
		$oItem.name:=Replace string:C233($atItems{$x};".4dm";"")  //Remove the .4dm file extension for the name
		$oItem.folder:=String:C10($oFolders.methods[$oItem.name])
		$tDocName:=$oItem.name+".md"
		$lFind:=Find in array:C230($atDocs;$tDocName)
		$oItem.hasDocs:=Choose:C955($lFind=-1;False:C215;True:C214)
		$cMasterList.push($oItem)
	End for 
End if 


/* Parse the forms and add them to the collection. Forms are actually folders:
- formName is the folder name
- formName.md for the documentation (still a file)
*/
$tItemsPath:=$tSourcesPath+"Forms"+Folder separator:K24:12
$tDocsPath:=$tDocumentationPath+"Forms"+Folder separator:K24:12
If (Test path name:C476($tItemsPath)=Is a folder:K24:2)  //No point in parsing if no methods exist
	FOLDER LIST:C473($tItemsPath;$atItems)  //Note we are getting a list of folders, not files here!
	If (Test path name:C476($tDocsPath)=Is a folder:K24:2)
		DOCUMENT LIST:C474($tDocsPath;$atDocs;Ignore invisible:K24:16)
	Else 
		DELETE FROM ARRAY:C228($atDocs;1;Size of array:C274($atDocs))
	End if 
	For ($x;1;Size of array:C274($atItems))
		$oItem:=New object:C1471
		$oItem.type:="Form"
		$oItem.name:=$atItems{$x}
		$oItem.folder:=String:C10($oFolders.forms[$oItem.name])
		$tDocName:=$oItem.name+".md"
		$lFind:=Find in array:C230($atDocs;$tDocName)
		$oItem.hasDocs:=Choose:C955($lFind=-1;False:C215;True:C214)
		$cMasterList.push($oItem)
	End for 
End if 


/* Parse the triggers and add them to the collection. File names are based on table number:
- table_1.4dm for the trigger
- table1.md for the documentation
*/
$tItemsPath:=$tSourcesPath+"Triggers"+Folder separator:K24:12
$tDocsPath:=$tDocumentationPath+"Triggers"+Folder separator:K24:12
If (Test path name:C476($tItemsPath)=Is a folder:K24:2)  //No point in parsing if no methods exist
	DOCUMENT LIST:C474($tItemsPath;$atItems;Ignore invisible:K24:16)
	If (Test path name:C476($tDocsPath)=Is a folder:K24:2)
		DOCUMENT LIST:C474($tDocsPath;$atDocs;Ignore invisible:K24:16)
	Else 
		DELETE FROM ARRAY:C228($atDocs;1;Size of array:C274($atDocs))
	End if 
	For ($x;1;Size of array:C274($atItems))
		$tItem:=Replace string:C233($atItems{$x};".4dm";"")  //Remove the .4dm file extension for the name
		$lTableNumber:=Num:C11(Replace string:C233($tItem;"table_";""))
		If ($lTableNumber>0)
			$oItem:=New object:C1471
			$oItem.type:="Trigger"
			$oItem.name:=Table name:C256($lTableNumber)
			$oItem.folder:=""  //Not put in folders
			$tDocName:="table"+String:C10($lTableNumber)+".md"
			$lFind:=Find in array:C230($atDocs;$tDocName)
			$oItem.hasDocs:=Choose:C955($lFind=-1;False:C215;True:C214)
			$cMasterList.push($oItem)
		End if 
	End for 
End if 


/* Parse the DevDocs and add them to the collection. This can be a hierarchal set of .md files (and other
file types, but they will be ignored). All files will still be presented in a flat list, but the folder
will contain the relative path. We look only for files with a .md extension.
- filename.md
*/
If (Test path name:C476($tDevDocsPath)=Is a folder:K24:2)
	DOCUMENT LIST:C474($tDevDocsPath;$atDocs;Ignore invisible:K24:16+Absolute path:K24:14+Recursive parsing:K24:13)
	$lBasePathLength:=Length:C16($tDevDocsPath)
	For ($x;1;Size of array:C274($atDocs))
		
		$oFile:=File:C1566($atDocs{$x};fk platform path:K87:2)
		
		  //Remove the base path and the file name and convert to standard path, including a "/" at the beginning
		$tDocPath:=Substring:C12($atDocs{$x};$lBasePathLength+1)
		$tDocPath:=Replace string:C233($tDocPath;$oFile.fullName;"")
		$tDocPath:="/"+Replace string:C233($tDocPath;Folder separator:K24:12;"/")
		
		$oItem:=New object:C1471
		$oItem.type:="DevDoc"
		$oItem.name:=$oFile.fullName
		$oItem.folder:=$tDocPath
		$oItem.hasDocs:=True:C214  //Always true
		$cMasterList.push($oItem)
	End for 
	
End if 


/* Now that the list is built, let's sort it so it only has to be done once
*/
$cMasterList:=$cMasterList.orderBy("folder asc, name asc, type asc")


$0:=$cMasterList
