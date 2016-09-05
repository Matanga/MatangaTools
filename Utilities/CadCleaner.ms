Macroscript CadCleanerV1
category:"Matanga"
(
	-------------------------------------------------------
	-------------------------------------------------------
	-----VARIABLES
	-------------------------------------------------------
	-------------------------------------------------------	
	blockCountLabel=undefined
	shapeCountLabel=undefined
	layerCountLabel=undefined
	-------------------------------------------------------
	-------------------------------------------------------
	-----TOOL UTILITIES
	-------------------------------------------------------
	-------------------------------------------------------
	
	/************************************
		USE: Unlinks and Deletes all blocks in the scene
	*/
	fn ClearBlocks =(
		undo on
		(
			for o in objects do 
			(
					o.controller=prs()
					if classof o.parent == LinkComposite do o.parent = undefined
			)
			for o in (objects as array) where classof o == LinkComposite do delete o		
		)
	)
	
	fn ClearAllSplines =
	(
		undo on
		(	
			for o in (objects as array) where superclassof o == Shape do delete o		
		)
	)
	
	fn UnifyLayers =
	(
		--make new layer
		theLayer = Layermanager.newlayer()

		for i in Objects do
			(
			
			--remove bylayer wirecolors
			i.colorbylayer = false
			i.wirecolor = if i.layer.wirecolor != white then i.layer.wirecolor \
							else if i.wirecolor != white then i.wirecolor \
							else orange
							
			--assign to new layer
			theLayer.addnode i
			)
		
			for o= Layermanager.count-1 to 0 by -1 do
			(
				  ilayer = layerManager.getLayer o
				  layerName = ilayer.name
				  layer = ILayerManager.getLayerObject o
				  layerNodes = refs.dependents layer
					--print (layerName+" has "+layerNodes.count as string +" nodes")				
					--for o in layerNodes do print o
				--A layer with 2 references is  an empty Layer
				  if(layerNodes.count==2)do LayerManager.deleteLayerByName layerName
				
			)
		
		
	)
	
	
	fn GetObjectsCount =
	(
		--Count Blocks
		counter=0
		for o in Objects where( matchpattern o.name pattern:"Block*") do counter=counter+1
		blockCountLabel= ("Block Count: "+ counter as string)
		--Count Shapes
		counter=0
		for o in Objects where superclassof o == Shape do counter= counter+1
		shapeCountLabel= ("Shape Count: "+ counter as string)
		--Layers
		layerCountLabel= ("Layer Count:"+ LayerManager.count as string)
		
	)
	GetObjectsCount()
	
	-------------------------------------------------------
	-------------------------------------------------------
	-----UI
	-------------------------------------------------------
	-------------------------------------------------------
	Rollout ROCleanBlocks "Clean Blocks"
	(
		label lblBlockCount blockCountLabel align:#left
		button btnCleanBlocks "Clean Blocks" align:#center tooltip:"This will unlink all blocks\nand delete them."
		label lblShapeCount shapeCountLabel align:#left
		button btnDeleteSplines "Delete Splines" align:#center tooltip:"WARNING:This will delete ALL shapes\nfrom the scene"
		label lblLayerCount layerCountLabel align:#left
		button btnUnifyLayers "Unify Layers" align:#center tooltip:"WARNING:This will move all objects to a new\nlayer and delete the remaining\nempty layers"
		
		on btnCleanBlocks pressed do
		(
			ClearBlocks()
			lblBlockCount.text="No Blocks"
			btnCleanBlocks.enabled=false
		)
		on btnDeleteSplines pressed do
		(
			ClearAllSplines()
			lblShapeCount.text="No Shapes"
			btnDeleteSplines.enabled=false
		)
		on btnUnifyLayers pressed do
		(
			UnifyLayers()
			btnUnifyLayers.enabled=false
			lblLayerCount.text="Fixed Layers"
		)
	)
	try(t=windows.getChildHWND 0 "Clean Blocks"
	UIAccessor.CloseDialog t[1])catch()
	CreateDialog ROCleanBlocks width:120 height:150
)