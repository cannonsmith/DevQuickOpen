//%attributes = {"folder":"Developer Quick Open","lang":"en"}
/* Sometimes you may want to know if the handler is running or not. This method
will let you know.
*/

C_BOOLEAN($0; $fIsRunning)

$fIsRunning:=Choose(Method called on event="DevQuickOpen_EventHandler"; True; False)

$0:=$fIsRunning