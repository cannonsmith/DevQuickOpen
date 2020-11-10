Case of 
	: (Form event code:C388=On Double Clicked:K2:5)
		If ((Macintosh option down:C545=True:C214) | (Windows Alt down:C563=True:C214))
			DevQuickOpen_HandleSelected (True:C214)
		Else 
			DevQuickOpen_HandleSelected (False:C215)
		End if 
		
	: (Form event code:C388=On Clicked:K2:4)
		If ((Right click:C712=True:C214) | (Contextual click:C713=True:C214) | (Macintosh option down:C545=True:C214))
			If (Form:C1466.lbResults.currentItem#Null:C1517)
				DevQuickOpen_HandleRightClick 
			End if 
		End if 
		
		
End case 
