//%attributes = {}
/* When they want to open an item (from hitting enter, option-enter, double-clicking, or right-clicking
and choosing open) this method will run to handle opening the item.

If Option was held down at the same time, we assume they want to open (creating if necessary) the 
markdown documentation for the item.
*/

C_BOOLEAN:C305($1;$fOptionDown)  //If true, they want the documentation

$fOptionDown:=$1

C_LONGINT:C283($x;$lTableNumber)
C_OBJECT:C1216($oItem)
C_TEXT:C284($tBasePath;$tDocumentationPath;$tDevDocsPath;$tMDPath;$tEmptyDoc;$tParentFolder)

If (Form:C1466.lbResults.currentItem#Null:C1517)  //Make sure an item is selected
	
	$oItem:=Form:C1466.lbResults.currentItem
	
	$tBasePath:=Get 4D folder:C485(Database folder:K5:14)
	$tDocumentationPath:=$tBasePath+"Documentation"+Folder separator:K24:12
	$tDevDocsPath:=$tBasePath+"DevDocs"+Folder separator:K24:12
	
	Case of 
		: ($oItem.type="Class")
			If ($fOptionDown=False:C215)
				METHOD OPEN PATH:C1213("[class]/"+$oItem.name)
				CANCEL:C270
			Else 
				$tMDPath:=$tDocumentationPath+"Classes"+Folder separator:K24:12+$oItem.name+".md"
				If (Test path name:C476($tMDPath)=Is a document:K24:1)
					OPEN URL:C673($tMDPath)
				Else 
					$tMDPath:=$tDocumentationPath+"Classes"+Folder separator:K24:12+$oItem.name+".md"
					If (Test path name:C476($tMDPath)=Is a document:K24:1)
						OPEN URL:C673($tMDPath)
					Else 
						  //Make sure folder exists
						$tParentFolder:=$tDocumentationPath+"Classes"+Folder separator:K24:12
						CREATE FOLDER:C475($tParentFolder;*)
						$tEmptyDoc:="# "+$oItem.name+" Class Documentation\r"
						TEXT TO DOCUMENT:C1237($tMDPath;$tEmptyDoc)
						OPEN URL:C673($tMDPath)
					End if 
				End if 
			End if 
			
			
		: ($oItem.type="Method")
			If ($fOptionDown=False:C215)
				METHOD OPEN PATH:C1213($oItem.name)
				CANCEL:C270
			Else 
				$tMDPath:=$tDocumentationPath+"Methods"+Folder separator:K24:12+$oItem.name+".md"
				If (Test path name:C476($tMDPath)=Is a document:K24:1)
					OPEN URL:C673($tMDPath)
				Else 
					  //Make sure folder exists
					$tParentFolder:=$tDocumentationPath+"Methods"+Folder separator:K24:12
					CREATE FOLDER:C475($tParentFolder;*)
					$tEmptyDoc:="# "+$oItem.name+" Method Documentation\r"
					TEXT TO DOCUMENT:C1237($tMDPath;$tEmptyDoc)
					OPEN URL:C673($tMDPath)
				End if 
			End if 
			
			
		: ($oItem.type="Form")
			If ($fOptionDown=False:C215)
				  //FORM EDIT($oItem.name)  //Available in v18 R5
				ALERT:C41("Forms can't be opened until v18 R5. Change code in DevQuickOpen_HandleSelected for this.")
			Else 
				$tMDPath:=$tDocumentationPath+"Forms"+Folder separator:K24:12+$oItem.name+".md"
				If (Test path name:C476($tMDPath)=Is a document:K24:1)
					OPEN URL:C673($tMDPath)
				Else 
					  //Make sure folder exists
					$tParentFolder:=$tDocumentationPath+"Forms"+Folder separator:K24:12
					CREATE FOLDER:C475($tParentFolder;*)
					$tEmptyDoc:="# "+$oItem.name+" Form Documentation\r"
					TEXT TO DOCUMENT:C1237($tMDPath;$tEmptyDoc)
					OPEN URL:C673($tMDPath)
				End if 
			End if 
			
			
		: ($oItem.type="DB Method")
			If ($fOptionDown=False:C215)
				METHOD OPEN PATH:C1213("[databaseMethod]/"+$oItem.name)
				CANCEL:C270
			Else 
				$tMDPath:=$tDocumentationPath+"DatabaseMethods"+Folder separator:K24:12+$oItem.name+".md"
				If (Test path name:C476($tMDPath)=Is a document:K24:1)
					OPEN URL:C673($tMDPath)
				Else 
					  //Make sure folder exists
					$tParentFolder:=$tDocumentationPath+"DatabaseMethods"+Folder separator:K24:12
					CREATE FOLDER:C475($tParentFolder;*)
					$tEmptyDoc:="# "+$oItem.name+" Database Method Documentation\r"
					TEXT TO DOCUMENT:C1237($tMDPath;$tEmptyDoc)
					OPEN URL:C673($tMDPath)
				End if 
			End if 
			
			
		: ($oItem.type="Trigger")
			For ($x;1;Get last table number:C254)
				If (Is table number valid:C999($x)=True:C214)
					If (Table name:C256($x)=$oItem.name)
						$lTableNumber:=$x
						$x:=Get last table number:C254+1  //Abort loop
					End if 
				End if 
			End for 
			
			If ($fOptionDown=False:C215)
				METHOD OPEN PATH:C1213("[trigger]/table_"+String:C10($lTableNumber))
				CANCEL:C270
			Else 
				
				$tMDPath:=$tDocumentationPath+"Triggers"+Folder separator:K24:12+"table"+String:C10($lTableNumber)+".md"
				If (Test path name:C476($tMDPath)=Is a document:K24:1)
					OPEN URL:C673($tMDPath)
				Else 
					  //Make sure folder exists
					$tParentFolder:=$tDocumentationPath+"Triggers"+Folder separator:K24:12
					CREATE FOLDER:C475($tParentFolder;*)
					$tEmptyDoc:="# "+$oItem.name+" Trigger Documentation\r"
					TEXT TO DOCUMENT:C1237($tMDPath;$tEmptyDoc)
					OPEN URL:C673($tMDPath)
				End if 
			End if 
			
			
		: ($oItem.type="DevDoc")  //It doesn't matter if Option/Alt is held down for this.
			$tMDPath:=Substring:C12($oItem.folder;2)  //Remove the first "/"
			$tMDPath:=Replace string:C233($tMDPath;"/";Folder separator:K24:12)
			$tMDPath:=$tDevDocsPath+$tMDPath+$oItem.name
			If (Test path name:C476($tMDPath)=Is a document:K24:1)
				OPEN URL:C673($tMDPath)
			End if 
			
	End case 
	
	
End if 
