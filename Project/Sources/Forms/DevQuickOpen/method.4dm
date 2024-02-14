Case of 
	: (Form event code=On Load)
		
		//Set up the form variables
		Form.search:=""
		Form.lbResults:=New object
		Form.lbResults.display:=New collection
		Form.lbResults.currentItem:=Null
		Form.lbResults.itemPosition:=0
		
/* Get a local copy of the existing master list. This will be an old one (or an empty one if
it is the first run), but we start with it. A worker will notify us of a newer one when it
is ready and we'll update at that point.
*/
		Form.masterList:=Storage.devQuickOpen.masterList.copy()
		
		//To manage window state
		Form.isExpanded:=False
		
		//Set up the UI
		OBJECT SET VISIBLE(*; "YellowCircle"; True)  //Yellow until the master list has been updated
		
		//Initiage the search
		DevQuickOpen_OnSearch
		
		
End case 
