//%attributes = {}
/* Additional functionality can be found by right-clicking an item in the list. This method shows
the pop up menu and handles the chosen menu item.
*/

C_LONGINT:C283($x;$lTableNumber)
C_TEXT:C284($tMenuRef;$tChoice;$tBasePath;$tDevDocsPath;$tFileName;$tFilePath;$tMDPath;$tEmptyDoc)
C_TEXT:C284($tSourcesPath;$tItemsPath;$tFolderPath;$tDocumentationPath)
C_OBJECT:C1216($oSelectedItem)

$oSelectedItem:=Form:C1466.lbResults.currentItem

$tMenuRef:=Create menu:C408

APPEND MENU ITEM:C411($tMenuRef;"Open "+$oSelectedItem.name;"";Current process:C322;*)
SET MENU ITEM PARAMETER:C1004($tMenuRef;-1;"OpenItem")

If ($oSelectedItem.hasDocs=True:C214)
	APPEND MENU ITEM:C411($tMenuRef;"Open documentation for "+$oSelectedItem.name;"";Current process:C322;*)
Else 
	APPEND MENU ITEM:C411($tMenuRef;"Create documentation for "+$oSelectedItem.name;"";Current process:C322;*)
End if 
SET MENU ITEM PARAMETER:C1004($tMenuRef;-1;"OpenDocs")

APPEND MENU ITEM:C411($tMenuRef;"Show "+$oSelectedItem.name+" on disk";"";Current process:C322;*)
SET MENU ITEM PARAMETER:C1004($tMenuRef;-1;"ShowSelectedOnDisk")

APPEND MENU ITEM:C411($tMenuRef;"Show "+$oSelectedItem.name+"'s documentation on disk";"";Current process:C322;*)
SET MENU ITEM PARAMETER:C1004($tMenuRef;-1;"ShowSelectedDocumentationOnDisk")
If ($oSelectedItem.hasDocs=False:C215)
	DISABLE MENU ITEM:C150($tMenuRef;-1)
End if 

APPEND MENU ITEM:C411($tMenuRef;"-")

APPEND MENU ITEM:C411($tMenuRef;"New DevDoc at the top level...";"";Current process:C322;*)
SET MENU ITEM PARAMETER:C1004($tMenuRef;-1;"CreateTopLevelDevDoc")

If ($oSelectedItem.type="DevDoc")
	APPEND MENU ITEM:C411($tMenuRef;"New DevDoc beside "+$oSelectedItem.name+"...";"";Current process:C322;*)
Else 
	APPEND MENU ITEM:C411($tMenuRef;"New DevDoc beside...";"";Current process:C322;*)
	DISABLE MENU ITEM:C150($tMenuRef;-1)
End if 
SET MENU ITEM PARAMETER:C1004($tMenuRef;-1;"CreateDevDocBesideSelected")

APPEND MENU ITEM:C411($tMenuRef;"Show DevDocs folder on disk";"";Current process:C322;*)
SET MENU ITEM PARAMETER:C1004($tMenuRef;-1;"ShowDevDocsOnDisk")

APPEND MENU ITEM:C411($tMenuRef;"-")

APPEND MENU ITEM:C411($tMenuRef;"Copy item name";"";Current process:C322;*)
SET MENU ITEM PARAMETER:C1004($tMenuRef;-1;"CopyItemName")

$tChoice:=Dynamic pop up menu:C1006($tMenuRef;"")
RELEASE MENU:C978($tMenuRef)

Case of 
	: ($tChoice="OpenItem")  //Simply opens the selected item. Same as hitting enter when it is selected.
		DevQuickOpen_HandleSelected (False:C215)
		
	: ($tChoice="OpenDocs")  //Opens (creating if necessary) the selected item. Same as hitting option-enter.
		DevQuickOpen_HandleSelected (True:C214)
		
	: ($tChoice="ShowSelectedOnDisk")  //Shows the underlying file on disk
		$tBasePath:=Get 4D folder:C485(Database folder:K5:14)
		$tSourcesPath:=$tBasePath+"Project"+Folder separator:K24:12+"Sources"+Folder separator:K24:12
		Case of 
			: ($oSelectedItem.type="Class")
				$tItemsPath:=$tSourcesPath+"Classes"+Folder separator:K24:12
				$tFilePath:=$tItemsPath+$oSelectedItem.name+".4dm"
				SHOW ON DISK:C922($tFilePath)
				
			: ($oSelectedItem.type="Method")
				$tItemsPath:=$tSourcesPath+"Methods"+Folder separator:K24:12
				$tFilePath:=$tItemsPath+$oSelectedItem.name+".4dm"
				SHOW ON DISK:C922($tFilePath)
				
			: ($oSelectedItem.type="Form")
				$tItemsPath:=$tSourcesPath+"Forms"+Folder separator:K24:12
				$tFolderPath:=$tItemsPath+$oSelectedItem.name+Folder separator:K24:12
				SHOW ON DISK:C922($tFolderPath;*)
				
			: ($oSelectedItem.type="DB Method")
				$tItemsPath:=$tSourcesPath+"DatabaseMethods"+Folder separator:K24:12
				$tFilePath:=$tItemsPath+$oSelectedItem.name+".4dm"
				SHOW ON DISK:C922($tFilePath)
				
			: ($oSelectedItem.type="Trigger")
				For ($x;1;Get last table number:C254)
					If (Is table number valid:C999($x)=True:C214)
						If (Table name:C256($x)=$oSelectedItem.name)
							$lTableNumber:=$x
							$x:=Get last table number:C254+1  //Abort loop
						End if 
					End if 
				End for 
				$tItemsPath:=$tSourcesPath+"DatabaseMethods"+Folder separator:K24:12
				$tFilePath:=$tItemsPath+"table_"+String:C10($lTableNumber)+".4dm"
				SHOW ON DISK:C922($tFilePath)
				
			: ($oSelectedItem.type="DevDoc")
				$tDevDocsPath:=$tBasePath+"DevDocs"+Folder separator:K24:12
				$tMDPath:=Substring:C12($oSelectedItem.folder;2)  //Remove the first "/"
				$tMDPath:=Replace string:C233($tMDPath;"/";Folder separator:K24:12)
				$tMDPath:=$tDevDocsPath+$tMDPath+$oSelectedItem.name
				SHOW ON DISK:C922($tMDPath)
				
		End case 
		CANCEL:C270
		
		
	: ($tChoice="ShowSelectedDocumentationOnDisk")  //Shows the underlying documentation file on disk
		$tBasePath:=Get 4D folder:C485(Database folder:K5:14)
		$tDocumentationPath:=$tBasePath+"Documentation"+Folder separator:K24:12
		Case of 
			: ($oSelectedItem.type="Class")
				$tItemsPath:=$tDocumentationPath+"Classes"+Folder separator:K24:12
				$tFilePath:=$tItemsPath+$oSelectedItem.name+".md"
				SHOW ON DISK:C922($tFilePath)
				
			: ($oSelectedItem.type="Method")
				$tItemsPath:=$tDocumentationPath+"Methods"+Folder separator:K24:12
				$tFilePath:=$tItemsPath+$oSelectedItem.name+".md"
				SHOW ON DISK:C922($tFilePath)
				
			: ($oSelectedItem.type="Form")
				$tItemsPath:=$tDocumentationPath+"Forms"+Folder separator:K24:12
				$tFilePath:=$tItemsPath+$oSelectedItem.name+".md"
				SHOW ON DISK:C922($tFilePath)
				
			: ($oSelectedItem.type="DB Method")
				$tItemsPath:=$tDocumentationPath+"DatabaseMethods"+Folder separator:K24:12
				$tFilePath:=$tItemsPath+$oSelectedItem.name+".md"
				SHOW ON DISK:C922($tFilePath)
				
			: ($oSelectedItem.type="Trigger")
				For ($x;1;Get last table number:C254)
					If (Is table number valid:C999($x)=True:C214)
						If (Table name:C256($x)=$oSelectedItem.name)
							$lTableNumber:=$x
							$x:=Get last table number:C254+1  //Abort loop
						End if 
					End if 
				End for 
				$tItemsPath:=$tDocumentationPath+"DatabaseMethods"+Folder separator:K24:12
				$tFilePath:=$tItemsPath+"table"+String:C10($lTableNumber)+".md"
				SHOW ON DISK:C922($tFilePath)
				
			: ($oSelectedItem.type="DevDoc")
				$tDevDocsPath:=$tBasePath+"DevDocs"+Folder separator:K24:12
				$tMDPath:=Substring:C12($oSelectedItem.folder;2)  //Remove the first "/"
				$tMDPath:=Replace string:C233($tMDPath;"/";Folder separator:K24:12)
				$tMDPath:=$tDevDocsPath+$tMDPath+$oSelectedItem.name
				SHOW ON DISK:C922($tMDPath)
				
		End case 
		CANCEL:C270
		
		
		
	: ($tChoice="CreateTopLevelDevDoc")  //Creates a markdown file with a given name in DevDocs. Then opens it for editing.
		HIDE WINDOW:C436
		$tFileName:=Request:C163("Enter the name of the markdown file you would like to create.";"index.md";"Create";"Cancel")
		SHOW WINDOW:C435
		If ((OK=1) & ($tFileName#""))
			  //Make sure it has an extension
			If (Position:C15(".md";$tFileName)#(Length:C16($tFileName)-2))
				$tFileName:=$tFileName+".md"
			End if 
			$tBasePath:=Get 4D folder:C485(Database folder:K5:14)
			$tDevDocsPath:=$tBasePath+"DevDocs"+Folder separator:K24:12
			CREATE FOLDER:C475($tDevDocsPath;*)  //Make sure it exists
			$tMDPath:=$tDevDocsPath+$tFileName
			If (Test path name:C476($tFilePath)#Is a document:K24:1)
				$tEmptyDoc:="# New DevDoc\r"
				TEXT TO DOCUMENT:C1237($tMDPath;$tEmptyDoc)
			End if 
			OPEN URL:C673($tMDPath)
		End if 
		CANCEL:C270
		
		
	: ($tChoice="CreateDevDocBesideSelected")  //Creates a markdown file with a given name beside the currently selected DevDoc item. Then opens it for editing.
		$tFileName:=Request:C163("Enter the name of the markdown file you would like to create.";"name.md";"Create";"Cancel")
		If ((OK=1) & ($tFileName#""))
			  //Make sure it has an extension
			If (Position:C15(".md";$tFileName)#(Length:C16($tFileName)-2))
				$tFileName:=$tFileName+".md"
			End if 
			$tBasePath:=Get 4D folder:C485(Database folder:K5:14)
			$tDevDocsPath:=$tBasePath+"DevDocs"+Folder separator:K24:12
			$tMDPath:=Substring:C12($oSelectedItem.folder;2)  //Remove the first "/"
			$tMDPath:=Replace string:C233($tMDPath;"/";Folder separator:K24:12)
			$tMDPath:=$tDevDocsPath+$tMDPath+$tFileName
			If (Test path name:C476($tFilePath)#Is a document:K24:1)
				$tEmptyDoc:="# New DevDoc\r"
				TEXT TO DOCUMENT:C1237($tMDPath;$tEmptyDoc)
			End if 
			OPEN URL:C673($tMDPath)
		End if 
		CANCEL:C270
		
		
	: ($tChoice="ShowDevDocsOnDisk")  //Shows the DevDocs folder on disk. Creates it first if necessary.
		$tBasePath:=Get 4D folder:C485(Database folder:K5:14)
		$tDevDocsPath:=$tBasePath+"DevDocs"+Folder separator:K24:12
		CREATE FOLDER:C475($tDevDocsPath;*)  //Make sure it exists
		SHOW ON DISK:C922($tDevDocsPath;*)
		CANCEL:C270
		
		
	: ($tChoice="CopyItemName")  //Copies the name of the selected item to the clipboard.
		SET TEXT TO PASTEBOARD:C523($oSelectedItem.name)
		CANCEL:C270
		
		
End case 
