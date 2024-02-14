//%attributes = {"folder":"Developer Quick Open","lang":"en"}
/* This method is run when the master list worker has finished refreshing the
master list and runs in the context of the window.
*/

//Update the signal in the window that the refresh is finished
OBJECT SET VISIBLE(*; "YellowCircle"; False)

//Copy the updated master list into the form
Form.masterList:=Storage.devQuickOpen.masterList.copy()

//Rerun the search in case it needs to be updated
DevQuickOpen_OnSearch
