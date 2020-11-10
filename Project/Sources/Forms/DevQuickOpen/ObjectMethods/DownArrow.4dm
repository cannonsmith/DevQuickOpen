C_LONGINT:C283($lSelected;$lCount)

$lSelected:=Form:C1466.lbResults.itemPosition
$lCount:=Form:C1466.lbResults.display.length

If (($lSelected>=0) & ($lSelected<$lCount))
	$lSelected:=$lSelected+1
	LISTBOX SELECT ROW:C912(*;"lbResults";$lSelected;lk replace selection:K53:1)
	OBJECT SET SCROLL POSITION:C906(*;"lbResults";$lSelected)
End if 
