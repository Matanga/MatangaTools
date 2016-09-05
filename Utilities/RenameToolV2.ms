macroscript RenameTool
category:"Matanga"
(
	local dnInfoLabel
	local dnToolTip
	local theMainRollout
	local theUIOffset = 55
	
	global UpdateObjectCountLabel() --Declare the function as global so we can use it as a callback
	fn UpdateObjectCountLabel = --Define the Function
	(
		selectedClasses=#() --Reset selectedClasses
		classObjectsArrays=#()
		for o in selection as array do
		(
			--If this object class in not in the list add it and also add a new empty array in the classObjectsArrays array
			if(appendIfUnique selectedClasses (classof o) )do append classObjectsArrays (#())
			--Add the current node to its corresponding classObjectsArrays based on their class
			append (classObjectsArrays[findItem selectedClasses (classof o)]) o
		)
		--Create the information for the info label tooltip
		newString=""
		for m=1 to selectedClasses.count by 1 do
		newString=newString+selectedClasses[m] as string +" - " +classObjectsArrays[m].count as string + "\n"

		--Assign the tooltip text with the created string
		dnToolTip.SetToolTip dnInfoLabel newString
		--Update the info Label with the current amount of selected objects
		dnInfoLabel.text =" "+(selection.count as string)+" objects selected"
	)

	Rollout NewNameDialog "Rename Tool"
	(
		--DOTNET INFO LABEL
		dotNetControl dnlbl_SelectionInfo "System.Windows.Forms.Label" width:325 height:20

		--BASE NAME
		checkbutton cbtnBase "Base" checked:true enabled:true across:2 align:#left width:50 offset:[0,10]
		editText etBaseName "" align:#left offset:[-60,10] height:20 width:170

		--PREFIX
		checkbutton cbtnPrefix "Prefix" checked:false enabled:true across:2 align:#left width:50 offset:[0,theUIOffset]
		edittext etPrefix align:#left width:170 enabled:false offset:[-60,theUIOffset] height:20
		on cbtnPrefix changed val do
		(
			etPRefix.enabled=val
		)
		--SUFFIX
		checkbutton cbtnSuffix "Suffix" checked:false enabled:true across:2 align:#left width:50
		edittext etSuffix align:#left width:170 enabled:false offset:[-60,0] height:20
		on cbtnSuffix changed val do
		(
			etSuffix.enabled=val
		)
		---NUMBERED
		checkbutton cbtnnumbered "Numbered" checked:false enabled:true across:3 align:#left width:55
		spinner spnFrom "From" range:[0,1000000,0] type:#integer enabled:false offset:[-20,4] width:80
		spinner spnEvery "Every" range:[0,1000000,0] type:#integer enabled:false offset:[-10,4] width:80
		on cbtnnumbered changed val do
		(
			spnFrom.enabled=val
			spnEvery.enabled=val
		)
		--TRIM
		checkbutton cbtnTrim "Trim" checked:false enabled:false across:3 align:#left width:55
		spinner spnFront "Front" range:[0,20,0] type:#integer enabled:false offset:[-20,4] width:80
		spinner spnEnd "End" range:[0,20,0] type:#integer enabled:false offset:[-10,4] width:80 --Subrollout advSubRollout "Advanced"
		on cbtnTrim changed val do
		(
			spnFront.enabled=val
			spnEnd.enabled=val
		)

		--BUTTONS
		button btnApply "Apply" width:150 enabled:true offset:[50,-150] align:#center tooltip:"Left click - Rename selected " across:2
		checkbutton btnAdvanced "+" width:25 offset:[24,-150]

		on btnApply pressed do
		(
			--ADD PREFIX
			prefixText=""
			if(cbtnPrefix.checked==true) do prefixText=etPrefix.text
			--ADD SUFFIX
			suffixText=""
			if(cbtnSuffix.checked==true) do suffixText=etSuffix.text
			numberedCounter=spnFrom.value
			for o in selection do
			(
				baseText=""
				if(etBaseName.text != "") then baseText=etBaseName.text
				else baseText =o.name	
				--TRIM
				--NUMBERED
				numberedText=""
				if(cbtnnumbered.checked==true) then
				(
					numberedText="_"+(numberedCounter as string)
					numberedCounter=numberedCounter+spnEvery.value
				)
				--APPLY NEW NAME
				o.name=prefixText+baseText+suffixText+numberedText	
			)
		)

		on btnAdvanced changed val do
		(
			if (val ==true) then
			(
				--All controls must be offseted
				cbtnPrefix.pos=[cbtnPrefix.pos.x,cbtnPrefix.pos.y-theUIOffset]
				etPrefix.pos=[etPrefix.pos.x,etPrefix.pos.y-theUIOffset]
				cbtnSuffix.pos=[cbtnSuffix.pos.x,cbtnSuffix.pos.y-theUIOffset]
				etSuffix.pos=[etSuffix.pos.x,etSuffix.pos.y-theUIOffset]
				cbtnnumbered.pos=[cbtnnumbered.pos.x,cbtnnumbered.pos.y-theUIOffset]
				spnFrom.pos=[spnFrom.pos.x,spnFrom.pos.y-theUIOffset]
				spnEvery.pos=[spnEvery.pos.x,spnEvery.pos.y-theUIOffset]
				cbtnTrim.pos=[cbtnTrim.pos.x,cbtnTrim.pos.y-theUIOffset]
				spnFront.pos=[spnFront.pos.x,spnFront.pos.y-theUIOffset]
				spnEnd.pos=[spnEnd.pos.x,spnEnd.pos.y-theUIOffset]
				btnApply.pos=[btnApply.pos.x,btnApply.pos.y+theUIOffset*2]
				btnAdvanced.pos=[btnAdvanced.pos.x,btnAdvanced.pos.y+theUIOffset*2]

				--All flags are enabled and resetted to unchecked
				cbtnPrefix.enabled=true
				cbtnSuffix.enabled=true
				cbtnnumbered.enabled=true
				cbtnTrim.enabled=false --FIX
				cbtnPrefix.state=false
				cbtnSuffix.state=false
				cbtnnumbered.state=false
				cbtnTrim.state=false

				theMainRollout.height = 220
				btnAdvanced.text="-"
			)
			else
			(
				--All controls must be offseted
				cbtnPrefix.pos=[cbtnPrefix.pos.x,cbtnPrefix.pos.y+theUIOffset]
				etPrefix.pos=[etPrefix.pos.x,etPrefix.pos.y+theUIOffset]
				cbtnSuffix.pos=[cbtnSuffix.pos.x,cbtnSuffix.pos.y+theUIOffset]
				etSuffix.pos=[etSuffix.pos.x,etSuffix.pos.y+theUIOffset]
				cbtnnumbered.pos=[cbtnnumbered.pos.x,cbtnnumbered.pos.y+theUIOffset]
				spnFrom.pos=[spnFrom.pos.x,spnFrom.pos.y+theUIOffset]
				spnEvery.pos=[spnEvery.pos.x,spnEvery.pos.y+theUIOffset]
				cbtnTrim.pos=[cbtnTrim.pos.x,cbtnTrim.pos.y+theUIOffset]
				spnFront.pos=[spnFront.pos.x,spnFront.pos.y+theUIOffset]
				spnEnd.pos=[spnEnd.pos.x,spnEnd.pos.y+theUIOffset]
				btnApply.pos=[btnApply.pos.x,btnApply.pos.y-theUIOffset*2]
				btnAdvanced.pos=[btnAdvanced.pos.x,btnAdvanced.pos.y-theUIOffset*2]

				--All flags are disabled
				cbtnPrefix.enabled=False
				cbtnSuffix.enabled=False
				cbtnnumbered.enabled=False
				cbtnTrim.enabled=False

				theMainRollout.height = 110
				btnAdvanced.text="+"
			)
		)

		on NewNameDialog open do
		(
			callbacks.addScript #selectionSetChanged "UpdateObjectCountLabel()" id:#quickRenameCB

			dnToolTip = dotnetobject "System.Windows.Forms.ToolTip"
			dnToolTip.Active = True
			dnToolTip.tooltipicon = (dotnetclass "System.Windows.Forms.ToolTipIcon").None

			dnFfontFam = dotNetObject "system.drawing.fontfamily" "tahoma"
			dnFontStyle = dotNetClass "system.drawing.fontStyle"
			myFont = dotNetObject "system.drawing.font" dnFfontFam 9 dnFontStyle.bold

			dnInfoLabel = dnlbl_SelectionInfo
			dnInfoLabel.width=225
			dnInfoLabel.height=25
			dnInfoLabel.textalign =dnInfoLabel.textalign.MiddleCenter
			dnInfoLabel.font=myFont

			UpdateObjectCountLabel()
		)
		on NewNameDialog close do
		(
			callbacks.removeScripts #selectionSetChanged id:#quickRenameCB
		)

	)

	try(t=windows.getChildHWND 0 "Rename Tool"
	UIAccessor.CloseDialog t[1])catch()

	CreateDialog NewNameDialog width:250 height:110 pos:mouse.screenpos --120
	theMainRollout =NewNameDialog


)

