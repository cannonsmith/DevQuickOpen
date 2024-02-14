//%attributes = {"folder":"Developer Quick Open","lang":"en"}
/* We want the window to open in a different process than the event handler process.

Normally this is called from the event handler, but it can also be called directly
based on something else if desired.
*/

C_LONGINT($lProcess)

$lProcess:=New process("DevQuickOpen_P"; 0; "$DevQuickOpenWindow"; *)
BRING TO FRONT($lProcess)

