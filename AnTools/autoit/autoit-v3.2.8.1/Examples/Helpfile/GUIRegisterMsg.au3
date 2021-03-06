; *******************************************************
; Example - Create an ownerdrawn/colored button
; *******************************************************

#include <GUIConstants.au3>

Global Const $WM_DRAWITEM			= 0x002B
Global Const $WM_COMMAND			= 0x0111

Global Const $GWL_STYLE 			= -16

Global Const $BS_OWNERDRAW			= 0x0000000B

Global Const $COLOR_BTNTEXT			= 18
Global Const $COLOR_BTNFACE			= 15
Global Const $COLOR_BTNSHADOW		= 16
Global Const $COLOR_HIGHLIGHTTEXT	= 14
Global Const $COLOR_GRAYTEXT		= 17

Global Const $DT_CENTER				= 0x00000001
Global Const $DT_RIGHT				= 0x00000002
Global Const $DT_VCENTER			= 0x00000004
Global Const $DT_BOTTOM				= 0x00000008
Global Const $DT_WORDBREAK			= 0x00000010
Global Const $DT_SINGLELINE			= 0x00000020
Global Const $DT_EXPANDTABS			= 0x00000040
Global Const $DT_TABSTOP			= 0x00000080
Global Const $DT_NOCLIP				= 0x00000100
Global Const $DT_EXTERNALLEADING	= 0x00000200
Global Const $DT_CALCRECT			= 0x00000400
Global Const $DT_NOPREFIX			= 0x00000800
Global Const $DT_INTERNAL			= 0x00001000

Global Const $ODS_SELECTED			= 0x0001
Global Const $ODS_GRAYED			= 0x0002
Global Const $ODS_DISABLED			= 0x0004
Global Const $ODS_CHECKED			= 0x0008
Global Const $ODS_FOCUS				= 0x0010
Global Const $ODS_HOTLIGHT			= 0x0040
Global Const $ODS_INACTIVE			= 0x0080
Global Const $ODS_NOACCEL			= 0x0100
Global Const $ODS_NOFOCUSRECT		= 0x0200

Global Const $ODT_BUTTON			= 4

Global Const $DFC_BUTTON			= 4
Global Const $DFCS_BUTTONPUSH		= 0x0010


$hGUI		= GUICreate("My Ownerdrawn Created Button", 300, 200)

$nButton	= GUICtrlCreateButton("", 90, 50, 120, 30)
GUICtrlSetStyle($nButton, BitOr($WS_TABSTOP, $BS_NOTIFY, $BS_OWNERDRAW)) ; Set the ownerdrawn flag

$nButton2	= GUICtrlCreateButton("Normal Button", 90, 110, 120, 30)

GUIRegisterMsg($WM_COMMAND, "MY_WM_COMMAND")
; WM_DRAWITEM has to registered before showing GUI otherwise the initial drawing isn't done
GUIRegisterMsg($WM_DRAWITEM, "MY_WM_DRAWITEM")

GUISetState()

While 1
	$GUIMsg = GUIGetMsg()
	
	Switch $GUIMsg
		Case $GUI_EVENT_CLOSE
			ExitLoop
			
		Case $nButton
			; Normally should not run through cause of our MY_WM_COMMAND function
			Msgbox(0, "Info", "Button pressed") 
			
		Case $nButton2
			; Normally should not run through cause of our MY_WM_COMMAND function
			Msgbox(0, "Info", "Button2 pressed")
	EndSwitch
WEnd

Exit


; React on a button click
Func MY_WM_COMMAND($hWnd, $Msg, $wParam, $lParam)
	$nNotifyCode	= BitShift($wParam, 16)
	$nID			= BitAnd($wParam, 0x0000FFFF)
	$hCtrl			= $lParam
	
	If $nID <> 2 And $nNotifyCode = 0 Then ; Check for IDCANCEL - 2
		; Ownerdrawn buttons don't send something by pressing ENTER
		; So IDOK - 1 comes up, now check for the control that has the current focus
		If $nID = 1 Then
			$hFocus = DllCall("user32.dll", "hwnd", "GetFocus")
			$nCtrlID = DllCall("user32.dll", "int", "GetDlgCtrlID", "hwnd", $hFocus[0])
			PostButtonClick($hFocus[0], $nCtrlID[0])
		Else
			Msgbox(0, "MY_WM_COMMAND", "GUIHWnd" & @TAB & ":" & $hwnd & @LF & _
										"MsgID" & @TAB & ":" & $Msg & @LF & _
										"wParam" & @TAB & ":" & $wParam & @LF & _
										"lParam" & @TAB & ":" & $lParam & @LF & @LF & _
										"WM_COMMAND - Infos:" & @LF & _
										"-----------------------------" & @LF & _
										"Code" & @TAB & ":" & $nNotifyCode & @LF & _
										"CtrlID" & @TAB & ":" & $nID & @LF & _
										"CtrlHWnd" & @TAB & ":" & $hCtrl)
		EndIf
		Return 0 ; Only workout clicking on the button
	EndIf
	; Proceed the default Autoit3 internal message commands.
	; You also can complete let the line out.
	; !!! But only 'Return' (without any value) will not proceed
	; the default Autoit3-message in the future !!!
	Return $GUI_RUNDEFMSG
EndFunc


; RePost a WM_COMMAND message to a ctrl in a gui window
Func PostButtonClick($hWnd, $nCtrlID)
	DllCall("user32.dll", "int", "PostMessage", _
									"hwnd", $hGUI, _
									"int", $WM_COMMAND, _
									"int", BitAnd($nCtrlID, 0x0000FFFF), _
									"hwnd", GUICtrlGetHandle($nCtrlid))
EndFunc


; Draw the button
Func MY_WM_DRAWITEM($hWnd, $Msg, $wParam, $lParam)
	Local $stDrawItem = DllStructCreate("uint;uint;uint;uint;uint;uint;uint;int[4];dword", $lParam)
	
	$nCtlType = DllStructGetData($stDrawItem, 1)
	If $nCtlType = $ODT_BUTTON Then
		$nCtrlID	= DllStructGetData($stDrawItem, 2)
		$nItemState	= DllStructGetData($stDrawItem, 5)
		$hCtrl		= DllStructGetData($stDrawItem, 6)
		$hDC		= DllStructGetData($stDrawItem, 7)
		$nLeft		= DllStructGetData($stDrawItem, 8, 1)
		$nTop		= DllStructGetData($stDrawItem, 8, 2)
		$nRight		= DllStructGetData($stDrawItem, 8, 3)
		$nBottom	= DllStructGetData($stDrawItem, 8, 4)
		$sText		= "Ownerdrawn Button"
		$nTextColor	= 0x5555DD
		$nBackColor	= 0xFFEEDD
		DrawButton($hWnd, $hCtrl, $hDC, $nLeft, $nTop, $nRight, $nBottom, $nItemState, $sText, $nTextColor, $nBackColor)
		$stDrawItem = 0
		Return 1
	EndIf

	$stDrawItem = 0
	Return $GUI_RUNDEFMSG ; Proceed the default Autoit3 internal message commands
EndFunc


; The main drawing procedure
Func DrawButton($hWnd, $hCtrl, $hDC, $nLeft, $nTop, $nRight, $nBottom, $nItemState, $sText, $nTextColor, $nBackColor)
	;Local $bDefault	= FALSE
	Local $bChecked	= BitAnd($nItemState, $ODS_CHECKED)
	Local $bFocused	= BitAnd($nItemState, $ODS_FOCUS)
	Local $bGrayed	= BitAnd($nItemState, BitOr($ODS_GRAYED, $ODS_DISABLED))
	Local $bSelected= BitAnd($nItemState, $ODS_SELECTED)

	$stRect = DllStructCreate("int;int;int;int")
	DllStructSetData($stRect, 1, $nLeft)
	DllStructSetData($stRect, 2, $nTop)
	DllStructSetData($stRect, 3, $nRight)
	DllStructSetData($stRect, 4, $nBottom)
	
	If $bGrayed Then
		$nClrTxt	= SetTextColor($hDC, GetSysColor($COLOR_HIGHLIGHTTEXT))
	ElseIf $nTextColor = -1 Then
		$nClrTxt	= SetTextColor($hDC, GetSysColor($COLOR_BTNTEXT))
	Else
		$nClrTxt	= SetTextColor($hDC, $nTextColor)
	EndIf
	
	If $nBackColor = -1 Then
		$hBrush		= GetSysColorBrush($COLOR_BTNFACE)
		$nClrSel	= GetSysColor($COLOR_BTNFACE)
	Else
		$hBrush		= CreateSolidBrush($nBackColor)
		$nClrSel	= $nBackColor;
	EndIf

	$nClrBk			= SetBkColor($hDC, $nClrSel)
	$hOldBrush		= SelectObject($hDC, $hBrush)

	$nTmpLeft	= $nLeft
	$nTmpTop	= $nTop
	$nTmpRight	= $nRight
	$nTmpBottom	= $nBottom
	
	If $bSelected Then
		InflateRect($nTmpLeft, $nTmpTop, $nTmpRight, $nTmpBottom, -1, -1)
		$hBrushSel = CreateSolidBrush(GetSysColor($COLOR_BTNSHADOW))
		FrameRect($hDC, $nTmpLeft, $nTmpTop, $nTmpRight, $nTmpBottom, $hBrushSel)
		DeleteObject($hBrushSel)
	Else
		If $bFocused And Not $bSelected Then InflateRect($nTmpLeft, $nTmpTop, $nTmpRight, $nTmpBottom, -1, -1)
		DrawFrameControl($hDC, $nTmpLeft, $nTmpTop, $nTmpRight, $nTmpBottom, $DFC_BUTTON, $DFCS_BUTTONPUSH)
	EndIf
	
	$nTmpLeft	= $nLeft
	$nTmpTop	= $nTop
	$nTmpRight	= $nRight
	$nTmpBottom	= $nBottom
	
	If $bSelected Then
		InflateRect($nTmpLeft, $nTmpTop, $nTmpRight, $nTmpBottom, -2, -2)
	Else
		If $bFocused And Not $bSelected Then
			InflateRect($nTmpLeft, $nTmpTop, $nTmpRight, $nTmpBottom, -3, -3)
			$nTmpLeft -= 1
			$nTmpTop -= 1
		Else
			InflateRect($nTmpLeft, $nTmpTop, $nTmpRight, $nTmpBottom, -2, -2)
			$nTmpLeft -= 1
			$nTmpTop -= 1
		EndIf
	EndIf
	
	FillRect($hDC, $nTmpLeft, $nTmpTop, $nTmpRight, $nTmpBottom, $hBrush)
	
	If $bSelected Or $bGrayed Then
		$nTmpLeft = $nTmpLeft + 2
		$nTmpTop = $nTmpTop +2
	EndIf
	
	$uFlags = BitOr($DT_NOCLIP, $DT_CENTER, $DT_VCENTER)

	If Not BitAnd(GetWindowLong($hCtrl, $GWL_STYLE), $BS_MULTILINE) Then $uFlags = BitOr($uFlags, $DT_SINGLELINE)
	
	DrawText($hDC, $sText, $nTmpLeft, $nTmpTop, $nTmpRight, $nTmpBottom, $uFlags)

	If $bGrayed Then
		$nTmpLeft	= $nLeft
		$nTmpTop	= $nTop
		$nTmpRight	= $nRight
		$nTmpBottom	= $nBottom
		
		$nTmpLeft -= 1
		
		$nClrTxt	= SetTextColor($hDC, GetSysColor($COLOR_GRAYTEXT))
		DrawText($hDC, $sText, $nTmpLeft, $nTmpTop, $nTmpRight, $nTmpBottom, BitOr($DT_NOCLIP, $DT_CENTER, $DT_VCENTER, $DT_SINGLELINE))
	EndIf

	$nTmpLeft	= $nLeft
	$nTmpTop	= $nTop
	$nTmpRight	= $nRight
	$nTmpBottom	= $nBottom
		
	If $bFocused Then
		$hBrush	= CreateSolidBrush(0)
		FrameRect($hDC, $nTmpLeft, $nTmpTop, $nTmpRight, $nTmpBottom, $hBrush)
		
		$nTmpLeft	= $nLeft
		$nTmpTop	= $nTop
		$nTmpRight	= $nRight
		$nTmpBottom	= $nBottom
		
		InflateRect($nTmpLeft, $nTmpTop, $nTmpRight, $nTmpBottom, -4, -4)
		DrawFocusRect($hDC, $nTmpLeft, $nTmpTop, $nTmpRight, $nTmpBottom)
	EndIf

	SelectObject($hDC, $hOldBrush)
	DeleteObject($hBrush)
	SetTextColor($hDC, $nClrTxt)
	SetBkColor($hDC, $nClrBk)
		 
	Return 1
EndFunc


; Some graphic / windows functions
Func CreateSolidBrush($nColor)
	Local $hBrush = DllCall("gdi32.dll", "hwnd", "CreateSolidBrush", "int", $nColor)
	Return $hBrush[0]
EndFunc


Func GetSysColor($nIndex)
	Local $nColor = DllCall("user32.dll", "int", "GetSysColor", "int", $nIndex)
	Return $nColor[0]
EndFunc


Func GetSysColorBrush($nIndex)
	Local $hBrush = DllCall("user32.dll", "hwnd", "GetSysColorBrush", "int", $nIndex)
	Return $hBrush[0]
EndFunc


Func DrawFrameControl($hDC, $nLeft, $nTop, $nRight, $nBottom, $nType, $nState)
	Local 	$stRect = DllStructCreate("int;int;int;int")
	
	DllStructSetData($stRect, 1, $nLeft)
	DllStructSetData($stRect, 2, $nTop)
	DllStructSetData($stRect, 3, $nRight)
	DllStructSetData($stRect, 4, $nBottom)
	
	DllCall("user32.dll", "int", "DrawFrameControl", "hwnd", $hDC, "ptr", DllStructGetPtr($stRect), "int", $nType, "int", $nState)

	$stRect = 0
EndFunc


Func DrawFocusRect($hDC, $nLeft, $nTop, $nRight, $nBottom)
	Local 	$stRect = DllStructCreate("int;int;int;int")
	
	DllStructSetData($stRect, 1, $nLeft)
	DllStructSetData($stRect, 2, $nTop)
	DllStructSetData($stRect, 3, $nRight)
	DllStructSetData($stRect, 4, $nBottom)
	
	DllCall("user32.dll", "int", "DrawFocusRect", "hwnd", $hDC, "ptr", DllStructGetPtr($stRect))
	
	$stRect = 0
EndFunc


Func DrawText($hDC, $sText, $nLeft, $nTop, $nRight, $nBottom, $nFormat)
	Local $nLen = StringLen($sText)
	
	Local $stRect = DllStructCreate("int;int;int;int")
	DllStructSetData($stRect, 1, $nLeft)
	DllStructSetData($stRect, 2, $nTop)
	DllStructSetData($stRect, 3, $nRight)
	DllStructSetData($stRect, 4, $nBottom)
	
	Local $stText = DllStructCreate("char[260]")
	DllStructSetData($stText, 1, $sText)
	
	DllCall("user32.dll", "int", "DrawText", "hwnd", $hDC, "ptr", DllStructGetPtr($stText), "int", $nLen, "ptr", DllStructGetPtr($stRect), "int", $nFormat)
	
	$stRect = 0
	$stText	= 0
EndFunc


Func FillRect($hDC, $nLeft, $nTop, $nRight, $nBottom, $hBrush)
	Local 	$stRect = DllStructCreate("int;int;int;int")
	
	DllStructSetData($stRect, 1, $nLeft)
	DllStructSetData($stRect, 2, $nTop)
	DllStructSetData($stRect, 3, $nRight)
	DllStructSetData($stRect, 4, $nBottom)
	
	DllCall("user32.dll", "int", "FillRect", "hwnd", $hDC, "ptr", DllStructGetPtr($stRect), "hwnd", $hBrush)
	
	$stRect = 0
EndFunc


Func FrameRect($hDC, $nLeft, $nTop, $nRight, $nBottom, $hBrush)
	Local 	$stRect = DllStructCreate("int;int;int;int")
	
	DllStructSetData($stRect, 1, $nLeft)
	DllStructSetData($stRect, 2, $nTop)
	DllStructSetData($stRect, 3, $nRight)
	DllStructSetData($stRect, 4, $nBottom)
	
	DllCall("user32.dll", "int", "FrameRect", "hwnd", $hDC, "ptr", DllStructGetPtr($stRect), "hwnd", $hBrush)
	
	$stRect = 0
EndFunc


Func InflateRect(ByRef $nLeft, ByRef $nTop, ByRef $nRight, ByRef $nBottom, $nX, $nY)
	Local 	$stRect = DllStructCreate("int;int;int;int")
	
	DllStructSetData($stRect, 1, $nLeft)
	DllStructSetData($stRect, 2, $nTop)
	DllStructSetData($stRect, 3, $nRight)
	DllStructSetData($stRect, 4, $nBottom)
	
	DllCall("user32.dll", "int", "InflateRect", "ptr", DllStructGetPtr($stRect), "int", $nX, "int", $nY)
	
	$nLeft		= DllStructGetData($stRect, 1)
	$nTop		= DllStructGetData($stRect, 2)
	$nRight		= DllStructGetData($stRect, 3)
	$nBottom	= DllStructGetData($stRect, 4)
	
	$stRect = 0
EndFunc


Func SetBkColor($hDC, $nColor)
	Local $nOldColor = DllCall("gdi32.dll", "int", "SetBkColor", "hwnd", $hDC, "int", $nColor)
	Return $nOldColor[0]
EndFunc


Func SetTextColor($hDC, $nColor)
	Local $nOldColor = DllCall("gdi32.dll", "int", "SetTextColor", "hwnd", $hDC, "int", $nColor)
	Return $nOldColor[0]
EndFunc


Func SelectObject($hDC, $hObj)
	Local $hOldObj = DllCall("gdi32.dll", "hwnd", "SelectObject", "hwnd", $hDC, "hwnd", $hObj)
	Return $hOldObj[0]
EndFunc


Func DeleteObject($hObj)
	Local $nResult = DllCall("gdi32.dll", "hwnd", "DeleteObject", "hwnd", $hObj)
EndFunc


Func GetWindowLong($hWnd, $nIndex)
	Local $nVal = DllCall("user32.dll", "int", "GetWindowLong", "hwnd", $hWnd, "int", $nIndex)
	Return $nVal[0]
EndFunc
