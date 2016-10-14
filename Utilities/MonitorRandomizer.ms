macroscript MonitorRandomizer
category:"Matanga"

(
	
	--local ScreensPath =
	
	local theMultiMaterial=undefined
	
	local theMaterials=#()
	
	local theScreensPath = undefined
	
	local theTexturesPaths=#()
	local theTexturesNames=#()
	
	
	
	fn GetFilesFromPath thePath theExtension =
	(
		--theFiles = getFiles ((thePath)+"\\*.jpg" )					--Referencio los archivos max demtro del path en el array myProps
		theFiles = getFiles ((thePath)+theExtension )					--Referencio los archivos max demtro del path en el array myProps
		theFiles
	)
	
	function CreateMultiMaterial =
	(
		print "Creating multimaterial"
			theMultiMaterial=MultiMaterial()
			theMultiMaterial.materialList= theMaterials
	)
	
	function CreateMonitorMaterials = 
	(
		print "Creating materials"
		theMaterials=#()
		print( "there  are "+ (theTexturesPaths.count as string) +"textures")
		for o=1 to theTexturesPaths.count by 1 do 
		(
			newMat= VRayMtl()
			newMat.name="MonitorScreen_"+theTexturesNames[o]
			theBitmap=Bitmaptexture()
			theBitmap.filename = theTexturesPaths[o]
			newMat.texmap_diffuse= theBitmap
			showTextureMap newMat newMat.texmap_diffuse on
			append theMaterials newMat
		)
		print theMaterials.count
	)
	
	
	rollout RLT_RandomizeMonitors "Randomize Monitors"
		
	(
		button btnSelectTexturesPath "Select Textures Path"
		
		listbox lbx_TheTextures "The Textures"
		
		button btnApplyMat "apply"
		
		on btnApplyMat pressed do
		(
			for o in selection do
			(
				theNum =random 1 theMaterials.count
				o.material= theMaterials[theNum]
			)

		)
		
		on btnSelectTexturesPath pressed do
		(
			thepath = getSavepath()		
			if(thePath!=undefined) then
			(
				theScreensPath = thePath
			
				theTexturesPaths = GetFilesFromPath theScreensPath "\\*.jpg"
				
				
				
				dotPath = dotNetClass "System.IO.Path"												--Dotnet Object Path
				
				theTexturesNames=#()
				
				for o in theTexturesPaths do												
				(					
					append 	theTexturesNames ( dotPath.GetFileNameWithoutExtension( o))		--Guardo sus nombres en un array
				)
				lbx_TheTextures.items= theTexturesNames
				

				CreateMonitorMaterials()
				CreateMultiMaterial()					
						

			)
			
		)
		
	)
	
	on execute do
	(
		CreateDialog RLT_RandomizeMonitors width:150 height:250
	)
	
	
	-- Step 1 - Select Monitor
	-- Step 2 - Review Instances
	-- Step 3A - Select the submaterial that represents the monitor
	-- Step 3B - Select all the instances
	
	-- Step 4 - Extract & select all monitor screens
	
	-- Step 4 - Choose what random screens to use
	
	--Step 5 - Apply randomly
	
	
	
)