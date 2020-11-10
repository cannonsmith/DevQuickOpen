/* Hitting esc once clears the search field.
Hitting it again closes the window.
*/

If (Form:C1466.search="")
	
	CANCEL:C270
	
Else 
	
	Form:C1466.search:=""
	DevQuickOpen_OnSearch 
	
End if 
