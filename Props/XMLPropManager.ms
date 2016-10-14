macroscript XMLPropManager
	Category:"Matanga"
(
	local myPropTools = undefined
	local RLTPropManager = undefined
	

	rollout RLTPropManager "Prop Manager"
	(
		label lblSpc1 ""

		--CATEGORIES
		--CATEGORIES
		--CATEGORIES
		
		edittext et_NewCategory ""  width:100 across:2 offset:[110,0]
		button btn_ChangeCategoryName "Rename" align:#right offset:[0,-3]
		
		dropdownList dd_MoveToCategory "" items:(myPropTools.GetCategories()) width:100 across:2 offset:[110,0]
		button btn_MoveToCategory "Move" align:#right offset:[0,-3] width:55

		button btnDeletedCategory "Remove" offset:[110,0]		
		listbox lb_Categories "" items:(myPropTools.GetCategories()) width:100 offset:[0,-80]	
			
		--PROPS
		--PROPS
		--PROPS
		label lblName "Name:" across:3 offset:[80,25]
		editText etNewName ""  offset:[50,25]
		button btnRename "Rename" offset:[30,23] width:48
			
		label lblIdText  "ID:" 	offset:[50,0] across:2
		label lblIdVal  "05" 	offset:[-55,0]	
			
		label lblMaxFile "Max File:" across:3 offset:[110,0] align:#left
		label lblTheFile "" offset:[65,0] align:#left
		button btnOpenMax "Open" offset:[60,-3] align:#left
				
		label lblIMGFile "Preview:" across:3 offset:[110,0] align:#left
		label lblTheIMGFile "" offset:[65,0] align:#left
		button btnOpenIMG "Display" offset:[55,-3] align:#left
		--dotNetControl uiPictureBox "System.Windows.Forms.PictureBox" offset:[50,0] width:(200) height:(200)
	
		button btnRemove "Remove" width:80 height:30 offset:[50,5]
			
		listbox lbx_Props "" height:10 width:100 offset:[0,-125]
		

			
		--GROUP
		--GROUP
		--GROUP			
		groupBox group1 "Categories" pos:[5,5] width:305 height:155			

		groupBox group2 "Props" pos:[5,170] width:305 height:160			

		on lbx_Props selected val do
		(
			pathClass = dotnetClass "System.IO.Path"
			
			
			etNewName.text= lbx_Props.selected
			
			--Update the max path information				
			currentMaxPath= myPropTools.GetPropMaxPath (lbx_Props.selected)
			cleanedMaxPath = pathClass.GetFilenameWithoutExtension 	currentMaxPath	
			lblTheFile.text = cleanedMaxPath
			
			--Update the preview image 
			thePreviewPath = myPropTools.GetPropPreviewPath (lbx_Props.selected)	
			cleanedPreviewPath = pathClass.GetFilenameWithoutExtension 	thePreviewPath	
			lblTheIMGFile.text = cleanedPreviewPath
			
			--bmpDisplayed = dotNetObject "System.Drawing.Bitmap" thePreviewPath 
			--uiPictureBox.image = bmpDisplayed
		)			
		
		
		
		on btn_ChangeCategoryName pressed do
		(
			if(lb_Categories.selection != 0 and et_NewCategory.text != " " )do
			(
				myPropTools.ChangePropCategory lb_Categories.selected et_NewCategory.text
				--Reset the UIAccessor
				lbx_Props.items=#("")
				dd_MoveToCategory.items = myPropTools.GetCategories()
				lb_Categories.items = myPropTools.GetCategories()
				et_NewCategory.text=""
			)
			
		)
			
		on btn_MoveToCategory pressed do
		(
			if(lb_Categories.selection != 0 and dd_MoveToCategory.selection != 0)do
			(
				myPropTools.ChangePropCategory lb_Categories.selected dd_MoveToCategory.selected
				--Reset the UIAccessor
				lbx_Props.items=#("")
				dd_MoveToCategory.items = myPropTools.GetCategories()
				lb_Categories.items = myPropTools.GetCategories()
			)
			
		)
			
		
		on lb_Categories selected val do
		(
			if(val != 1) then
			(
				props= myPropTools.GetPropByCategory (lb_Categories.items[val])
				
				lbx_Props.items=props
				lbx_Props.selection=0
			)			
		)
		
	

		
	)
	

	on execute do
	(
		try
		(
			myPropTools		= globalVars.get #PropDBUtilsStruct
			
			t=undefined			
			try(
				t=windows.getChildHWND 0 "Prop Manager"
				UIAccessor.CloseDialog t[1]
				)
			catch()

			CreateDialog RLTPropManager width:315 height:370

		)
		catch
		(
			messageBox "KispTools must be running in order to use this tool."
		)					
	)		
)