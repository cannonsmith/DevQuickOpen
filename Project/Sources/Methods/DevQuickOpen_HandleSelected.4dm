//%attributes = {"folder":"Developer Quick Open","lang":"en"}
/* When they want to open an item (from hitting enter, option-enter, double-clicking, or right-clicking
and choosing open) this method will run to handle opening the item.

If Option was held down at the same time, we assume they want to open (creating if necessary) the 
markdown documentation for the item.
*/

C_BOOLEAN($1; $fOptionDown)  //If true, they want the documentation

$fOptionDown:=$1

C_LONGINT($x; $lTableNumber)
C_OBJECT($oItem)
C_TEXT($tBasePath; $tDocumentationPath; $tDevDocsPath; $tMDPath; $tEmptyDoc; $tParentFolder)

If (Form.lbResults.currentItem#Null)  //Make sure an item is selected
	
	$oItem:=Form.lbResults.currentItem
	
	$tBasePath:=Get 4D folder(Database folder)
	$tDocumentationPath:=$tBasePath+"Documentation"+Folder separator
	$tDevDocsPath:=$tBasePath+"DevDocs"+Folder separator
	
	Case of 
		: ($oItem.type="Class")
			If ($fOptionDown=False)
				METHOD OPEN PATH("[class]/"+$oItem.name)
				CANCEL
			Else 
				$tMDPath:=$tDocumentationPath+"Classes"+Folder separator+$oItem.name+".md"
				If (Test path name($tMDPath)=Is a document)
					OPEN URL($tMDPath)
				Else 
					$tMDPath:=$tDocumentationPath+"Classes"+Folder separator+$oItem.name+".md"
					If (Test path name($tMDPath)=Is a document)
						OPEN URL($tMDPath)
					Else 
						//Make sure folder exists
						$tParentFolder:=$tDocumentationPath+"Classes"+Folder separator
						CREATE FOLDER($tParentFolder; *)
						$tEmptyDoc:="# "+$oItem.name+" Class Documentation\r"
						TEXT TO DOCUMENT($tMDPath; $tEmptyDoc)
						OPEN URL($tMDPath)
					End if 
				End if 
			End if 
			
			
		: ($oItem.type="Method")
			If ($fOptionDown=False)
				METHOD OPEN PATH($oItem.name)
				CANCEL
			Else 
				$tMDPath:=$tDocumentationPath+"Methods"+Folder separator+$oItem.name+".md"
				If (Test path name($tMDPath)=Is a document)
					OPEN URL($tMDPath)
				Else 
					//Make sure folder exists
					$tParentFolder:=$tDocumentationPath+"Methods"+Folder separator
					CREATE FOLDER($tParentFolder; *)
					$tEmptyDoc:="# "+$oItem.name+" Method Documentation\r"
					TEXT TO DOCUMENT($tMDPath; $tEmptyDoc)
					OPEN URL($tMDPath)
				End if 
			End if 
			
			
		: ($oItem.type="Form")
			If ($fOptionDown=False)
				FORM EDIT(String($oItem.name))
				CANCEL
			Else 
				$tMDPath:=$tDocumentationPath+"Forms"+Folder separator+$oItem.name+".md"
				If (Test path name($tMDPath)=Is a document)
					OPEN URL($tMDPath)
				Else 
					//Make sure folder exists
					$tParentFolder:=$tDocumentationPath+"Forms"+Folder separator
					CREATE FOLDER($tParentFolder; *)
					$tEmptyDoc:="# "+$oItem.name+" Form Documentation\r"
					TEXT TO DOCUMENT($tMDPath; $tEmptyDoc)
					OPEN URL($tMDPath)
				End if 
			End if 
			
			
		: ($oItem.type="DB Method")
			If ($fOptionDown=False)
				METHOD OPEN PATH("[databaseMethod]/"+$oItem.name)
				CANCEL
			Else 
				$tMDPath:=$tDocumentationPath+"DatabaseMethods"+Folder separator+$oItem.name+".md"
				If (Test path name($tMDPath)=Is a document)
					OPEN URL($tMDPath)
				Else 
					//Make sure folder exists
					$tParentFolder:=$tDocumentationPath+"DatabaseMethods"+Folder separator
					CREATE FOLDER($tParentFolder; *)
					$tEmptyDoc:="# "+$oItem.name+" Database Method Documentation\r"
					TEXT TO DOCUMENT($tMDPath; $tEmptyDoc)
					OPEN URL($tMDPath)
				End if 
			End if 
			
			
		: ($oItem.type="Trigger")
			For ($x; 1; Get last table number)
				If (Is table number valid($x)=True)
					If (Table name($x)=$oItem.name)
						$lTableNumber:=$x
						$x:=Get last table number+1  //Abort loop
					End if 
				End if 
			End for 
			
			If ($fOptionDown=False)
				METHOD OPEN PATH("[trigger]/"+$oItem.name)
				CANCEL
			Else 
				
				$tMDPath:=$tDocumentationPath+"Triggers"+Folder separator+"table"+String($lTableNumber)+".md"
				If (Test path name($tMDPath)=Is a document)
					OPEN URL($tMDPath)
				Else 
					//Make sure folder exists
					$tParentFolder:=$tDocumentationPath+"Triggers"+Folder separator
					CREATE FOLDER($tParentFolder; *)
					$tEmptyDoc:="# "+$oItem.name+" Trigger Documentation\r"
					TEXT TO DOCUMENT($tMDPath; $tEmptyDoc)
					OPEN URL($tMDPath)
				End if 
			End if 
			
			
		: ($oItem.type="DevDoc")  //It doesn't matter if Option/Alt is held down for this.
			$tMDPath:=Substring($oItem.folder; 2)  //Remove the first "/"
			$tMDPath:=Replace string($tMDPath; "/"; Folder separator)
			$tMDPath:=$tDevDocsPath+$tMDPath+$oItem.name
			If (Test path name($tMDPath)=Is a document)
				OPEN URL($tMDPath)
			End if 
			
	End case 
	
	
End if 
