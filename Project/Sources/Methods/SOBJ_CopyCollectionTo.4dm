//%attributes = {}
  //It isn't possible to copy a regular collection into a shared collection. This method
  //gets around the limitation by brute-force copying each element, thus making it possible
  //to copy a regular collection into a shared collection.

  //See SOBJ_CopyObjectTo for an example. Doing the same with collections would be similar.

C_COLLECTION:C1488($1;$cCollectionToCopy)
C_COLLECTION:C1488($2;$cSharedCollection)

$cCollectionToCopy:=$1
$cSharedCollection:=$2

C_LONGINT:C283($lSize;$lIndex;$lType)

$lSize:=$cCollectionToCopy.length
For ($lIndex;0;$lSize-1)
	$lType:=Value type:C1509($cCollectionToCopy[$lIndex])
	Case of 
		: ($lType=Is object:K8:27)
			$cSharedCollection[$lIndex]:=New shared object:C1526
			Use ($cSharedCollection[$lIndex])
				SOBJ_CopyObjectTo ($cCollectionToCopy[$lIndex];$cSharedCollection[$lIndex])
			End use 
		: ($lType=Is collection:K8:32)
			$cSharedCollection[$lIndex]:=New shared collection:C1527
			Use ($cSharedCollection[$lIndex])
				SOBJ_CopyCollectionTo ($cCollectionToCopy[$lIndex];$cSharedCollection[$lIndex])
			End use 
		Else 
			$cSharedCollection[$lIndex]:=$cCollectionToCopy[$lIndex]
	End case 
End for 