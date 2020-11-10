//%attributes = {}
/* Sometimes you may want to know if the handler is running or not. This method
will let you know.
*/

C_BOOLEAN:C305($0;$fIsRunning)

$fIsRunning:=Choose:C955(Method called on event:C705="DevQuickOpen_EventHandler";True:C214;False:C215)

$0:=$fIsRunning