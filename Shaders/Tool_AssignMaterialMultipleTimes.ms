tool AsignMaterialMultipleTimes
(
		on mousePoint clickno do
		(

					if( (clickno==1) or (clickno >=2) )do
					(
					clearListener()
					print "Free moving"
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
									overObj =intersect[closestIndex][1]
									print overObj
							)
						)				
					
									overObj.material=medit.GetCurMtl() 

					)			
			
		)
			
		on mouseAbort clickno do
		(				
				format "Aborteddd: %\n" clickno
				#stop
		)
			
		on start do
		(
			global overObj=undefined
		)

)
		startTool AsignMaterialMultipleTimes prompt:"Place Prop"

