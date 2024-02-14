//%attributes = {"folder":"Shared Objects","lang":"en"}
//It isn't possible to copy a regular collection into a shared collection. This method
//gets around the limitation by brute-force copying each element, thus making it possible
//to copy a regular collection into a shared collection.

//See SOBJ_CopyObjectTo for an example. Doing the same with collections would be similar.

C_COLLECTION($1; $cCollectionToCopy)
C_COLLECTION($2; $cSharedCollection)

$cCollectionToCopy:=$1
$cSharedCollection:=$2

C_LONGINT($lSize; $lIndex; $lType)

$lSize:=$cCollectionToCopy.length
For ($lIndex; 0; $lSize-1)
	$lType:=Value type($cCollectionToCopy[$lIndex])
	Case of 
		: ($lType=Is object)
			$cSharedCollection[$lIndex]:=New shared object
			Use ($cSharedCollection[$lIndex])
				SOBJ_CopyObjectTo($cCollectionToCopy[$lIndex]; $cSharedCollection[$lIndex])
			End use 
		: ($lType=Is collection)
			$cSharedCollection[$lIndex]:=New shared collection
			Use ($cSharedCollection[$lIndex])
				SOBJ_CopyCollectionTo($cCollectionToCopy[$lIndex]; $cSharedCollection[$lIndex])
			End use 
		Else 
			$cSharedCollection[$lIndex]:=$cCollectionToCopy[$lIndex]
	End case 
End for 