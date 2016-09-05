macroscript CreateLightCacheMap
category:"Matanga"
(
	local oldPrimaryEngine		--Reference to the previous Primary GI Type
	local currRenderer			--A Reference to the currently used Renderer
	local thePath				--The filename/path of the lightCache that will be created
		
	global DoPostRenderStuff()
	fn DoPostRenderStuff = --Define the Function
	(			
		callbacks.removeScripts #postRender id:#postRender
		
		--Disable distributed rendering
		currRenderer.system_distributedrender= true

		--Disable Render Final Image 
		currRenderer.options_dontRenderImage=false
		
		--Restore previous VRay settings
		currRenderer.gi_primary_Type=oldPrimaryEngine
		
		--Set Vray to render light cache from Path
		currRenderer.lightCache_mode=2
		currRenderer.lightcache_loadFileName=thePath		
	)		

	function SetupVrayforLightCacheMap =
	(
		--Disable distributed rendering
		currRenderer.system_distributedrender= false

		--Disable Render Final Image 
		currRenderer.options_dontRenderImage=true
		
		--Configure light cache
		
		currRenderer.lightcache_autoSave =true			
		currRenderer.lightcache_autoSaveFileName = thePath
		currRenderer.lightcache_switchToSavedMap = true
		
		--vr.lightcache_ui_view=1

		oldPrimaryEngine=currRenderer.gi_primary_Type
		currRenderer.gi_primary_Type=3
	)
	
	function GetLightCacheMapSavePath =
	(
		--Create the save path for the light cache map
		theBase=maxFilePath
		--Convert tha path to UNC 
		theBase=pathConfig.convertPathToUnc theBase
		--print theBase
		
		dnPath=dotnetclass "System.IO.Path"
	
		--theName=maxFileName
		
		theName =dnPath.getfilenamewithoutextension maxFileName

		theFinalName ="\\"+theName+".vrlmap"
		
		
		returnPath= theBase+theFinalName
		
		print returnPath

		returnPath			
	)		
		
	on execute do
	(
		--First of all we add a callback function to the #postrender event
		callbacks.addScript #postRender "DoPostRenderStuff()" id:#postRender
		
		--Get the current renderer
		currRenderer= renderers.current
		--Check if the current renderer is any version of Vray
		theName = currRenderer as string
		check= findString theName "V_Ray"
		isVray=false	
		if(check!= undefined) then isVray=true
							  else messageBox "Vray is not set as the renderer"
		
		--Check if GI is enabled and if Light cache is set to the secondarry engine
		giON=false
		lightCacheOn=false
		
		if(currRenderer.gi_on== false)do
		(
			messageBox "GI is not enabled! It will be enabled now."
			currRenderer.gi_on=true
		)
		if(currRenderer.gi_secondary_Type != 3 ) do
		(
			messageBox "Light Cache is not set as the secondary engine!"
			currRenderer.gi_secondary_Type= 3
		)	

		
		thePath=GetLightCacheMapSavePath()

		SetupVrayforLightCacheMap()
		

		
		
		Render()			
		
	)
)