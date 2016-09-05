macroscript LayerUtility
category:"Matanga"
Icon:#("AnimLayerToolbar",2)
(
	local dnInfoLabel
	local dnToolTip

	local allLayers=#()
	local selectionCount="  "+(selection.count as string)+" objects selected"
	
	fn GetAllLayers = 
	(
		allLayers=#() 							--Reseteo el array con los nombres de las layers
		for i = 0 to layerManager.count-1 do
		(
		  ilayer = layerManager.getLayer i
		  append allLayers ilayer.name		---Agregamos el nombre de la layer a la lista de layers
		)	
	)
	GetAllLayers()
	
	fn SendSelectedToLayer theIndex =
	(
		ilayer = layerManager.getLayer theIndex
		for n in (selection as array) do ilayer.addnode n		
	)
	
	fn CreateNewLayerAndAdd theName isHidden isFrozen =
	(
		newLayer = LayerManager.newLayer()
		newLayer.setname theName
		newLayer.isHidden=isHidden
		newLayer.isFrozen=isFrozen
		for n in (selection as array) do newLayer.addnode n
	)
	
	global UpdateSelectionInfoLabel()	--Declare the function as global so we can use it as a callback
	fn UpdateSelectionInfoLabel =		--Redefine the Function
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
		dnInfoLabel.text ="  "+(selection.count as string)+" objects selected"
	)
	
	rollout rltSendToLayer "Send to Layer"
	(
		--DOTNET INFO LABEL
		dotNetControl dnlbl_OriginalName "System.Windows.Forms.Label" width:325 height:20 --create a LABEL DotNetControl

		--SEND TO EXISTING
		label lblLayers "Layers:" across:5 align:#left offset:[0,25]
		dropdownlist ddAllLayers "" items:allLayers align:#left width:110 offset:[-15,22]
		checkbutton cbtnCurrLayerHidden "H" offset:[35,22] tooltip:"Switch Hidden"
		checkbutton cbtnCurrLayerFrozen "F" offset:[10,22] tooltip:"Switch Frozen"
		button btnSendToExisting "Send" align:#left width:55 offset:[0,22] tooltip:"Send selected objects to this layer."
		
		
		--SEND TO NEW
		label lblName "Name:" align:#left  across:5 offset:[0,30]
		editText etNewLayer "" width:110 align:#left  offset:[-17,28]
		checkbutton cbtnNewLayerHidden "H" offset:[35,26] tooltip:"Hidden"
		checkbutton cbtnNewLayerFrozen "F" offset:[10,26] tooltip:"Frozen"
		button btnCreateNewLayer "Create" align:#left offset:[0,26] width:55 tooltip:"Create a new layer with this name and\nsend all selected objects to it."
		
		groupBox groupExisting "Send to Existing" pos:[5,33] width:280 height:50
		groupBox groupNew "Send to New" pos:[5,85] width:280 height:50
		
		on ddAllLayers selected val do
		(
			ilayer = layerManager.getLayer (val-1)
			cbtnCurrLayerHidden.state =ilayer.isHidden
			cbtnCurrLayerFrozen.state =iLayer.isFrozen		
		)
		on cbtnCurrLayerHidden changed val do
		(
			print ddAllLayers.selection
			ilayer = layerManager.getLayer (ddAllLayers.selection-1)
			ilayer.isHidden=val
		)
		on cbtnCurrLayerFrozen changed val do
		(
			ilayer = layerManager.getLayer (ddAllLayers.selection-1)
			ilayer.isFrozen=val
		)
		
		on btnSendToExisting pressed do
		(
			SendSelectedToLayer (ddAllLayers.selection-1)
		)
		on btnCreateNewLayer pressed do
		(
			if(etNewLayer.text!= "") do 
			(
				CreateNewLayerAndAdd etNewLayer.text cbtnNewLayerHidden.state cbtnNewLayerFrozen.state
				GetAllLayers()
				ddAllLayers.items=allLayers
				ddAllLayers.selection=0
				etNewLayer.text=""
				cbtnNewLayerHidden.state=false
				cbtnNewLayerFrozen.state=false
			)
		)		
		
		on rltSendToLayer open do
		(
			callbacks.addScript #selectionSetChanged "UpdateSelectionInfoLabel()" id:#myCallbackID		

			
			dnToolTip = dotnetobject "System.Windows.Forms.ToolTip"
			dnToolTip.Active = True
			dnToolTip.tooltipicon = (dotnetclass "System.Windows.Forms.ToolTipIcon").None

			dnFfontFam = dotNetObject "system.drawing.fontfamily" "tahoma"
			dnFontStyle = dotNetClass "system.drawing.fontStyle"
			myFont = dotNetObject "system.drawing.font" dnFfontFam 9 dnFontStyle.bold

			dnInfoLabel = dnlbl_OriginalName
			dnInfoLabel.width=260
			dnInfoLabel.height=25
			dnInfoLabel.textalign =dnInfoLabel.textalign.MiddleCenter
			dnInfoLabel.font=myFont
			
			
			ilayer = layerManager.getLayer 0
			cbtnCurrLayerHidden.state =ilayer.isHidden
			cbtnCurrLayerFrozen.state =iLayer.isFrozen
		
			UpdateSelectionInfoLabel()
		)
		
		on rltSendToLayer close do
		(
			callbacks.removeScripts #selectionSetChanged id:#myCallbackID
		)		
	)
	
	try(t=windows.getChildHWND 0 "Send to Layer"
		UIAccessor.CloseDialog t[1])catch()
		
	CreateDialog rltSendToLayer width:290 height:140
	
)