tool PlaceProp
(
on freeMove do 
( 
	if(propPlaced == false )do
	(
			mouseray = mapScreenToWorldRay mouse.pos							--Creamos un rayo desde el mouse hacia la escena
			
			myray=ray mouseray.pos mouseray.dir

			local intersect = intersectRayScene myray

			if intersect.count>0 then
			(
				
				/*Get the matrix of the current viewport camera*/ coordSysTM = Inverse(getViewTM())
				/*Get the pos of the viewport camera*/ viewPt = coordSysTM.row4

				/*Create a value for holding the index of the closest node*/closestIndex=-1
				/*Setup a value that holds the current closest distance*/closestDist=1000000					 

				--clearListener()
				for o=1 to intersect.count by 1 do
				(	
					if(intersect[o][1]!=importedProp) do
					(						
						--print intersect[o][1].name
						--print (classof intersect[o][1])
						--lastSel= intersect[o][1]
						--print intersect[o][2].pos						
						/*calculate the distance between this node and the camera*/thisDist= distance (viewPt) (intersect[o][2].pos)
						if(thisDist<closestDist) do
						(
							closestDist=thisDist
							closestIndex=o
						)						
					)					
				)				
				if(closestIndex!=-1)do
				(
						--print ("Closest node is "+intersect[closestIndex][1].name)
						importedProp.pos =intersect[closestIndex][2].pos
				)
			)
	)
)
on mousePoint clickno do
	(
		remainder= mod clickno 2

		format "Click: % . Remainder: % . Place Multiple: % \n" clickno remainder placeMultiple

		--print "Placing Object"
		if(remainder==1)do propPlaced=true
		if(remainder==0) do 
		(
			if(placeMultiple==false )then #stop
			else
			(
				print "Cloning"
				testArray=#()
				append testArray importedProp
				select testArray[1]
				maxOps.cloneNodes (testArray) cloneType:#instance newNodes:&nnl #nodialog
				importedProp=nnl[1]

				global startMousePos= Mouse.pos.x
				global propPlaced=false
				--Run the Tool
				#stop
			)
		)
	)

on mouseMove clickno do 
	(
		--print Mouse.pos
		theRotation =Mouse.pos.x- startMousePos		
		importedProp.rotation.z_rotation=theRotation		
	)
	
on start do 
	(
		/*
		--print importedProp.name
		--select importedProp
		--print"starting"		
		--We will create a plane that is invisible and very large so objects like chairs could be placed on the scene at ground level
		if(thePlane==Undefined)do
		(
			global thePlane = Plane length:10000 lengthsegs:1 width:10000 widthsegs:1 pos:[0,0,0] isSelected:off name:"plainito" wirecolor:(color 128 128 128)
			myMaterial= StandardMaterial()
			myMaterial.opacity=0
			thePlane.material=myMaterial			
		)	
		*/
	)
	
on mouseAbort clickno do
	(
		aborted=true
		
		format "Aborteddd: %\n" clickno
		#stop
	)
	
on stop do
	(
		if(placeMultiple ==False ) then 
		(
			print "Finished placing single"
			try (delete thePlane	)
			catch(delete $plainito)
		)
		else 
		(
			if(aborted==true)then
			(
				print "Finished placing multiple"
				delete importedProp
				delete thePlane	
			)
			else
			(
				fileIn "\\\\COMPARTIDA\Renderings\Resources\KispTools\Scripts\Props\Tool_PlaceProp.ms"	
			)
				
		)
	)
)
startTool PlaceProp prompt:"Place Prop"

--USAGE
--USAGE
/*
		--CREATE THE PLANE THAT IS GOING TO BE USED AS GROUND 
		global thePlane = Plane length:10000 lengthsegs:1 width:10000 widthsegs:1 pos:[0,0,0] isSelected:off name:"plainito" wirecolor:(color 128 128 128)
		myMaterial= StandardMaterial()
		myMaterial.opacity=0
		thePlane.material=myMaterial	
																														
		--DEFINE THE OBJECT TO BE PLACED
		mergemaxfile PropImporterV2.selectedItem  #select #mergeDups #useSceneMtlDups     
		global importedProp =selection[1]	
		--OR
		global importedProp=PickObject()									

		--DECLARE THE GLOBAL VARIABLES FOR THE TOOL
		global startMousePos= Mouse.pos.x
		global propPlaced=false
		global placeMultiple=false
		global aborted=false
	
		--RUN THE TOOL
		fileIn "\\\\COMPARTIDA\Renderings\Resources\KispTools\Scripts\Props\Tool_PlaceProp.ms"
*/
