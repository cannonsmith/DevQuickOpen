//%attributes = {}
/* When this event handler is installed, it listens for Option-Space and invokes the
Quick Open developer window. See documentation for the ON EVENT CALL command for
information and examples on how to listen for different kinds of keystrokes if
you want to try it.

I originally thought I'd need to listen for it like this:

If ((Modifiers ?? Option key bit) & (KeyCode = Space))

but that didn't work. With some testing I found that KeyCode = 202 is the same
as Option-Space. I don't know why, but keep that in mind if you want to change the
keystroke to something else.
*/

If (KeyCode=202)  //Option-Space
	FILTER EVENT:C321  //Don't let 4D will also get this event
	DevQuickOpen_OpenWindow 
End if 
