//%attributes = {}
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

C_OBJECT:C1216($1;$oObjectToCopy)  //The object we want to copy into the shared object
C_OBJECT:C1216($2;$oSharedObject)  //The shared object we want to be a copy of the first object

$oObjectToCopy:=$1
$oSharedObject:=$2

C_LONGINT:C283($lType;$x)

ARRAY TEXT:C222($arrNames;0)

OB GET PROPERTY NAMES:C1232($oObjectToCopy;$arrNames)
For ($x;1;Size of array:C274($arrNames))
	$lType:=OB Get type:C1230($oObjectToCopy;$arrNames{$x})
	Case of 
		: ($lType=Is object:K8:27)
			$oSharedObject[$arrNames{$x}]:=New shared object:C1526
			Use ($oSharedObject[$arrNames{$x}])
				SOBJ_CopyObjectTo ($oObjectToCopy[$arrNames{$x}];$oSharedObject[$arrNames{$x}])
			End use 
		: ($lType=Is collection:K8:32)
			$oSharedObject[$arrNames{$x}]:=New shared collection:C1527
			Use ($oSharedObject[$arrNames{$x}])
				SOBJ_CopyCollectionTo ($oObjectToCopy[$arrNames{$x}];$oSharedObject[$arrNames{$x}])
			End use 
		Else 
			$oSharedObject[$arrNames{$x}]:=$oObjectToCopy[$arrNames{$x}]
	End case 
End for 