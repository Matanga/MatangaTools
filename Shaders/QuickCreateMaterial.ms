macroscript QuickAddMaterial
	category:"Matanga"
	tooltip:"Quick Add Material"
(	
	function DotheShit val state color=
	(
		if(state ==1) do
				(
					myMaterial= StandardMaterial()
					myMaterial.name = val
					myMaterial.diffuse=color
				)
				if(state ==2) do
				(
					myMaterial= VrayMtl()
					myMaterial.name = val
					myMaterial.diffuse=color
				)
				for o in selection do o.material =myMaterial
					
				
	)
	
	
	rollout Entername "Enter Name"
	(		
			radiobuttons rad_buttons "Type:"  labels:#("Standard", "Vray")  align:#left across:2
			colorpicker theColor ""  modal:false  align:#right
			button randomize "Random" align:#right offset:[0,-25]		
			edittext newName "Material Name:" text:"NewMaterial"fieldWidth:180 labelOnTop:true		
			button exitbutton "Apply & Exit"
		
			on randomize pressed do
			(
				theColor.color=Random black white
			)
			on exitbutton pressed do
			(
				DoTheShit newName.text rad_buttons.state theColor.color
				destroyDialog Entername
			)		
	)
	
	function DoIt =
	(		
			if selection.count!=0 then
			(				
				createDialog Entername width:200
			)
			else messagebox "Nothing is selected"		
	)
	DoIt()
	
	
)