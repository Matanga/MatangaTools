macroscript XMLPropImporter
	Category:"Matanga"
(
	local myPropTools = undefined

	local RLTImportProp = undefined
	
	local currentPreview = undefined
	
	local currentMaxPath = undefined
	
	
	 fn PlaceSelectedItem = 
	(		
		
			global thePlane = Plane length:10000 lengthsegs:1 width:10000 widthsegs:1 pos:[0,0,0] isSelected:off name:"plainito" wirecolor:(color 128 128 128)
			myMaterial= StandardMaterial()
			myMaterial.opacity=0
			thePlane.material=myMaterial	
																															
			--DEFINE THE OBJECT TO BE PLACED
			mergemaxfile currentMaxPath  #select #mergeDups #useSceneMtlDups    -- Merge in the objects and select them																																			
			--Declare the global for the tool
			global importedProp =selection[1]	
			global startMousePos= Mouse.pos.x
			global propPlaced=false
			global placeMultiple=false
			global aborted=false

		
			--Run the Tool
			fileIn "\\\\COMPARTIDA\Renderings\Resources\KispTools\Scripts\Props\Tool_PlaceProp.ms"
			--startTool PlaceProp prompt:"Hello!"	

	)  
																																
	
	

	rollout RLTImportProp "Import Prop"
	(
		edittext et_SearchWord "Search:"

		dropdownlist dd_Categories "Categories" items:(myPropTools.GetCategories())	
			
		listbox lbx_Props "Props:" height:5 
		
		dotNetControl uiPictureBox "System.Windows.Forms.PictureBox" offset:[-10,0] width:(200) height:(200)

		button btn_MergeSelected "Merge" width:150 height:35 offset:[0,10]

			
		on dd_Categories selected val do
		(
			if(val != 1) then
			(
				print dd_Categories.items[val]
				props= myPropTools.GetPropByCategory (dd_Categories.items[val])
				
				lbx_Props.items=props
				lbx_Props.selection=0
			)			
		)
		
		--GetPropPreviewPath
		
		on lbx_Props selected val do
		(
			--Update the max path information
				
			currentMaxPath= myPropTools.GetPropMaxPath (lbx_Props.selected)
			print currentMaxPath
			
			--Update the preview image 
			thePreviewPath = myPropTools.GetPropPreviewPath (lbx_Props.selected)			
			bmpDisplayed = dotNetObject "System.Drawing.Bitmap" thePreviewPath 
			uiPictureBox.image = bmpDisplayed
		)	

		on btn_MergeSelected pressed do
		(
			if (currentMaxPath != undefined) do
			(
				PlaceSelectedItem()
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
				t=windows.getChildHWND 0 "Import Prop"
				UIAccessor.CloseDialog t[1]
				)
			catch()

			CreateDialog RLTImportProp width:205 height:430

		)
		catch
		(
			messageBox "KispTools must be running in order to use this tool."
		)
	)	

	
)