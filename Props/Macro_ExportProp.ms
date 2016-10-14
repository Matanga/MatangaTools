macroscript ExportPropV1
	category:"Matanga"
(		
	local myPropTools
	
	------------------------------------------------------------------------------------------------------------------
	--
	--	PROP TOOLS ROLLOUTS 
	--	PROP TOOLS ROLLOUTS 
	--	PROP TOOLS ROLLOUTS 
	--
	------------------------------------------------------------------------------------------------------------------
	global creatingPropScreenshot =undefined
	global theTimer = undefined
	
	local RLTAddProp =undefined
	
	
	--THE PROP
	local newProp= undefined
	local allSubObjects= undefined
	
	--The original transform of the prop for restoring its value after the process is done
	local originalTransform=undefined
	
	--The preview Image
	local thePreviewImage = undefined
	
	--Flag to know if the process has been finished 
	local processDone=false
	
	--The Path where all props should be stored
	local serverPath = "\\\\COMPARTIDA\\Renderings\\Resources\\KispTools_Props\\AllProps"	
	
	
	--EXPORT VALUES
	--EXPORT VALUES
	
	local propName=undefined
	local propCategory = undefined
	
	local propFilePath=undefined
	local previewFilePath= undefined
	

	---------------------------------------------------
	--
	--	UTILITY METHODS
	--	UTILITY METHODS
	--
	----------------------------------------------------
	
	local GetGroupParent()
	
	function GetGroupParent theChild =
	(
		theParent= theChild.parent
		
		if (isGroupMember theParent) then theParent = GetGroupParent theParent
		
		theParent
	)

	/************************************
		USE:Returns a centered cropped version of the provided Bitmap
		ARGUMENTS : theBitmap = the bitmap that we want to crop
					size = the height and width values we want the returned image to have
	*/
	fn CropImage theImg size =
	(		
		--theImg = getclipboardBitmap()
		theImg= theImg as bitmap
		
		--Define the Coordinates for the cropping
		srcW=theImg.width/2-(size/2)
		srcH=theImg.height/2-(size/2)

		--Create the new image
		theTemImg=bitmap size size color:white --filename:newTempName
		theTemImg.gamma =2.2
		
		pasteBitmap theImg theTemImg (box2  srcW srcH size size) [0,0]	--src dest	 
		
		theTemImg
	)	
	
	function TakeScreenshot =
	(	
		if ( creatingPropScreenshot==true ) then
		(			
			if (img!= undefined) do img=undefined
			img = gw.getViewportDib()
			setclipboardBitmap img

			img = CropImage (getclipboardBitmap()) 200
			
			setclipboardBitmap img
			
			--DisplayClipBoardImage()
			clipboardClass = dotNetClass "System.Windows.Forms.Clipboard"				
			
			RLTAddProp.uiPictureBox.image = clipboardClass.getImage()
		)
		else
		(
			theTimer.stop()	
		)

	)
	
	function StartScreenshotTimer =
	(
		theTimer = dotNetObject "System.Windows.Forms.Timer"
		dotnet.addEventHandler theTimer "tick" TakeScreenshot
		theTimer.interval = 100
		theTimer.start()
	)
	
	--LEGACY METHOD
	--LEGACY METHOD
	--LEGACY METHOD
	function TakeScreenshot2 =
	(	
		if (img!= undefined) do img=undefined
		img = gw.getViewportDib()
		setclipboardBitmap img

		img

	)	
	
	fn AddChildrenToArray theChildren currentObjsToExport =
	(
		for c in theChildren do
		(
			append currentObjsToExport c
			addChildrenToArray c.children currentObjsToExport
		)
	)
	
	function PrepareProp theProp =
	(
		--Find out if the node belongs to a group and if so go up the hierarchy until the uppermost parent is found
		inGroup=undefined
		if(isGroupMember theProp) 	then inGroup = true
									else inGroup = false
		
		if(inGroup) then theProp= GetGroupParent theProp
		
		--If the node was part of a group now check if the group is open and close it if it isnt
		if( isOpenGroupHead  theProp) then setGroupOpen theProp false
		
		--Store the Original Transform and prop
		newProp=theProp
		originalTransform=newProp.transform

		--Reset the transform (position, rotation, scale) of the prop
		newProp.transform =matrix3 1		
				
		--Isolate Selected Nodes
		select newProp
		allSubObjects = #(newProp)
		if(newProp.children.count != 0 ) then
		(
			addChildrenToArray newProp.children allSubObjects			
		)
		print allSubObjects
			
		IsolateSelection.EnterIsolateSelectionMode()
		
		--Close the listener--UNEXPECTED BEHAVIOUR
		uiaccessor.closedialog (windows.getchildhwnd 0 "MAXScript Listener")[1]
		
		--Clear selection to make getting the preview faster
		clearselection()			
	)
	
	
	/************************************
		USE: Method that saves the max file with the selected prop
	*/
	function SavePropFile =
	(
		saveNodes allSubObjects propFilePath quiet:true	
	)
	/************************************
		USE: Method that saves the preview image for the prop
	*/
	function SavePreview =
	(
		theImg = getclipboardBitmap()			
		oldGamma= FileOutGamma
		FileOutGamma =1.0			
		theImg.filename = previewFilePath
		save theImg quiet:true 
		close theImg
		FileOutGamma = oldGamma
	)
	/************************************
		USE: Method that follows all the necessary steps to add a new prop to the server and the database
	*/
	function StartSavePropProcess =
	(
		--Save Max File		
		propID= myPropTools.GetNextID() 
		
		propFilePath = serverPath+"\\"+propID+"_"+propName+".max"
		SavePropFile()
		
		--Save Preview File
		previewFilePath = serverPath+"\\"+propID+"_"+propName+".jpg"			
		SavePreview()
		
		--Update XML
		myPropTools.AddProp propName propCategory propFilePath previewFilePath
		
	)
	
	
	---------------------------------------------------
	--
	--	UI METHODS
	--	UI METHODS
	--
	----------------------------------------------------

	function EnableStep2UI =
	(
		RLTAddProp.btn_GetProp.enabled=false
		RLTAddProp.btn_CommitScreenshot.enabled=true
		RLTAddProp.et_PropName.text=newProp.name

		--Further testing is needed on this method to check for errors and compatibility
		StartScreenshotTimer()
	)	
	function EnableStep3UI =
	(			
		--btn_TakeScreenshot.enabled=false
		RLTAddProp.btn_CommitScreenshot.enabled=false
		RLTAddProp.et_PropName.enabled=true
		RLTAddProp.dd_Category.enabled=true
		RLTAddProp.et_NewCategory.enabled=true
	)	
	function AddCategoryToList =
	(
		if queryBox "Please avoid adding unnecessary or redundant categories.\n Continue?" beep:true then
		(				
			--Copy the exisiting categories
			newItems=RLTAddProp.dd_Category.items
			--Add the new category to the new list
			append newItems (RLTAddProp.et_NewCategory.text)
			--Set the new list as the dropdownlist list
			RLTAddProp.dd_Category.items= newItems
			--Select the last item wich will be the new category
			RLTAddProp.dd_Category.selection=RLTAddProp.dd_Category.items.count
			--Disable the add category button
			RLTAddProp.btn_AddCategory.enabled=false
			--Clear the edittext text
			RLTAddProp.et_NewCategory.text=""
			--Disable the new category editText
			RLTAddProp.et_NewCategory.enabled=false
		)
		else
		(
			--Disable the add category button
			RLTAddProp.btn_AddCategory.enabled=false
			--Clear the edittext text
			RLTAddProp.et_NewCategory.text=""
			--Disable the new category editText
			RLTAddProp.et_NewCategory.enabled=true
		)
	)
	
	
	rollout RLTAddProp "Add Prop"
	(
		---------------
		--STEP 1 -- SELECT PROP
		--STEP 1 -- SELECT PROP
		---------------
		label lbl_Step1 "Step 1 - Pick Object from Scene"
		label lbl_Step1Info "Poner el pivot del prop/grupo en el lugar donde luego va a ser apoyado. Base para sillas, mesas, muebles. Atras para pizarrones, etc. " offset:[5,0] height:70 width:185 style_sunkenedge:true align:#right
		
		button btn_GetProp "Select Prop" width:150 height:30 
		
		
		---------------
		--STEP 2 -- CREATE PREVIEW
		--STEP 2 -- CREATE PREVIEW
		---------------
		label lbl_Step2 "Step 2 -Create Preview" offset:[0,15]
		label lbl_Step2Info "Acomodar la camara en una posicion que mejor represente al prop y presionar `Commit` para elegir el preview" offset:[5,0] height:70 width:185 style_sunkenedge:true align:#right
		
		dotNetControl uiPictureBox "System.Windows.Forms.PictureBox" offset:[-10,0] width:(200) height:(200)
		--button btn_TakeScreenshot "Take Screenshot" across:2 enabled:false
		button btn_CommitScreenshot "Commit" enabled:false

		---------------
		--STEP 3 -- PROP DATA
		--STEP 3 -- PROP DATA
		---------------	
		
		label lbl_Step3 "Step 3 - Prop Info" offset:[0,15]

		label lb_nameTitle "Name:" align:#left across:2
		editText et_PropName "" width:120 offset:[-33,0] enabled:false
		label lb_categoryTitle "Category:" across:2 align:#left
		dropdownlist dd_Category ""   items:(myPropTools.GetCategories()) align:#left offset:[-30,-3] width:120 enabled:false

		button btn_AddCategory "Add Cat." align:#left across:2 offset:[-3,0] enabled:false
		EditText et_NewCategory ""  align:#left  width:120 offset:[-33,3] enabled:false


		---------------
		--STEP 4 -- PROP DATA
		--STEP 4 -- PROP DATA
		---------------	
		
		button btn_SaveProp "Save" width:150 height:50 offset:[0,10]
		
		
		on btn_SaveProp pressed do
		(
			--Check if a prop with the same name already exists
			if( myPropTools.IsPropNameUnique et_PropName.text == false ) then
			(
				messageBox "A prop with the same name already exists. This may cause issues. Please change the name."	
			)else
			(
				propName=et_PropName.text
				propCategory= dd_Category.selected 
				StartSavePropProcess()
			)
		)
		
		----------------
		--EVENTS
		--EVENTS
		----------------
		
		on btn_GetProp pressed do 
		(
			--Get the new prop from the scene
			newProp = PickObject()
			if(newProp != undefined) then
			(
				--Setup the Picked Prop
				PrepareProp newProp
				--Enable the UI for the second step
				EnableStep2UI()					
			)			
		)
		--OLD METHOD OF GETTING THE SCREENSHOT
		--OLD METHOD OF GETTING THE SCREENSHOT
		--OLD METHOD OF GETTING THE SCREENSHOT
		/*
		on btn_TakeScreenshot pressed do
		(
			--Take a ScreenShot of the current Active viewport
			thePreviewImage = TakeScreenshot()
			thePreviewImage = CropImage (getclipboardBitmap()) 200
				
			setclipboardBitmap thePreviewImage
	
			--DisplayClipBoardImage()
			clipboardClass = dotNetClass "System.Windows.Forms.Clipboard"
			uiPictureBox.image = clipboardClass.getImage()
				
			--DisplayImage tempImgPath
			if(btn_CommitScreenshot.enabled==false)then btn_CommitScreenshot.enabled=true
		)
		*/
		on btn_CommitScreenshot pressed do
		(
			--This is to stop the SCREENSHOT UPDATER
			creatingPropScreenshot=false
			--Update the UI to continue with the next step
			EnableStep3UI()			
		)
		
		on et_NewCategory changed val do
		(
				if(val=="") then btn_AddCategory.enabled=false
							else btn_AddCategory.enabled=true
		)
		
		on btn_AddCategory pressed do
		(
			AddCategoryToList()
		)
		
		
		
		
		on RLTAddProp open do
		(
			creatingPropScreenshot=true
		)
		
		on RLTAddProp close do
		(
			creatingPropScreenshot=false
			if(processDone==false and originalTransform != undefined) do
			(
				newProp.transform = originalTransform
			)
		)		
		
	)
	

	
	on execute do
	(
		try
		(
			myPropTools		= globalVars.get #PropDBUtilsStruct
			
			t=undefined
			
			try(t=windows.getChildHWND 0 "Add Prop")catch()
			
			if(t==undefined) then 
			(
				CreateDialog RLTAddProp width:200 height:650
			)
			else
			(
				messageBox "You can only create one prop at a time master. Calm your titties."
			)
		)
		catch
		(
				messageBox "KispTools must be running in order to use this tool."
		)
	)
)













