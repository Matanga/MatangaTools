macroscript QuickUVWRotate
category:"Matanga"
(
	
	
	fn TryRotate theAngle =
	(			
			if ( selection.count == 1) then
			(
					theObj= selection[1]			
					giz=undefined
					
					for o in theObj.modifiers do
					(
							if (classof o == UVWMap) do giz=o
					)
					
					if(giz!= undefined) then
					(
						--ROTATE HERE
						
						gizmo_rotation = giz.gizmo.rotation
						giz.gizmo.rotation = gizmo_rotation * ((eulerangles theAngle.x theAngle.y theAngle.z) as quat)						
					)
					else
					(
							messagebox "No UVWMap in the object"
					)					
			)						
			else
			(
				messagebox "Select only one object"
			)
	)
	
	rollout QuickRotate "Quick Rotate UVW"
	(
		  button minusX "<" align:#left width:35 across:3 --offset:[-7,0]
		  button axisX "X" align:#center width:35
		  button plusX ">" align:#right width:35
		
		  button minusY "<" align:#left width:35 across:3 --offset:[-7,0]
		  button axisY "Y" align:#center width:35
		  button plusY ">" align:#right width:35		
		
		  button minusZ "<" align:#left width:35 across:3 --offset:[-7,0]
		  button axisZ "Z" align:#center width:35
		  button plusZ ">" align:#right width:35		

			on minusX pressed do TryRotate [-90,0,0]
			on plusX pressed do TryRotate [90,0,0]
			on minusY pressed do TryRotate [0,-90,0]
			on plusY pressed do TryRotate [0,90,0]
			on minusZ pressed do TryRotate [0,0,90]
			on plusZ pressed do TryRotate [0,0,-90]
				

		
	)
	
	CreateDialog QuickRotate width:150 height:90
	
)