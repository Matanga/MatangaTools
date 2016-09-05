tool TransferMaterial
(
			on mouseAbort clickno do
			(
				format "Abort: %\n" clickno
				#stop
			)	

			on start do
				(
					original=PickObject()
					transfer=PickObject()
					if(original != undefined and  transfer != undefined) then
					(
							if(original.material != undefined) then
							(
								transfer.material= original.material
								#stop
							)
							else
							(
								messagebox "The selected object doesnt have a material."
								#stop
							)						
					)
					else
					(
						messagebox "There was an error during the object selection."
						#stop						
					)				
					
				)
				on end do print "Ending"
)
