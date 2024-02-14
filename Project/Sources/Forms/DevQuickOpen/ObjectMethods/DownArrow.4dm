C_LONGINT($lSelected; $lCount)

$lSelected:=Form.lbResults.itemPosition
$lCount:=Form.lbResults.display.length

If (($lSelected>=0) & ($lSelected<$lCount))
	$lSelected:=$lSelected+1
	LISTBOX SELECT ROW(*; "lbResults"; $lSelected; lk replace selection)
	OBJECT SET SCROLL POSITION(*; "lbResults"; $lSelected)
End if 
