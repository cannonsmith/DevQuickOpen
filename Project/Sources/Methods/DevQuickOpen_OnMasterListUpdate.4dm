//%attributes = {}
/* This method is run when the master list worker has finished refreshing the
master list and runs in the context of the window.
*/

  //Update the signal in the window that the refresh is finished
OBJECT SET VISIBLE:C603(*;"YellowCircle";False:C215)

  //Copy the updated master list into the form
Form:C1466.masterList:=Storage:C1525.devQuickOpen.masterList.copy()

  //Rerun the search in case it needs to be updated
DevQuickOpen_OnSearch 
