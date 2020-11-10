//%attributes = {}
/* This method is the process head for the Quick Open window. It makes sure the event handler isn't
running while the window is open, makes sure the Storage.devQuickOpen shared object is initialized,
fires off the background worker process which will create an updated list of items, and opens the
Quick Open window.
*/

C_LONGINT:C283($lWin)
C_BOOLEAN:C305($fHandlerWasRunning)

/* If the handler is running, then we need to temporarily pause it while the window is open. We don't
want it to try to re-open the window when it is already open. We'll get it going again after the
window is closed.
*/
$fHandlerWasRunning:=DevQuickOpen_IsHandlerRunning 
If ($fHandlerWasRunning=True:C214)
	DevQuickOpen_EndHandler 
End if 

/* We want to make sure the shared object we use to track things for this window is set up in case
this is the first time this is run.
*/
If (Storage:C1525.devQuickOpen=Null:C1517)
	Use (Storage:C1525)
		Storage:C1525.devQuickOpen:=New shared object:C1526
		Use (Storage:C1525.devQuickOpen)
			Storage:C1525.devQuickOpen.masterList:=New shared collection:C1527
			Storage:C1525.devQuickOpen.lastRefresh:=Milliseconds:C459
			Storage:C1525.devQuickOpen.isRefreshing:=False:C215
			Storage:C1525.devQuickOpen.refreshMilliseconds:=0
			Storage:C1525.devQuickOpen.winRef:=0
		End use 
	End use 
End if 


/* We next want to ask the background worker which will refresh the master list to get started, but
it will need to know the reference to the window to pass the master list back to. So we actually
call Open form window first, then start the background worker, and then continue with the DIALOG
command.
*/
$lWin:=Open form window:C675("DevQuickOpen";Pop up form window:K39:11;Horizontally centered:K39:1;Menu bar height:C440+70)
Use (Storage:C1525.devQuickOpen)
	Storage:C1525.devQuickOpen.isRefreshing:=True:C214
	Storage:C1525.devQuickOpen.winRef:=$lWin
End use 
CALL WORKER:C1389("DevQuickOpenWorker";"DevQuickOpen_Worker")

  //Now we continue with opening the dialog
DIALOG:C40("DevQuickOpen")
CLOSE WINDOW:C154($lWin)

  //Restart the handler if it was running before the window opened.
If ($fHandlerWasRunning=True:C214)
	DevQuickOpen_BeginHandler 
End if 
