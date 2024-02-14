Case of 
	: (Form event code=On Double Clicked)
		If ((Macintosh option down=True) | (Windows Alt down=True))
			DevQuickOpen_HandleSelected(True)
		Else 
			DevQuickOpen_HandleSelected(False)
		End if 
		
	: (Form event code=On Clicked)
		If ((Right click=True) | (Contextual click=True) | (Macintosh option down=True))
			If (Form.lbResults.currentItem#Null)
				DevQuickOpen_HandleRightClick
			End if 
		End if 
		
		
End case 
