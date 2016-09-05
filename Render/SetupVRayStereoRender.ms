macroScript SetupVRayStereoCamera
category:"Matanga"
tooltip:"Setup VRay Stereo"
(	
	function RemoveStereoHelpers =
	(
		newColl = for o in Helpers where (classof o == VRayStereoscopic) collect o		
		for m in newColl do delete m		
	)		
	
	function SetupNormal =
	(
		RemoveStereoHelpers()
		
		renderSceneDialog.close()
		renderWidth = 1920
		renderHeight = 1080	
		vr=renderers.current
		vr.camera_type=0	
	)
	
	function SetupStereo =
	(
		RemoveStereoHelpers()
		
		myVREStereoHelper = VRayStereoscopic pos:[0,0,0] isSelected:off
		myVREStereoHelper.enabled= true
		myVREStereoHelper.adjust_resolution=true
		myVREStereoHelper.eye_distance= units.decodeValue "65mm"
		renderSceneDialog.close()
		renderWidth = 1536*6
		renderHeight = 1536	
		vr=renderers.current
		vr.camera_type=10
	)

	rollout RLTExists "Stereoscopic Setup"
	(
		label lbl_Explanation "A Stereoscopic Helper already exists!" align:#left
		label lbl_Space "" align:#left height:10
		
		button btn_BackToNormalRender "Normal Mode"     width:200 height:35 tooltip:"If pressed scene will go back to default mode.\nResolution will be set to 1920*1080\nAll existing Stereoscopic helpers will be deleted."
		button btn_StereoscopicMode "Stereoscopic Mode" width:200 height:35 tooltip:"The scene will be reseted, all existing Stereoscopic helpers will be removed.\nand replaced with new ones."
		
		on btn_BackToNormalRender pressed do
		(
			SetupNormal()
			DestroyDialog RLTExists
		)
		on btn_StereoscopicMode pressed do
		(
			SetupStereo()
			DestroyDialog RLTExists
		)
		
	)	
	
	helperFound= false
	for o in Helpers where (classof o == VRayStereoscopic) do helperFound =true	

	
    if helperFound == false then SetupStereo()						   
	else
	(
		try(t=windows.getChildHWND 0 "Stereoscopic Setup"
		UIAccessor.CloseDialog t[1])catch()
		CreateDialog RLTExists width:220 height:120
	)	
	
	
)