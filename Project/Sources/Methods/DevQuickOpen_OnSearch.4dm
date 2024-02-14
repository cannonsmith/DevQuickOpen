//%attributes = {"folder":"Developer Quick Open","lang":"en"}
/* This method handles updating the window and list as keystrokes are entered in the search field.
It makes sure the window is expanded if at least one character is entered, filters the list based
on what is entered, and sorts the list by ranking according to relevance. The hope is that the
item they want to open is the first item in the list so only Enter needs to be hit.
*/

C_TEXT($tSearch)
C_LONGINT($lLeft; $lTop; $lRight; $lBottom; $lSearchBottom; $lDiff; $lNamePosition; $lNameRank)
C_LONGINT($lFolderPosition; $lFolderRank; $lTypePosition; $lTypeRank)
C_OBJECT($oItem)
C_COLLECTION($cFiltered)

$tSearch:=Form.search

/* First handle window expansion. Once they've entered at least one character, we make
sure the window is expanded. If they get back to zero characters, we collapse it again.
*/
If ((Length($tSearch)>0) & (Form.isExpanded=False))  //Then it needs to be expanded
	
	OBJECT GET COORDINATES(*; "Background"; $lLeft; $lTop; $lRight; $lBottom)
	OBJECT GET COORDINATES(*; "SearchBackground"; $lLeft; $lTop; $lRight; $lSearchBottom)
	$lDiff:=$lBottom-$lSearchBottom-10
	
	GET WINDOW RECT($lLeft; $lTop; $lRight; $lBottom)
	SET WINDOW RECT($lLeft; $lTop; $lRight; $lBottom+$lDiff)
	
	Form.isExpanded:=True
End if 

If ((Length($tSearch)=0) & (Form.isExpanded=True))  //Then it needs to be collapsed
	
	OBJECT GET COORDINATES(*; "Background"; $lLeft; $lTop; $lRight; $lBottom)
	OBJECT GET COORDINATES(*; "SearchBackground"; $lLeft; $lTop; $lRight; $lSearchBottom)
	$lDiff:=$lBottom-$lSearchBottom-10
	
	GET WINDOW RECT($lLeft; $lTop; $lRight; $lBottom)
	SET WINDOW RECT($lLeft; $lTop; $lRight; $lBottom-$lDiff)
	
	Form.isExpanded:=False
End if 



/* Now handle the search itself
*/
If ($tSearch="")
	
	//Show the entire list and deselect all rows. The windows will be collapsed at this stage anyway,
	//but we do it anyway. Why? I guess to just feel cleaner. Like taking a shower every day! :-)
	Form.lbResults.display:=Form.masterList
	LISTBOX SELECT ROW(*; "lbResults"; 0; lk replace selection)
	
Else 
	
	//First filter the list to items that have the query string in them at some point
	$cFiltered:=Form.masterList.query("name = :1 OR folder = :1 or type = :1"; "@"+$tSearch+"@")
	
	//Now assign a ranking to each item
	For each ($oItem; $cFiltered)
		
		$lNamePosition:=Position($tSearch; $oItem.name)
		$lFolderPosition:=Position($tSearch; $oItem.folder)
		$lTypePosition:=Position($tSearch; $oItem.type)
		
		$lNameRank:=0
		If ($lNamePosition>0)
			$lNameRank:=1000-($lNamePosition*25)  //Lose points for every character away from the beginning the search term is
		End if 
		
		$lFolderRank:=0
		If ($lFolderPosition>0)
			$lFolderRank:=400-($lFolderPosition*20)  //Lose points for every character away from the beginning the search term is
		End if 
		
		$lTypeRank:=0
		If ($lTypePosition>0)
			$lTypeRank:=100-($lTypePosition*10)  //Lose points for every character away from the beginning the search term is
		End if 
		
		$oItem.rank:=$lNameRank+$lFolderRank+$lTypeRank+Choose($oItem.name=$tSearch; 1000; 0)
		
	End for each 
	
	//And then update the list box with the filtered items sorted by rank
	Form.lbResults.display:=$cFiltered.orderBy("rank desc, name asc")
	
	//And make sure the first row is selected so it is ready for them to hit return/enter
	LISTBOX SELECT ROW(*; "lbResults"; 1; lk replace selection)
	
End if 
