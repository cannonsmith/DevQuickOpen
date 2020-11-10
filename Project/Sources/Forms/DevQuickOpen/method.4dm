Case of 
	: (Form event code:C388=On Load:K2:1)
		
		  //Set up the form variables
		Form:C1466.search:=""
		Form:C1466.lbResults:=New object:C1471
		Form:C1466.lbResults.display:=New collection:C1472
		Form:C1466.lbResults.currentItem:=Null:C1517
		Form:C1466.lbResults.itemPosition:=0
		
/* Get a local copy of the existing master list. This will be an old one (or an empty one if
it is the first run), but we start with it. A worker will notify us of a newer one when it
is ready and we'll update at that point.
*/
		Form:C1466.masterList:=Storage:C1525.devQuickOpen.masterList.copy()
		
		  //To manage window state
		Form:C1466.isExpanded:=False:C215
		
		  //Set up the UI
		OBJECT SET VISIBLE:C603(*;"YellowCircle";True:C214)  //Yellow until the master list has been updated
		
		  //Initiage the search
		DevQuickOpen_OnSearch 
		
		
End case 
