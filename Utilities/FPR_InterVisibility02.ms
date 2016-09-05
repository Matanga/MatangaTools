macroscript CreateViewData
category:"Matanga"
(
	--All selected views to process
	local theViews=#()

	--This Array will hold all valid Links
	local validLinks=#()	
	local allFPRLinks =#()
	
	local validConnections  = undefined

	--The obstacles between the currently selected nodes
	local debugLine  = undefined
	local currentObstacle=undefined

	--The Rollouts References
	local RLTSelectViews = undefined
	local RLTViewsConfig = undefined
	local RLTDebugViewsConnection = undefined
	local RLTScreenSpaceDebug = undefined
	local RLTExport = undefined
	local AddScreenSpaceLink = undefined

	local RLTDebugViewLinks = undefined				


	--ScreenSpace Link Creation
	local previousViewportType = undefined
	local previousViewportMatrix = undefined
	local theHelperCamera = undefined


	--PRE DEFINED METHODS
	global PrintCameraRotation()		--This one is global because it is used by a callback
	local GetRelativePosCoord()
	local GetScreenCoord()
	local CreateViewLinkDebugRollout()
	local GetRayIntersectResults()
	local GetIsOcluded()
--------------------------------------------
--STRUCTS
--STRUCTS
--STRUCTS
--STRUCTS
--------------------------------------------
	struct FPRLink
	(
		myViewName= undefined,
			
		myType=undefined, 		--FPR, url, image.
	
		--Screen Space Variables
		myCoordSys= undefined,	--Can be 	"Screen" 	or	 "World"
		
		--Screen Space Variables
		myCoords=undefined,		--When the coord
		
		
		--LINK OPTIONS
		vreUrl=undefined,		--URL of the vre u
		fprURL=undefined,		--URL of the fpr
		
		linkIndex=undefined,	--The index of the link
		linkURL =undefined,		--The url of the link
		
		-------------------------------------------
		--Draw A Debug Spline shape
		-------------------------------------------
		function Debug =
		(
			print ("--DEUGGING FPR" + myViewName)
			print( "Type: "+  myType as string)
			print( "Coord. Sys: " +myCoordSys)
			print( "My coords: " +myCoords as string)
			--print( "Vre Url: " +vreUrl as string)
			--print( "FPR Url: " +fprUrl as string)
			--print( "Link Index: " +linkIndex as string )
			--print( "Link Url : " +linkURL as string)
			print ("--FINISHED FPR"+"\n")
		)	
		
	)
	----------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--Method that returns an FPRLink
	----------------------------------------------------------------------------------------------------------------------------------------------------------------------
	function CreateAllFPRLinks coordSyst =
	(
		free allFPRLinks		
		
		for o in validLinks do
		(	
			--Create new link, name it and configure it
			newFPR = FPRLink()			
			newFPR.myType= "FPR Link"			
			newFPR.myViewName= o[1].name			
			newFPR.myCoordSys = coordSyst
			
			--Get the actual coordinate based on the selected method  appropiate 
			--There can be 2 modes WORLD and SCREEN. Both are represented by a Vector·
			--In the WORLD configuration the vector represents the position of the second object of the 
			--array using the first object as an origin. 
			if(coordSyst== "world") do newFPR.myCoords= GetRelativePosCoord o
			--In the SCREEN configuration the X and Y axes are angles that  give a coordinate in a 3d Sphere
			-- the Z axis is used to store the distance at which the second object is from the first object.			
			if(coordSyst=="screen") do newFPR.myCoords="w"
			
			append allFPRLinks newFPR
		)
		
	)

--------------------------------------------
--METHODS
--METHODS
--METHODS
--METHODS
--------------------------------------------
	
----------------
--EXPORT
--EXPORT
--EXPORT
----------------	
	-------------------------------------------------------------
	--Working XML Exporter Test Method
	---------------------------------------------
		function ExportWorld =
		(
			clearListener()

			--Create a new XML file
			xDoc = XMLDocument() --Create a new XMLDocument
			xDoc.file = "C:\\users\\asinf\\Desktop\\Temp.xml" --Set the file for the document, this would be set if we were using LoadXML() SEE BELOW
			xDoc.loaded = True --Set loaded to True, this would be set if we were using LoadXML() SEE BELOW
			rNode = xDoc.getNewNode "VRE" --Create a new XMLNode THIS MUST BE CALLED!
			xDoc.AppendNode rNode --Append the new node the XMLDocument
			rNode.AddAttribute "VRE_URL" "theURL" --Add Attribute
			rNode.AddAttribute "Name" "theName" --Add Attribute

			
			print theViews.count
			for o in theViews do
			(
				viewNode = xDoc.getNewNode "FPR" --Get a new Node
				viewNode.AddAttribute "Name" (o.name)
				rNode.AppendNode newNode --Append a new Node
				
				posNode = XDoc.getNewNode  "WorldPos"
				viewNode.AppendNode posNode
				posNode.SetText (o.pos as string)
				
				indexLinkNode= XDoc.getNewNode "Index_Link"
				indexLinkNode.AddAttribute "Type" "worldSpace" --Add Attribute
				indexLinkNode.AddAttribute "FPR_index" "theIndex" --Add Attribute
				viewNode.AppendNode indexLinkNode

				urlLinkNode =XDoc.getNewNode "URL_Link"
				indexLinkNode.AddAttribute "Type" "worldSpace" --Add Attribute
				urlLinkNode.AddAttribute "VRE_URL" "theUrl" --Add Attribute
				urlLinkNode.AddAttribute "FPR_URL" "theUrl" --Add Attribute			
				viewNode.AppendNode urlLinkNode

				
				
				rNode.AppendNode viewNode
			)

			xDoc.SaveXML() --Save XML
			xDoc.PrettySaveXML() --Saves well formed XML

		)	
----------------
--DEBUG
--DEBUG
--DEBUG
----------------
	------------------------------------------------------------------------------------------------------------------------------
	--Takes the necessary steps for the creation of a ScreenSpace Linkç
	--1- Store the current transform of the active viewport camera. and the active viewport.activeViewport.
	--2- Create a camera in the position of the selected camera,
	--3- Change the active viewport to the new camera
	------------------------------------------------------------------------------------------------------------------------------
		function SetupScreenSpaceLinkCreation =
		(		
			--Store current settings
			previousViewportType=viewport.getType()			
			previousViewportMatrix =viewport.getTM()	
			
			--Get the currently selected view
			theNode=theViews[RLTScreenSpaceDebug.ddScreenSpaceAllViews.selection]
			
			--Create and setup the helper camera and the selected view position
			theHelperCamera = Freecamera fov:45 targetDistance:160 nearclip:1 farclip:1000 nearrange:0 farrange:1000 mpassEnabled:off mpassRenderPerPass:off pos:theNode.pos isSelected:off
			theHelperCamera.transform.rotation=theNode.transform.rotation			
			theHelperCamera.transform = theNode.transform
			theHelperCamera.name="HelperCamera"									
			theHelperCamera.isHidden=true
--			setTransformLockFlags theHelperCamera #all
			
			
			viewport.setCamera theHelperCamera
		)		
	--------------------------------
	--Draw A Debug Spline shape
	---------------------------------
		fn DebugDrawLineBetweenTwoPoints pointA pointB =
		(
			if(debugLine!= undefined) do delete debugLine
			debugLine = SplineShape pos:pointA.pos
			debugLine.wirecolor= red
			addNewSpline debugLine
			addKnot debugLine 1 #corner #line PointA.pos
			addKnot debugLine 1 #corner #line PointB.pos
			updateShape debugLine
		)	
	----------------------------------------------------------
	--Debugs the obstacles  between views
	----------------------------------------------------------
	function DebugViewConnection theLinks =
	(
		if(RLTDebugViewsConnection.cbDebugLine.state==true) do DebugDrawLineBetweenTwoPoints theLinks[1] theLinks[2]
		--This variable will store the reference to the obstacle if one exists
		theObstacle=undefined
		--Get a list of all objects that are in the path of the ray that we get based on the positions of this two nodes
		theIntersects= GetRayIntersectResults theLinks
		--If there are any objects on the Array	
		if( theIntersects.count!=0) do
		(
			theObstacle=GetIsOcluded theIntersects theLinks
		)
		if(theObstacle!=undefined) then
		(
			currentObstacle=theObstacle
			RLTDebugViewsConnection.btnSelectFirstObstacle.text=currentObstacle.name
		)
		else
		(
			currentObstacle=undefined
			RLTDebugViewsConnection.btnSelectFirstObstacle.text=""
		)
	)
----------------
--MAIN
--MAIN
--MAIN
----------------	
	------------------------------------------------------------------------------------------------------------------------
	--Methods that receives an array consisting of two nodes. it then creates a ray starting from the first
	--object going to the second and returns all the objects in the scene that are in the path of that ray
	--Note that this returned objects are not necessarily obstacles since they could just be objects that are
	--in the path of the ray but much further away than the distance between 2 views
	--theArray= Array of two nodes, [fromNode,toNode]
	------------------------------------------------------------------------------------------------------------------------
		function GetRayIntersectResults theArray =
		(
			--First calculate the direction of the Ray
			thedir= theArray[2].pos-theArray[1].pos
			--Create the Ray
			theRay = ray theArray[1].pos thedir
			--Create the intersect data
			intersect = intersectRayScene theRay
			--for o=1 to intersect.count by 1 do(if( intersect[o][1] != theArray[1] and intersect[o][1] != theArray[2] ) do print intersect[o][1].name)
			--Return the Array with the info
			intersect
		)
	------------------------------------------------------------------------------------------------------------------
	--Methods that returns the first obstacle between two nodes or undefined if none
	--intersectObjects = the intersect array
	--theNodes = array with the fromNode and the toNode
	------------------------------------------------------------------------------------------------------------------
		function GetIsOcluded intersectObjects theNodes =
		(	
			closestObstacle=undefined
			--print ("The connection index is "+ theIndex as string)			

			theViewDist= distance theNodes[1] theNodes[2]				

			theIndex=0
			theMinDist=100000
			
			for obstacle in intersectObjects do
			(				
				rm = RayMeshGridIntersect () --create an instance of the Reference Target
				rm.Initialize 1 --init. the voxel grid size to 10x10x10
				
				rm.addNode obstacle[1]		--Agrego uno solo por que la pagina dice que igual este parametro no trabajo con todo el array sino con solo el primero
			
				rm.buildGrid () --build the grid data (collecting faces into the grid voxels)				

				thedir= theNodes[2].pos-theNodes[1].pos		
				theHitsCount = rm.intersectRay theNodes[1].pos thedir false 
				theClosestHitIndex = rm.getClosestHit () --get the index of the closest hit by the ray
				theObjDist = rm.getHitDist theClosestHitIndex --get the face index corresponding to that indexed hit
				
				--print ( theViewDist as string+ " View Dist/"+theObjDist as string+ " object Dist")					
				if (theObjDist<= theViewDist) do 
				(				
					if(theObjDist < theMinDist) do
					(	
						closestObstacle=obstacle[1]
						theMinDist= theObjDist
					)
				)				
			)		
			closestObstacle
		)		
	------------------------------------------------------------------------
	--Methods that Gets all the possible connections
	------------------------------------------------------------------------
		function CalculateAllLinks =
		(
			free validLinks

			--Get all connections, from every view to every other view, all connections are repeated ( both directions )
			--This can be fixed later on to save memory
			for o in theViews do
			(
				for x in theViews do if(o != x) do
				(
					--print ("testing from "+ o.name+" to "+x.name)
					isValid=true
					
					--Check MIN  and MAX CONDITIONS
					--THIS SHOULD BE TESTED FOR MAX UNITS SETUP
					if(RLTViewsConfig.useMin.state==true or RLTViewsConfig.useMax.state==true )do
					(
						--print("Using distance threshold")
						theDistance= distance o x 
						if(RLTViewsConfig.useMin.state==true)do
						(
							--print("using min")
							if(RLTViewsConfig.spnMinDist.value> theDistance) do isValid=false
						)
						if(RLTViewsConfig.useMax.state==true)do
						(
							--print("using max")
							if(RLTViewsConfig.spnMaxDist.value< theDistance) do isValid=false
						)
					)
					--Check for Obstacles
					if(RLTViewsConfig.cbIgnoreWalls.state ==false) do
					(
						theObstacle=undefined
						--Get a list of all objects that are in the path of the ray that we get based on the positions of this two nodes
						theIntersects= GetRayIntersectResults (#(o,x))
						--If there are any objects on the Array	
						if( theIntersects.count!=0) do
						(
							theObstacle=GetIsOcluded theIntersects (#(o,x))
						)
						if(theObstacle!=undefined) do isValid=false
					)
					if(isValid==true)do append validLinks (#(o,x))
				)
			)
			print ("there are a total of "+validLinks.count as string +" valid links.")
			for o in validLinks do print (o[1].name +"--"+o[2].name)
		)


		function GetCorrectedDir =
		(
			theObj=$
			newObj=Box()
			newObj.pos=theObj.pos
			newObj.dir=theObj.dir
			print theobj.dir
			oldDir=theObj.dir
			oldDir.z=0
			newObj.dir=oldDir

			$.rotation as eulerangles

		)
--------------------------------------------
--UI
--UI
--UI
--UI
--------------------------------------------
		
	----------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--Method that is attached to the ChangeViewport Callback. Is used to update the Create ScreenSpace Link Rollout
	----------------------------------------------------------------------------------------------------------------------------------------------------------------------
		function PrintCameraRotation =
		(
			theRotation=theHelperCamera.transform.rotation as EulerAngles
			AddScreenSpaceLink.lblEulerX.text ="X: "+ theRotation.x as string 
			AddScreenSpaceLink.lblEulerY.text ="Y: 0 "
			AddScreenSpaceLink.lblEulerZ.text ="Z: "+ theRotation.z as string 
		)
	------------------------------------------------------------------------------------------------------------------------------
	--Updates the ScreenSpace Link Configuration Rollout  
	------------------------------------------------------------------------------------------------------------------------------
		function UpdateScreenSpaceOptions =
		(
			RLTScreenSpaceDebug.ddScreenSpaceAllViews.items=for o in theViews collect o.name
			RLTScreenSpaceDebug.ddScreenSpaceAllViews.selection =0
		)
	-------------------------------------------
	-- When FPR Links are calculated this method is in charge of initializing the Subrollout that debugs worldSpace links
	-------------------------------------------
		function EnableWorldSpaceDebug =
		(
				RLTDebugViewsConnection.fromNode.enabled=true
				RLTDebugViewsConnection.toNode.enabled=true
				RLTDebugViewsConnection.fromNode.items=( for o in theViews collect o.name)
				RLTDebugViewsConnection.fromNode.selection=0
				RLTDebugViewsConnection.toNode.items=( for o in theViews collect o.name)
				RLTDebugViewsConnection.toNode.selection=0
		)
	------------------------------------------------
	-- Rollout to examine View Links
	------------------------------------------------
		function GetValidConnectionNames =
		(
			theItems=#()
			for o in validLinks do append theItems (o[1].name+"---"+o[2].name)				
			theItems
		)
	------------------------------------------------------------------------------------------------
	--Returns the relative position of a node in relation to another node
	--theNodes= An array of 2 nodes the fromNode and the toNode
	------------------------------------------------------------------------------------------------
		function GetRelativePosCoord theNodes =
		(
			relativePos= theNodes[2].pos-theNodes[1].pos
			relativePos
		)
	------------------------------------------------------------------------
	--Returns a vector 3 rounded to 1 decimal place
	------------------------------------------------------------------------
		function GetRoundedVector3 theVector =
		(
			newVector= [0.0,0.0,0.0]
			newVector.x = floor(10 * theVector.x) / 10
			newVector.y = floor(10 * theVector.y) / 10
			newVector.z = floor(10 * theVector.z) / 10
			newVector
		)
----------------------------
-- ROLLOUTS
-- ROLLOUTS
-- ROLLOUTS
----------------------------
	---------------------------
	--MAIN ROLLOUT
	---------------------------
		rollout RLTMainRollout "Calculate Views Connections"
		(
			subrollout SRLTChooseViews "Project Name"


			on RLTMainRollout close do
			(
				if(debugLine!= undefined) do delete debugLine
			)
		)		
	-----------------------------------------------------------------------------
	--Rollout to select the Views that we want to process
	-----------------------------------------------------------------------------
		rollout RLTSelectViews "Step 1 - Select Views"
		(
			multilistbox objectsToView "Views:" items:(for o in theViews collect o.name) width:130 --pos:[10,10]
			pickButton pckbtnSingle "Add Single" tooltip:"Individually choose Views" width:65 across:4 pos:[145,25]
			Button pckbtnMultipleObject "Add Multiple" tooltip:"Choose multiple Views" width:65 pos:[145,50]
			button btnAddAllCams "Add Cams" tooltip:"Add all existing scene cameras" width:65 pos:[145,75]
			button btnRemoveSelected "Remove" tooltip:"Remove Selected Views from list" width:65 height:40 pos:[145,115]

			on pckbtnSingle picked val do
			(
				appendIfUnique theViews val
				
				RLTSelectViews.objectsToView.items=( for o in theViews collect o.name)
				UpdateScreenSpaceOptions()
			)
			on pckbtnMultipleObject pressed do
				(
					--This will holde the selected objects
					theObj=PickObject()
					while (theObj != undefined)do
					(
						--Add the selected object
						appendIfUnique theViews theObj
						--Refresh the list
						objectsToView.items=( for o in theViews collect o.name)
						--Refresh the ScreenSpace options List
						UpdateScreenSpaceOptions()
						--Reset the object holder
						theObj=undefined
						--Attempt to select a new object
						theObj=pickObject()
					)
			)
			on btnAddAllCams pressed do
			(
				--print Cameras.count
				for o in Cameras where classof o != TargetObject do appendIfUnique theViews o
				
				RLTSelectViews.objectsToView.items=( for o in theViews collect o.name)
				UpdateScreenSpaceOptions()
			)
			on btnRemoveSelected pressed do
			(
				--Turn the selected items into an index array
				theSelection = objectsToView.selection as array
				--Create a new array that holds the selected nodes
				newArray= for o in theSelection collect theViews[o]
				--Delete items from the main Node Arrays
				for o in newArray do deleteItem theViews (findItem theViews o)
				
				--Update the MultiListView
				RLTSelectViews.objectsToView.items=( for o in theViews collect o.name)
				--Refresh the ScreenSpace options List
				UpdateScreenSpaceOptions()
			)
		)		
	-------------------------------------------------------------------------------------------------------------------------------
	--Rollout with all the options to configure the type of visibility we want between the views
	-------------------------------------------------------------------------------------------------------------------------------
		rollout RLTViewsConfig "Step 2 - Setup / Options"
		(
			checkbox cbIgnoreWalls "Ignore Obstacles" tooltip:"Enabling this option will make all cameras visible among themselves"
			CheckBox useMin "Use min distance" across:2 tooltip:"If enabled, distances below this threshold will be ignored"
			spinner spnMinDist "" range:[1,10000,1] enabled:false
			CheckBox useMax "Use max distance" across:2 tooltip:"If enabled, distances above this threshold will be ignored"
			spinner spnMaxDist "" range:[1,10000,1] enabled:false

			button btnCalculateConnections "Get Connections" width:150 height:40 offset:[0,10] tooltip:"Calculate all connections between nodes"


			--on cbIgnoreWalls changed val do 

			on useMin changed val do ( spnMinDist.enabled=val )
			on useMax changed val do ( spnMaxDist.enabled=val )

			on btnCalculateConnections pressed do
			(
				CalculateAllLinks()
				CreateAllFPRLinks "world"
				EnableWorldSpaceDebug()
				RLTExport.lblvalidLinks.text= ("There are  "+validLinks.count as string+" valid links") 
				RLTExport.ddlAllConnections.items=(GetValidConnectionNames())
				RLTExport.ddlAllConnections.selection=0
			)
		)
	------------------------------------------------
	--Rollout with the Export Options
	------------------------------------------------
		rollout RLTExport "Step 3 - Review / Export"
		(
			Label lblvalidLinks "There are X valid links" offset:[0,5]			
			
			dropdownlist  ddlAllConnections "Select Links"  selection:0
			
			label lblFPRNameText 	"From:"	align:#left	offset:[0,15] across:2
			label lblFPRFrom 		""		align:#left	offset:[-60,15]
			
			label lblFPRTypeText 	"Type:"	align:#left	offset:[0,0] across:2
			label lblFPRType 		""		align:#left	offset:[-60,0]	
			
			label lblFPRCoordSysText 	"Coord. Sys.:"	align:#left	offset:[0,0] across:2
			label lblFPRCoordSys 		""				align:#left	offset:[-30,0]	
			
			label lblFPRCoordsText 	"Coords.:"	align:#left	offset:[0,0] across:2
			label lblFPRCoords 		""		align:#left	offset:[-50,0]
			
			label lblSpacing ""
			
			groupbox gbxFPRInfo "FPR Link Info" width:215 height:95 pos:[5,75]
			
			button btnExportUnified "Export " 	width:150 height:40 offset:[0,5]

			on ddlAllConnections selected val do
			(
				allFPRLinks[val].Debug()
				lblFPRFrom.text= allFPRLinks[val].myViewName
				lblFPRType.text= allFPRLinks[val].myType
				lblFPRCoordSys.text= allFPRLinks[val].myCoordSys
				lblFPRCoords.text= allFPRLinks[val].myCoords as string
			)
			
			on btnExportUnified pressed do
			(
				ExportWorld()
			)	
				
		)
	---------------------------------------------------------------------------------------------------------------
	--Rollout with the results of the visibility we calculated, mostly used to debug
	---------------------------------------------------------------------------------------------------------------
		rollout RLTDebugViewsConnection "Debug Views Connections"
		(
			checkBox cbDebugLine "Draw Debug Line" align:#left
			listbox fromNode "From View" enabled:false width:100 height:5 across:2
			listbox toNode "To View" enabled:false width:100 height:5

			label lblSpc "" 

			label lblFirstObstText "First Obstacle:" across:2 align:#left
			
			button btnSelectFirstObstacle ""  width:130 offset:[-15,-3] tooltip:"Select first obstacle "

			on cbDebugLine changed val do
			(
				if (val ==True) do
				(
					if(toNode.selection != 0 and fromNode.selection != 0) do 
						DebugDrawLineBetweenTwoPoints theViews[fromNode.selection] theViews[toNode.selection]
				)
			)
			
			on fromNode selected val do
			(
				--print ("fromNode selected "+ val as string )
				if(toNode.selection != 0) do
				(
					DebugViewConnection (#(theViews[fromNode.selection],theViews[toNode.selection]))
				)
			)
			on toNode selected val do
			(
				--print ("toNode selected "+ val as string )
				if(fromNode.selection != 0) do
				(
					DebugViewConnection (#(theViews[fromNode.selection],theViews[toNode.selection]))
				)
			)
			on fromNode doubleClicked val do 
			(
				select theViews[val]
			)
			on toNode doubleClicked val do 
			(
				select theViews[val]
			)
			
			on btnSelectFirstObstacle pressed do 
			(
				if (currentObstacle != undefined) do try(select currentObstacle)catch()
			)

		)	
	------------------------------------------------
	--Rollout with the Export Options
	------------------------------------------------
		rollout RLTScreenSpaceDebug "Screen Space Link Configuration"
		(
			label lblViews "View: " align:#left across:2 width:40
			dropdownlist ddScreenSpaceAllViews "" align:#left width:175 offset:[-70,-3] items:(for o in theViews collect o.name)

			button btnAddNewScreenSpaceLink "Add New"
			
			button btnDebugExisting "Print Existing"
			on btnDebugExisting pressed do
			(
				for o in screenLinks do DebugFPRLink o
			)
			
			on btnAddNewScreenSpaceLink pressed do
			(
				if( ddScreenSpaceAllViews.selection>0) do	--Si hay una vista seleccionada
				(
					SetupScreenSpaceLinkCreation()
					CreateDialog AddScreenSpaceLink width:230 height:160
				)	
			)
		)		
	----------------------------------------------------------------------------------
	--Rollout with the ScreenSpace Link Creation Methods
	----------------------------------------------------------------------------------
		rollout AddScreenSpaceLink "Add ScreenSpace Link"
		(		
			button lblInstructions1 "Click & Drag left mouse button to move"  	align:#left	width:205 height:30 enabled:false
			button lblInstructions2 "Postition the camera and press `Add`"  		align:#left	width:205 height:30 enabled:false			
			
			label lblCoor "Coordinates" align:#middle offset:[0,5]
			label lblEulerX ""  align:#left offset:[0,5] across:3
			label lblEulerY ""  align:#left offset:[0,5]
			label lblEulerZ ""  align:#left offset:[0,5]
			
			button btnFinish "Add" height:25 width:120 offset:[0,5]
			
			on btnFinish pressed do
			(
				newLink= NewFPRLink RLTScreenSpaceDebug.ddScreenSpaceAllViews.selected "FPR" "Screen"
				newLink.myCoords= theHelperCamera.transform.rotation as EulerAngles
				
				append screenLinks newLink
				DestroyDialog AddScreenSpaceLink
				
			)
			
			
			on AddScreenSpaceLink open do
			(
				callbacks.addScript #viewportChange "PrintCameraRotation()" id:#UpdateHelperCamRotation				
				print "creating new ScreenSpace Link"				
				max pancamera
			)
			on AddScreenSpaceLink close do
			(
				callbacks.removeScripts #viewportChange id:#UpdateHelperCamRotation
				
				delete theHelperCamera					--Borramos la camara helper
				viewport.setType previousViewportType 	--Volvemos al viewport que estaba activo antes del comienzo del setteo
				viewport.setTM previousViewportMatrix	--Reseteamos a la posicion original de ese viewport
				max pancamera
			)
			
		)
		
--------------------------------------------
--EXECUTE
--EXECUTE
--EXECUTE
--EXECUTE
--------------------------------------------	
	on execute do
	(
		theViews=#()
		
		try(t=windows.getChildHWND 0 "Calculate Views Connections"
		UIAccessor.CloseDialog t[1])catch()

		CreateDialog RLTMainRollout width:270 height:650
		AddSubRollout RLTMainRollout.SRLTChooseViews RLTSelectViews
		AddSubRollout RLTMainRollout.SRLTChooseViews RLTViewsConfig
		AddSubRollout RLTMainRollout.SRLTChooseViews RLTExport
		
		AddSubRollout RLTMainRollout.SRLTChooseViews RLTDebugViewsConnection
		AddSubRollout RLTMainRollout.SRLTChooseViews RLTScreenSpaceDebug

		RLTMainRollout.SRLTChooseViews.height += 625
		RLTMainRollout.SRLTChooseViews.RLTDebugViewsConnection.open=false
		RLTMainRollout.SRLTChooseViews.RLTScreenSpaceDebug.open=false
	)
)
