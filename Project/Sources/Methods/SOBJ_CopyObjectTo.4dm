//%attributes = {"folder":"Shared Objects","lang":"en"}
//It isn't possible to use OB Copy to copy a regular object into a shared object. This method
//gets around the limitation by brute-force copying each element, thus making it possible to
//copy a regular object into a shared object.

//Example:

//C_OBJECT($oMeta)
//$oMeta:=OBJ_Load_FromFile ("...")
//Use (Storage)
//  Storage.meta:=New shared object
//  Use (Storage.meta)
//    SOBJ_CopyObjectTo ($oMeta;Storage.meta)
//  End use 
//End use 

C_OBJECT($1; $oObjectToCopy)  //The object we want to copy into the shared object
C_OBJECT($2; $oSharedObject)  //The shared object we want to be a copy of the first object

$oObjectToCopy:=$1
$oSharedObject:=$2

C_LONGINT($lType; $x)

ARRAY TEXT($arrNames; 0)

OB GET PROPERTY NAMES($oObjectToCopy; $arrNames)
For ($x; 1; Size of array($arrNames))
	$lType:=OB Get type($oObjectToCopy; $arrNames{$x})
	Case of 
		: ($lType=Is object)
			$oSharedObject[$arrNames{$x}]:=New shared object
			Use ($oSharedObject[$arrNames{$x}])
				SOBJ_CopyObjectTo($oObjectToCopy[$arrNames{$x}]; $oSharedObject[$arrNames{$x}])
			End use 
		: ($lType=Is collection)
			$oSharedObject[$arrNames{$x}]:=New shared collection
			Use ($oSharedObject[$arrNames{$x}])
				SOBJ_CopyCollectionTo($oObjectToCopy[$arrNames{$x}]; $oSharedObject[$arrNames{$x}])
			End use 
		Else 
			$oSharedObject[$arrNames{$x}]:=$oObjectToCopy[$arrNames{$x}]
	End case 
End for 