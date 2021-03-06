#Include <Constants.au3>
#NoTrayIcon

Opt("TrayMenuMode",1)	; Default tray menu items (Script Paused/Exit) will not be shown.

$chkitem		= TrayCreateItem("Check it")
TrayCreateItem("")
$checkeditem	= TrayCreateItem("Checked")
TrayCreateItem("")
$exititem		= TrayCreateItem("Exit")

TraySetState()

While 1
	$msg = TrayGetMsg()
	Select
		Case $msg = 0
			ContinueLoop
		Case $msg = $chkitem
			TrayItemSetState($checkeditem,$TRAY_CHECKED)
		Case $msg = $exititem
			ExitLoop
	EndSelect
WEnd

Exit
