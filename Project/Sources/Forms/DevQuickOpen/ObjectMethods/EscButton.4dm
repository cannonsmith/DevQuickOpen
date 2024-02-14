/* Hitting esc once clears the search field.
Hitting it again closes the window.
*/

If (Form.search="")
	
	CANCEL
	
Else 
	
	Form.search:=""
	DevQuickOpen_OnSearch
	
End if 
