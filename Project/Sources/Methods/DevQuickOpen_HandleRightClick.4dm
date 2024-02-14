//%attributes = {"folder":"Developer Quick Open","lang":"en"}
/* Additional functionality can be found by right-clicking an item in the list. This method shows
the pop up menu and handles the chosen menu item.
*/

C_LONGINT($x; $lTableNumber)
C_TEXT($tMenuRef; $tChoice; $tBasePath; $tDevDocsPath; $tFileName; $tFilePath; $tMDPath; $tEmptyDoc)
C_TEXT($tSourcesPath; $tItemsPath; $tFolderPath; $tDocumentationPath)
C_OBJECT($oSelectedItem)

$oSelectedItem:=Form.lbResults.currentItem

$tMenuRef:=Create menu

APPEND MENU ITEM($tMenuRef; "Open "+$oSelectedItem.name; ""; Current process; *)
SET MENU ITEM PARAMETER($tMenuRef; -1; "OpenItem")

If ($oSelectedItem.hasDocs=True)
	APPEND MENU ITEM($tMenuRef; "Open documentation for "+$oSelectedItem.name; ""; Current process; *)
Else 
	APPEND MENU ITEM($tMenuRef; "Create documentation for "+$oSelectedItem.name; ""; Current process; *)
End if 
SET MENU ITEM PARAMETER($tMenuRef; -1; "OpenDocs")

APPEND MENU ITEM($tMenuRef; "Show "+$oSelectedItem.name+" on disk"; ""; Current process; *)
SET MENU ITEM PARAMETER($tMenuRef; -1; "ShowSelectedOnDisk")

APPEND MENU ITEM($tMenuRef; "Show "+$oSelectedItem.name+"'s documentation on disk"; ""; Current process; *)
SET MENU ITEM PARAMETER($tMenuRef; -1; "ShowSelectedDocumentationOnDisk")
If ($oSelectedItem.hasDocs=False)
	DISABLE MENU ITEM($tMenuRef; -1)
End if 

APPEND MENU ITEM($tMenuRef; "-")

APPEND MENU ITEM($tMenuRef; "New DevDoc at the top level..."; ""; Current process; *)
SET MENU ITEM PARAMETER($tMenuRef; -1; "CreateTopLevelDevDoc")

If ($oSelectedItem.type="DevDoc")
	APPEND MENU ITEM($tMenuRef; "New DevDoc beside "+$oSelectedItem.name+"..."; ""; Current process; *)
Else 
	APPEND MENU ITEM($tMenuRef; "New DevDoc beside..."; ""; Current process; *)
	DISABLE MENU ITEM($tMenuRef; -1)
End if 
SET MENU ITEM PARAMETER($tMenuRef; -1; "CreateDevDocBesideSelected")

APPEND MENU ITEM($tMenuRef; "Show DevDocs folder on disk"; ""; Current process; *)
SET MENU ITEM PARAMETER($tMenuRef; -1; "ShowDevDocsOnDisk")

APPEND MENU ITEM($tMenuRef; "-")

APPEND MENU ITEM($tMenuRef; "Copy item name"; ""; Current process; *)
SET MENU ITEM PARAMETER($tMenuRef; -1; "CopyItemName")

$tChoice:=Dynamic pop up menu($tMenuRef; "")
RELEASE MENU($tMenuRef)

Case of 
	: ($tChoice="OpenItem")  //Simply opens the selected item. Same as hitting enter when it is selected.
		DevQuickOpen_HandleSelected(False)
		
	: ($tChoice="OpenDocs")  //Opens (creating if necessary) the selected item. Same as hitting option-enter.
		DevQuickOpen_HandleSelected(True)
		
	: ($tChoice="ShowSelectedOnDisk")  //Shows the underlying file on disk
		$tBasePath:=Get 4D folder(Database folder)
		$tSourcesPath:=$tBasePath+"Project"+Folder separator+"Sources"+Folder separator
		Case of 
			: ($oSelectedItem.type="Class")
				$tItemsPath:=$tSourcesPath+"Classes"+Folder separator
				$tFilePath:=$tItemsPath+$oSelectedItem.name+".4dm"
				SHOW ON DISK($tFilePath)
				
			: ($oSelectedItem.type="Method")
				$tItemsPath:=$tSourcesPath+"Methods"+Folder separator
				$tFilePath:=$tItemsPath+$oSelectedItem.name+".4dm"
				SHOW ON DISK($tFilePath)
				
			: ($oSelectedItem.type="Form")
				$tItemsPath:=$tSourcesPath+"Forms"+Folder separator
				$tFolderPath:=$tItemsPath+$oSelectedItem.name+Folder separator
				SHOW ON DISK($tFolderPath; *)
				
			: ($oSelectedItem.type="DB Method")
				$tItemsPath:=$tSourcesPath+"DatabaseMethods"+Folder separator
				$tFilePath:=$tItemsPath+$oSelectedItem.name+".4dm"
				SHOW ON DISK($tFilePath)
				
			: ($oSelectedItem.type="Trigger")
				For ($x; 1; Get last table number)
					If (Is table number valid($x)=True)
						If (Table name($x)=$oSelectedItem.name)
							$lTableNumber:=$x
							$x:=Get last table number+1  //Abort loop
						End if 
					End if 
				End for 
				$tItemsPath:=$tSourcesPath+"Triggers"+Folder separator
				$tFilePath:=$tItemsPath+"table_"+String($lTableNumber)+".4dm"
				SHOW ON DISK($tFilePath)
				
			: ($oSelectedItem.type="DevDoc")
				$tDevDocsPath:=$tBasePath+"DevDocs"+Folder separator
				$tMDPath:=Substring($oSelectedItem.folder; 2)  //Remove the first "/"
				$tMDPath:=Replace string($tMDPath; "/"; Folder separator)
				$tMDPath:=$tDevDocsPath+$tMDPath+$oSelectedItem.name
				SHOW ON DISK($tMDPath)
				
		End case 
		CANCEL
		
		
	: ($tChoice="ShowSelectedDocumentationOnDisk")  //Shows the underlying documentation file on disk
		$tBasePath:=Get 4D folder(Database folder)
		$tDocumentationPath:=$tBasePath+"Documentation"+Folder separator
		Case of 
			: ($oSelectedItem.type="Class")
				$tItemsPath:=$tDocumentationPath+"Classes"+Folder separator
				$tFilePath:=$tItemsPath+$oSelectedItem.name+".md"
				SHOW ON DISK($tFilePath)
				
			: ($oSelectedItem.type="Method")
				$tItemsPath:=$tDocumentationPath+"Methods"+Folder separator
				$tFilePath:=$tItemsPath+$oSelectedItem.name+".md"
				SHOW ON DISK($tFilePath)
				
			: ($oSelectedItem.type="Form")
				$tItemsPath:=$tDocumentationPath+"Forms"+Folder separator
				$tFilePath:=$tItemsPath+$oSelectedItem.name+".md"
				SHOW ON DISK($tFilePath)
				
			: ($oSelectedItem.type="DB Method")
				$tItemsPath:=$tDocumentationPath+"DatabaseMethods"+Folder separator
				$tFilePath:=$tItemsPath+$oSelectedItem.name+".md"
				SHOW ON DISK($tFilePath)
				
			: ($oSelectedItem.type="Trigger")
				For ($x; 1; Get last table number)
					If (Is table number valid($x)=True)
						If (Table name($x)=$oSelectedItem.name)
							$lTableNumber:=$x
							$x:=Get last table number+1  //Abort loop
						End if 
					End if 
				End for 
				$tItemsPath:=$tDocumentationPath+"Triggers"+Folder separator
				$tFilePath:=$tItemsPath+"table"+String($lTableNumber)+".md"
				SHOW ON DISK($tFilePath)
				
			: ($oSelectedItem.type="DevDoc")
				$tDevDocsPath:=$tBasePath+"DevDocs"+Folder separator
				$tMDPath:=Substring($oSelectedItem.folder; 2)  //Remove the first "/"
				$tMDPath:=Replace string($tMDPath; "/"; Folder separator)
				$tMDPath:=$tDevDocsPath+$tMDPath+$oSelectedItem.name
				SHOW ON DISK($tMDPath)
				
		End case 
		CANCEL
		
		
		
	: ($tChoice="CreateTopLevelDevDoc")  //Creates a markdown file with a given name in DevDocs. Then opens it for editing.
		HIDE WINDOW
		$tFileName:=Request("Enter the name of the markdown file you would like to create."; "index.md"; "Create"; "Cancel")
		SHOW WINDOW
		If ((OK=1) & ($tFileName#""))
			//Make sure it has an extension
			If (Position(".md"; $tFileName)#(Length($tFileName)-2))
				$tFileName:=$tFileName+".md"
			End if 
			$tBasePath:=Get 4D folder(Database folder)
			$tDevDocsPath:=$tBasePath+"DevDocs"+Folder separator
			CREATE FOLDER($tDevDocsPath; *)  //Make sure it exists
			$tMDPath:=$tDevDocsPath+$tFileName
			If (Test path name($tFilePath)#Is a document)
				$tEmptyDoc:="# New DevDoc\r"
				TEXT TO DOCUMENT($tMDPath; $tEmptyDoc)
			End if 
			OPEN URL($tMDPath)
		End if 
		CANCEL
		
		
	: ($tChoice="CreateDevDocBesideSelected")  //Creates a markdown file with a given name beside the currently selected DevDoc item. Then opens it for editing.
		HIDE WINDOW
		$tFileName:=Request("Enter the name of the markdown file you would like to create."; "name.md"; "Create"; "Cancel")
		SHOW WINDOW
		If ((OK=1) & ($tFileName#""))
			//Make sure it has an extension
			If (Position(".md"; $tFileName)#(Length($tFileName)-2))
				$tFileName:=$tFileName+".md"
			End if 
			$tBasePath:=Get 4D folder(Database folder)
			$tDevDocsPath:=$tBasePath+"DevDocs"+Folder separator
			$tMDPath:=Substring($oSelectedItem.folder; 2)  //Remove the first "/"
			$tMDPath:=Replace string($tMDPath; "/"; Folder separator)
			$tMDPath:=$tDevDocsPath+$tMDPath+$tFileName
			If (Test path name($tFilePath)#Is a document)
				$tEmptyDoc:="# New DevDoc\r"
				TEXT TO DOCUMENT($tMDPath; $tEmptyDoc)
			End if 
			OPEN URL($tMDPath)
		End if 
		CANCEL
		
		
	: ($tChoice="ShowDevDocsOnDisk")  //Shows the DevDocs folder on disk. Creates it first if necessary.
		$tBasePath:=Get 4D folder(Database folder)
		$tDevDocsPath:=$tBasePath+"DevDocs"+Folder separator
		CREATE FOLDER($tDevDocsPath; *)  //Make sure it exists
		SHOW ON DISK($tDevDocsPath; *)
		CANCEL
		
		
	: ($tChoice="CopyItemName")  //Copies the name of the selected item to the clipboard.
		SET TEXT TO PASTEBOARD($oSelectedItem.name)
		CANCEL
		
		
End case 
