//%attributes = {}
/* This method handles updating the window and list as keystrokes are entered in the search field.
It makes sure the window is expanded if at least one character is entered, filters the list based
on what is entered, and sorts the list by ranking according to relevance. The hope is that the
item they want to open is the first item in the list so only Enter needs to be hit.
*/

C_TEXT:C284($tSearch)
C_LONGINT:C283($lLeft;$lTop;$lRight;$lBottom;$lSearchBottom;$lDiff;$lNamePosition;$lNameRank)
C_LONGINT:C283($lFolderPosition;$lFolderRank;$lTypePosition;$lTypeRank)
C_OBJECT:C1216($oItem)
C_COLLECTION:C1488($cFiltered)

$tSearch:=Form:C1466.search

/* First handle window expansion. Once they've entered at least one character, we make
sure the window is expanded. If they get back to zero characters, we collapse it again.
*/
If ((Length:C16($tSearch)>0) & (Form:C1466.isExpanded=False:C215))  //Then it needs to be expanded
	
	OBJECT GET COORDINATES:C663(*;"Background";$lLeft;$lTop;$lRight;$lBottom)
	OBJECT GET COORDINATES:C663(*;"SearchBackground";$lLeft;$lTop;$lRight;$lSearchBottom)
	$lDiff:=$lBottom-$lSearchBottom-10
	
	GET WINDOW RECT:C443($lLeft;$lTop;$lRight;$lBottom)
	SET WINDOW RECT:C444($lLeft;$lTop;$lRight;$lBottom+$lDiff)
	
	Form:C1466.isExpanded:=True:C214
End if 

If ((Length:C16($tSearch)=0) & (Form:C1466.isExpanded=True:C214))  //Then it needs to be collapsed
	
	OBJECT GET COORDINATES:C663(*;"Background";$lLeft;$lTop;$lRight;$lBottom)
	OBJECT GET COORDINATES:C663(*;"SearchBackground";$lLeft;$lTop;$lRight;$lSearchBottom)
	$lDiff:=$lBottom-$lSearchBottom-10
	
	GET WINDOW RECT:C443($lLeft;$lTop;$lRight;$lBottom)
	SET WINDOW RECT:C444($lLeft;$lTop;$lRight;$lBottom-$lDiff)
	
	Form:C1466.isExpanded:=False:C215
End if 



/* Now handle the search itself
*/
If ($tSearch="")
	
	  //Show the entire list and deselect all rows. The windows will be collapsed at this stage anyway,
	  //but we do it anyway. Why? I guess to just feel cleaner. Like taking a shower every day! :-)
	Form:C1466.lbResults.display:=Form:C1466.masterList
	LISTBOX SELECT ROW:C912(*;"lbResults";0;lk replace selection:K53:1)
	
Else 
	
	  //First filter the list to items that have the query string in them at some point
	$cFiltered:=Form:C1466.masterList.query("name = :1 OR folder = :1 or type = :1";"@"+$tSearch+"@")
	
	  //Now assign a ranking to each item
	For each ($oItem;$cFiltered)
		
		$lNamePosition:=Position:C15($tSearch;$oItem.name)
		$lFolderPosition:=Position:C15($tSearch;$oItem.folder)
		$lTypePosition:=Position:C15($tSearch;$oItem.type)
		
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
		
		$oItem.rank:=$lNameRank+$lFolderRank+$lTypeRank+Choose:C955($oItem.name=$tSearch;1000;0)
		
	End for each 
	
	  //And then update the list box with the filtered items sorted by rank
	Form:C1466.lbResults.display:=$cFiltered.orderBy("rank desc, name asc")
	
	  //And make sure the first row is selected so it is ready for them to hit return/enter
	LISTBOX SELECT ROW:C912(*;"lbResults";1;lk replace selection:K53:1)
	
End if 
