macroscript Macro_PropExporterV1
	category:"Matanga"
	tooltip:"Prop Exporter Utility"
(
	local originalPropObjects= undefined
	local newPropObjects = undefined
	--Group Parts
	local theParts=#()
	local theHead=undefined
	
	--PROP PRE REQUIREMENTS
	--Not a group
	--Good Pivot positioning
	--GoodNaming
	--Positioned at origin
	
	
	
	function clusterAttach objArr =
  	(
  		
  		j = 1
  		count = objArr.count
  			
  		undo off
  		(
  			while objArr.count > 1 do
  			(				
  				if classof objArr[j] != Editable_Poly then converttopoly objArr[j]
  					
  				polyop.attach objArr[j] objArr[j+1]
  				deleteItem objArr (j+1)
  					
  				j += 1
  					
  				if (j + 1) > objArr.count then j = 1
  				
  			)
  		)
  		return objArr[1]
  	)
	
	fn CloneOriginal prop =
	(
		maxOps.cloneNodes prop cloneType:#instance newNodes:&newPropObjects
	)
	
	-- This function gets the head of a group
	fn ClassifyGroupNodes newProp =
	(
		theParts=#()
		theHead=undefined
		
		theParts= for o in newPropObjects where (isGroupMember o) collect o
		for o in newPropObjects where isGroupHead o do theHead = o	
	)
	
	
	--Prop Database
	
	--Take a screenshot	
	fn TakeScreenshot =
	(
		img = gw.getViewportDib()
		img.filename = "C:/Users/asinf/Desktop/" + selection[1].name + ".jpg"
		save img	
	)
	
	
	on execute do
	(
		originalPropObjects= $
		
		CloneOriginal originalPropObjects
		
		print newPropObjects
		
		ClassifyGroupNodes newPropObjects
		
		print theHead
		
		theHead.pos=[0,0,0]
		
		select newPropObjects
		
		IsolateSelection.EnterIsolateSelectionMode()
		
		explodegroup theHead
		
		clusterAttach theParts
		
		
	)
	
	
	
	
	
	
	--Select a prop
	
	--Update Prop Importer Macro
	
)