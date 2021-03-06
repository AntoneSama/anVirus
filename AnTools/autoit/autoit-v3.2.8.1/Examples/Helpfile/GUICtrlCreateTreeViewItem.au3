#include <GUIConstants.au3>

GUICreate("My GUI with treeview", 350, 215)

$treeview       = GUICtrlCreateTreeView(6, 6, 100, 150, BitOr($TVS_HASBUTTONS, $TVS_HASLINES, $TVS_LINESATROOT, $TVS_DISABLEDRAGDROP, $TVS_SHOWSELALWAYS), $WS_EX_CLIENTEDGE)
$generalitem    = GUICtrlCreateTreeViewitem("General", $treeview)
GUICtrlSetColor(-1, 0x0000C0)
$displayitem    = GUICtrlCreateTreeViewitem("Display", $treeview)
GUICtrlSetColor(-1, 0x0000C0)
$aboutitem      = GUICtrlCreateTreeViewitem("About", $generalitem)
$compitem       = GUICtrlCreateTreeViewitem("Computer", $generalitem)
$useritem       = GUICtrlCreateTreeViewitem("User", $generalitem)
$resitem        = GUICtrlCreateTreeViewitem("Resolution", $displayitem)
$otheritem      = GUICtrlCreateTreeViewitem("Other", $displayitem)

$startlabel     = GUICtrlCreateLabel("TreeView Demo",190,90,100,20)
$aboutlabel     = GUICtrlCreateLabel("This little scripts demonstates the using of a treeview-control.", 190, 70, 100, 60)
GUICtrlSetState(-1, $GUI_HIDE)  ; Hides the "aboutlabel"-text during initialization
$compinfo       = GUICtrlCreateLabel("Name:" & @TAB & @ComputerName & @LF & "OS:" & @TAB & @OSVersion & @LF & "SP:" & @TAB & @OSServicePack, 120, 30, 200, 80)
GUICtrlSetState(-1, $GUI_HIDE)  ; Hides the "compinfo"-text during initialization

GUICtrlCreateLabel("", 0, 170, 350, 2, $SS_SUNKEN)
$togglebutton   = GUICtrlCreateButton("&Toggle", 35, 185, 70, 20)
$infobutton     = GUICtrlCreateButton("&Info", 105, 185, 70, 20)
$statebutton	= GUICtrlCreateButton("Col./Exp.", 175, 185, 70, 20)
$cancelbutton   = GUICtrlCreateButton("&Cancel", 245, 185, 70, 20)

GUICtrlSetState($generalitem, BitOr($GUI_EXPAND,$GUI_DEFBUTTON))    ; Expand the "General"-item and paint in bold
GUICtrlSetState($displayitem, BitOr($GUI_EXPAND,$GUI_DEFBUTTON))    ; Expand the "Display"-item and paint in bold

GUISetState ()
While 1
	$msg = GUIGetMsg()
	Select
		Case $msg = $cancelbutton Or $msg = $GUI_EVENT_CLOSE
			ExitLoop
    
		Case $msg = $togglebutton   ; Toggle the bold painting
			If BitAnd(GUICtrlRead($generalitem), $GUI_DEFBUTTON) Then
				GUICtrlSetState($generalitem, 0)
				GUICtrlSetState($displayitem, 0)
			Else
				GUICtrlSetState($generalitem, $GUI_DEFBUTTON)
				GUICtrlSetState($displayitem, $GUI_DEFBUTTON)
            EndIf
        
		Case $msg = $infobutton
			$item = GUICtrlRead($treeview)      ; Get the controlID of the current selected treeview item
			If $item = 0 Then
				MsgBox(64, "TreeView Demo", "No item currently selected")
			Else
				$text = GUICtrlRead($item, 1) ; Get the text of the treeview item
				If $text == "" Then
					MsgBox(16, "Error", "Error while retrieving infos about item")
				Else
					MsgBox(64, "TreeView Demo", "Current item selected is: " & $text)
				EndIf
			EndIf
            
		Case $msg = $statebutton
        	$item = GUICtrlRead($treeview)
        	If $item > 0 Then
				$hItem = GUICtrlGetHandle($item)
				DllCall("user32.dll", "int", "SendMessage", "hwnd", GUICtrlGetHandle($treeview), "int", $TVM_EXPAND, "int", $TVE_TOGGLE, "hwnd", $hItem)
			EndIf
            
        ; The following items will hide the other labels (1st and 2nd parameter) and then show the 'own' labels (3rd and 4th parameter)
		Case $msg = $generalitem
			GUIChangeItems($aboutlabel, $compinfo, $startlabel, $startlabel)
        
		Case $msg = $aboutitem
			GUICtrlSetState ($compinfo, $GUI_HIDE)
			GUIChangeItems($startlabel, $startlabel, $aboutlabel, $aboutlabel)
            
		Case $msg = $compitem
			GUIChangeItems($startlabel, $aboutlabel, $compinfo, $compinfo)
	EndSelect
WEnd

GUIDelete()
Exit

Func GUIChangeItems($hidestart, $hideend, $showstart, $showend)
	Local $idx
    
	For $idx = $hidestart To $hideend
		GUICtrlSetState ($idx, $GUI_HIDE)
	Next
	For $idx = $showstart To $showend
		GUICtrlSetState ($idx, $GUI_SHOW)
	Next    
EndFunc
