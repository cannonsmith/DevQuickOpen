//%attributes = {"folder":"Developer Quick Open","lang":"en"}
/* This method is the process head for the Quick Open window. It makes sure the event handler isn't
running while the window is open, makes sure the Storage.devQuickOpen shared object is initialized,
fires off the background worker process which will create an updated list of items, and opens the
Quick Open window.
*/

C_LONGINT($lWin)
C_BOOLEAN($fHandlerWasRunning)

/* If the handler is running, then we need to temporarily pause it while the window is open. We don't
want it to try to re-open the window when it is already open. We'll get it going again after the
window is closed.
*/
$fHandlerWasRunning:=DevQuickOpen_IsHandlerRunning
If ($fHandlerWasRunning=True)
	DevQuickOpen_EndHandler
End if 

/* We want to make sure the shared object we use to track things for this window is set up in case
this is the first time this is run.
*/
If (Storage.devQuickOpen=Null)
	Use (Storage)
		Storage.devQuickOpen:=New shared object
		Use (Storage.devQuickOpen)
			Storage.devQuickOpen.masterList:=New shared collection
			Storage.devQuickOpen.lastRefresh:=Milliseconds
			Storage.devQuickOpen.isRefreshing:=False
			Storage.devQuickOpen.refreshMilliseconds:=0
			Storage.devQuickOpen.winRef:=0
		End use 
	End use 
End if 


/* We next want to ask the background worker which will refresh the master list to get started, but
it will need to know the reference to the window to pass the master list back to. So we actually
call Open form window first, then start the background worker, and then continue with the DIALOG
command.
*/
$lWin:=Open form window("DevQuickOpen"; Pop up form window; Horizontally centered; Menu bar height+70)
Use (Storage.devQuickOpen)
	Storage.devQuickOpen.isRefreshing:=True
	Storage.devQuickOpen.winRef:=$lWin
End use 
CALL WORKER("DevQuickOpenWorker"; "DevQuickOpen_Worker")

//Now we continue with opening the dialog
DIALOG("DevQuickOpen")
CLOSE WINDOW($lWin)

//Restart the handler if it was running before the window opened.
If ($fHandlerWasRunning=True)
	DevQuickOpen_BeginHandler
End if 
