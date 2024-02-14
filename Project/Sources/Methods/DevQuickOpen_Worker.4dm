//%attributes = {"folder":"Developer Quick Open","lang":"en"}
/* This method is run in a worker and is called the same time the Quick Open window is opening.
Its job is to decide whether to refresh the master list and do the refreshing if needed. It
then calls the window to know it is done. The window will use the last master list until the
new one comes in. This allows the user to start typing using the old list even while a new
one is being built in case it takes a long time.

BTW, there is no point in having this method run in a preemptive process because those aren't
supported in interpreted mode which is the only mode this will ever run in.
*/

C_LONGINT($lThreshold)
C_REAL($rBegin; $rEnd)
C_COLLECTION($cMasterList)

/* You can use a threshold to tell the worker to not refresh again unless at least this many
milliseconds have passed since the last refresh. On small databases, this probably doesn't
matter as the refresh will be faster than you can start typing. But if it starts to matter on
larger databases and you aren't actually adding many new methods, you may want to change this
threshold so doing lots of searches in a small amount of time won't keep firing off the master
list update over and over.
*/
$lThreshold:=0  //Milliseconds. 0 effectively ensures the list is rebuilt every time.


//Build a new master list if enough time has passed since the last one
If ((Milliseconds-Storage.devQuickOpen.lastRefresh)>$lThreshold)
	
	DELAY PROCESS(Current process; 10)
	
	//Build a new master list
	$rBegin:=Milliseconds
	$cMasterList:=DevQuickOpen_BuildMasterList
	$rEnd:=Milliseconds
	
	Use (Storage.devQuickOpen)
		Use (Storage.devQuickOpen.masterList)
			//The following can be replaced with .copy() in v18 R3 or later which can copy to a shared collection.
			//Then there is no reliance on the two SOBJ_ methods.
			SOBJ_CopyCollectionTo($cMasterList; Storage.devQuickOpen.masterList)
		End use 
		Storage.devQuickOpen.lastRefresh:=Milliseconds
		Storage.devQuickOpen.refreshMilliseconds:=$rEnd-$rBegin
	End use 
	
End if 


//Record that we are done refreshing
Use (Storage.devQuickOpen)
	Storage.devQuickOpen.isRefreshing:=False
End use 


//Now let the window know the master list is available
CALL FORM(Storage.devQuickOpen.winRef; "DevQuickOpen_OnMasterListUpdate")
