
struct BlockAnalizer
(
	myInst=undefined,
	
	myPanel1= undefined,
	myPanel2=undefined,	
	myLV =undefined,
	
	--------------------------------------------
	--------------------------------------------
	-- TOOL VARIABLES
	-- TOOL VARIABLES
	--------------------------------------------
	--------------------------------------------	
	currentSelectedName= undefined,
	currentSelectedIndex= undefined,
	
	BlockArray=#(),
	
	allBlocks=#(),
	
	allBlocksAmount=#(),

	allBlocksFullNames=#(),
	
	allBlocksTypes=#(),	
	
	selectedBlocks=#(),

	allSplineBlocks=#(),

	allSelected =#(),
	
	
	--------------------------------------------
	--------------------------------------------
	-- DOTNET UTILITIES
	-- DOTNET UTILITIES
	--------------------------------------------
	--------------------------------------------	
	include "\\\\COMPARTIDA\Renderings\Resources\KispTools\KispToolsUtils.ms" 
	
	--------------------------------------------
	--------------------------------------------
	-- TOOL UTILITIES
	-- TOOL UTILITIES
	--------------------------------------------
	--------------------------------------------
		--Block Types  0: undefined  1:empty  2: spline  3:nested  4:Geometry
		fn GetBlockType theIndex =			
		(
			--print ("testing index "+theIndex as string)
			theType=""
			if(theIndex==1)do theType="Empty"
			if(theIndex==2)do theType="Spline"
			if(theIndex==3)do theType="Nested"
			if(theIndex==4)do theType="Geometry"
			if(theIndex==5)do theType="Child"
			theType
		),
	
		fn IsObjectBlock theObjName =
		(
			isBlock=false
			if( matchPattern theObjName pattern:"Block*" ignoreCase:true) do isBlock=true
			isBlock
		),
		
		fn AreAllChildrenShapes theParent =
		(
			allChildAreShapes= true
			for o in theParent.children where (superclassof o !=Shape) do allChildAreShapes=false 
			allChildAreShapes
		),
		
		---REVIEWWWW
		fn BlockHasGeometry theParent =
		(
			hasGeometry= false
			for o in theParent.children do
			(
				if superclassof o ==GeometryClass do hasGeometry=true 
			)			
			hasGeometry		
		),
		
		--Recursive function that gets all children diwb the hierarchy
		fn AddchildrenToSelection theParent theArray =
		(
			for child in theParent.children do
			(
				append theArray child
				if(child.children.count !=0) do AddchildrenToSelection child theArray
			)
		),
		
	--------------------------------------------
	-- TOOL METHODS
	-- TOOL METHODS
	--------------------------------------------
	--------------------------------------------

		--Function to check if a given object is part of a hierarchy whose parent is a Block
		
		fn NodeBelongsToBlock =
		(			
				theObj= PickObject()
				
				if(theObj != undefined) do 
				(
						--print ("The Object "+theObj.name)
						if(theObj.parent != undefined) do
						(
							--print ("the parent "+theObj.parent.name)
							if ( (IsObjectBlock theObj.parent.name) ==true) then
							(
								theIndex=1
								matchFound=false
								for o in allBlocksFullNames do
								(
									if(matchFound==false)do
									(
										if(theObj.parent.name == o) then matchFound=true
																				else theIndex=theIndex+1																		
									)
								)
								--This Highlights the Item
								BlockAnalizer.myLV.FocusedItem= BlockAnalizer.myLV.Items.Item[theIndex-1]
								BlockAnalizer.myLV.Items.Item[theIndex-1].Selected = true;						
							)
							else
							(
									print "not a block"
							)
						)
				)				
		),	
		
		
		fn ClearNestedBlocks =
		(	
			allNested=#()
			for m=1 to allBlocksTypes.count by 1 do
			(
				if allBlocksTypes[m]==3 do append allNested m				
			)
			
			selectedBlocks=#()

			for x in allNested do				
			(
					for o in geometry where o.name ==allBlocksFullNames[x] do 
					(
						append selectedBlocks o
					)					
			)
			--Select the list
			select selectedBlocks		
		),		
		--Function to select all Blocks with the provided name and its children
		fn SelectAllBlocksAndChilds theName =
		(	
			--print ("Selecting "+ theName)
			--Reset the selected list
			selectedBlocks=#()
			for o in geometry where o.name ==theName do 
			(
				--Add this object to the list
				append selectedBlocks o
				--Add all the children of the object to the list
				for c in o.children do append selectedBlocks c
			)
			--Select the list
			select selectedBlocks		
		),
		
		--Select all blocks that are solely 
		fn RemoveSplineBlocks =
		(
			undo on
			(
				BlockAnalizer.allSplineBlocks=#()
				--Por todos los objectos en la geometria que sean bloques y cuyos hijos sean todos Splines
				for o in geometry where ( (IsObjectBlock o.name) ==true ) and ( (AreAllChildrenShapes o )==true  ) do append allSplineBlocks o	
				
				--allSelected=#()
				toBeSelected =#()				
				for o in allSplineBlocks do
				(
					AddchildrenToSelection o toBeSelected
					append toBeSelected o
				)				
				delete toBeSelected		
			)	
			BlockAnalizer.PopulateList()
			BlockAnalizer.UpdateBlockListView()		
		),
		
		fn ReplaceSelected theName =
		(
			undo on
			(
					replaceObj= PickObject()

					if (replaceObj != undefined) do
					(
						newPositions=#()
						newRotations=#()	
						createdObjects = #()
						for o in geometry where o.name ==theName do 
						(
							--resetxform o
							append newPositions o.position
							append newRotations o.rotation
						)				
						for inst=1 to newPositions.count do
						(
							newObj= copy replaceObj
							newObj.baseObject=replaceObj.baseObject
							if(replaceObj.material != undefined) do newObj.material=replaceObj.material
							append createdObjects newObj
							newObj.rotation= newRotations[inst]							
							newObj.position= newPositions[inst]
						)
						SelectAllBlocksAndChilds theName
						delete selection
						select createdObjects
						BlockAnalizer.PopulateList()
					)
		
			)
		),
			
		function GetAllBlocksAmounts =
		(
			--Populate the List with empty Values
			for o in BlockAnalizer.allBlocks do append BlockAnalizer.allBlocksAmount 0
					
			for o in geometry where ( o.parent == undefined) do
			(
				--print ("doing "+ o.name)
				if(  (BlockAnalizer.IsObjectBlock o.name) ==true) do
				(
					theIndex = findItem BlockAnalizer.allBlocksFullNames o.name 						
					BlockAnalizer.allBlocksAmount[theIndex]=BlockAnalizer.allBlocksAmount[theIndex]+1						
				)
			)	
		),

		--Block Types  0: undefined  1:empty  2: spline  3:nested  4:Geometry 5:Child
		function GetAllBlocksTypes =
		(
			--Populate the List with empty Values
			for o in BlockAnalizer.allBlocks do append BlockAnalizer.allBlocksTypes 0
					
			for o in geometry where ( o.parent == undefined) do
			(
				if( (BlockAnalizer.IsObjectBlock o.name) ==true) do
				(
					theIndex = findItem BlockAnalizer.allBlocksFullNames o.name
					
					if(BlockAnalizer.allBlocksTypes[theIndex] == 0)do
					(
						typeFound=false
						--Is this an Empty Block??
						if(o.children.count ==0 and typeFound==false) do
						(
							--print"block is Empty"
							BlockAnalizer.allBlocksTypes[theIndex]=1
							typeFound=true
						)
						
						
						
						--Is this a block that has a block as a child (nested Block )
						if(o.children.count ==1 and IsObjectBlock o.children[1].name ==true  and typeFound==false) do
						(
							--print"block is Nested"
							BlockAnalizer.allBlocksTypes[theIndex]=3
							typeFound=true
						)
						--Is this a block whose childs are all splines?
						if(AreAllChildrenShapes o and typeFound==false) do
						(
							--print"block is Spline"
							BlockAnalizer.allBlocksTypes[theIndex]=2
							typeFound=true
						)
						--Is this a block that has at least one child that is Geometry
						if(BlockHasGeometry o==true and typeFound==false) do
						(
							--print"block is Geometry"
							BlockAnalizer.allBlocksTypes[theIndex]=4
							typeFound=true
						)
						
					
					
					)					
				)
			)	
		),
				
		
		function UpdateBlockLists =
		(
			print "Cataloguing Blocks"
			BlockAnalizer.allBlocks=#()
			BlockAnalizer.allBlocksFullNames =#()
			BlockAnalizer.allBlocksAmount =#()			
			BlockAnalizer.allBlocksTypes=#()
						
			
			--First find all unique Blocks
			for o in geometry where ( o.parent == undefined) do
			(
					--print ("doing "+ o.name)
					if(   (BlockAnalizer.IsObjectBlock o.name) ==true  ) do	--If the object is a block and it doesnt have a parent
					(
						--print o.name 
						newString= replace o.name 1 6 ""
						--print newString							
						appendIfUnique BlockAnalizer.allBlocks newString
						appendIfUnique BlockAnalizer.allBlocksFullNames o.name
						
					)
			)
			print("Blocks: "+ BlockAnalizer.allBlocks.count as string )
			
			BlockAnalizer.GetAllBlocksAmounts()
			BlockAnalizer.GetAllBlocksTypes()
		
		),
		
		--------------------------------------------
		--------------------------------------------
		-- UI UTILITIES 
		-- UI UTILITIES 
		--------------------------------------------
		--------------------------------------------
		
		--Function that fills the ListView
		fn PopulateList  = 
		(
            rows=#()
			BlockAnalizer.myLV.Clear()
			BlockAnalizer.myLV.Update()
			
			BlockAnalizer.myLV.HideSelection = false
			
			--addColumns theLv #("Name","Image")
			BlockAnalizer.myLV.Columns.add "Name" 225
			BlockAnalizer.myLV.Columns.add "Amount" 50
			BlockAnalizer.myLV.Columns.add "Type" 75
			BlockAnalizer.UpdateBlockLists()
			
            for t=1 to BlockAnalizer.allBlocks.count do 
			(
				li=dotNetObject "System.Windows.Forms.ListViewItem" (replace BlockAnalizer.allBlocksFullNames[t] 1 6 "")
				li.UseItemStyleForSubItems=true
				--The amount of instances of this block
				li.subitems.add (BlockAnalizer.allBlocksAmount[t] as string )
				--The Type of this block
				li.subitems.add (BlockAnalizer.GetBlockType BlockAnalizer.allBlocksTypes[t] )
				
				append rows li
            )
           
       
			BlockAnalizer.myLV.items.addRange rows
			BlockAnalizer.myLV.Update()
        ),		
		
		fn NewDNButton theName s:[0,0] =
		(
								--Create a new Button 
					dnButton = dotNetObject "button"
					--Set the Text
					dnButton.text=theName
					--Set the size
					dnButton.Size = dnSize s:[s.x, s.y]		
					--Set the Margin
					dnButton.Margin.All=10
					--dnButton.Margin= dnButton.Margin.empty					
					--Set the backcolor
					dnButton.backcolor = dnColor c:[200,200,200] a:255
					--Set Hover Colors
					dnButton.flatStyle=dnButton.flatStyle.popup
			
					dnButton
		),				
		
		--------------------------------------------
		--------------------------------------------
		-- UI METHODS 
		-- UI METHODS 
		--------------------------------------------
		--------------------------------------------

		
		fn UpdateBlockListView  =
		(			
			--------------------------------
			--------------------------------
			--PANEL 1
			--PANEL 1
			--------------------------------
			--------------------------------	
			BlockAnalizer.myPanel1
			BlockAnalizer.myPanel1.backColor =dnColor c:[75,50,90] a:255			
			
						--------------------------------
						--------------------------------
						--LIST VIEW
						--LIST VIEW
						--------------------------------
						--------------------------------				
			
										--Setup the forms view
							theLv= dotNetObject "ListView"
							myLV=theLV			
							theLv.width=BlockAnalizer.myPanel1.width
							theLv.height=BlockAnalizer.myPanel1.height

							theLv.view=(dotNetClass "system.windows.forms.view").details
							theLv.FullRowSelect=true			--Set so full width of listView is selected and not just first column.
							theLv.GridLines=true				--Show lines between the items. 
							theLv.MultiSelect=false				--Only one item can be selected 

						
						
							--Add the LV control to the panel
							BlockAnalizer.myPanel1.controls.add theLv
							--LLenar la lista
							BlockAnalizer.PopulateList()
							
							dotNet.addEventHandler theLv "ItemSelectionChanged" ( fn ChangeSelectedItem = 
																							(																								
																								if(BlockAnalizer.myLV.FocusedItem != undefined) do
																								(
																									BlockAnalizer.currentSelectedName=BlockAnalizer.allBlocksFullNames[BlockAnalizer.myLV.FocusedItem.index+1]
																									print("Selected "+ BlockAnalizer.currentSelectedName)
																									
																									--print(BlockAnalizer.myLv.FocusedItem.index)
																									
																									
																								)
																							)  
																					)		
							dotNet.setLifetimeControl theLv #dotnet

							dotNet.addEventHandler theLv "DoubleClick" ( fn SelectDoubleClicked = 
																							(	
																								--print "DoubleClicked"
																								--print BlockAnalizer.currentSelectedName
																								BlockAnalizer.currentSelectedIndex=BlockAnalizer.myLv.FocusedItem.index
																								
																								BlockAnalizer.SelectAllBlocksAndChilds BlockAnalizer.currentSelectedName
																								/*
																									print BlockAnalizer.myLv.Items.Item[BlockAnalizer.currentSelectedIndex]
																									BlockAnalizer.myLv.Items.Item[BlockAnalizer.currentSelectedIndex].Selected = true
																									BlockAnalizer.myLv.Select()
																								*/
																							)  
																					)		
							dotNet.setLifetimeControl theLv #dotnet																					
			
			
		),
		
		fn UpdateToolList sender =
		(			
			--------------------------------
			--PANEL 1
			--PANEL 1
			--------------------------------			
					--------------------------------
					--FLOW
					--FLOW
					--------------------------------			
					--Flow Layout		
					dnFlow= dotNetObject "flowLayoutPanel"
					dnFlow.Flowdirection = dnFlow.Flowdirection.LeftToRight
					--dnFlow.bounds =KispTools.dnRec s:[kispTools.theContentPanel.width, kispTools.theContentPanel.height]
					dnFlow.BorderStyle=dnFlow.BorderStyle.none
					dnFlow.width=sender.width
					dnFlow.height=sender.height
					
					sender.controls.add dnFlow					
						
			
					dnButton1 =BlockAnalizer.NewDNButton "Update List" s:[80,30]					
					dnFlow.controls.add dnButton1						
					dotNet.addEventHandler dnButton1 "click" ( fn UpdateList = ( BlockAnalizer.PopulateList() ) )
					dotNet.setLifetimeControl dnButton1 #dotnet
				
					dnButton2 =BlockAnalizer.NewDNButton "Remove Spline Blocks" s:[80,30]					
					dnFlow.controls.add dnButton2						
					dotNet.addEventHandler dnButton2 "click" ( fn UpdateList = ( BlockAnalizer.RemoveSplineBlocks() ) )
					dotNet.setLifetimeControl dnButton2 #dotnet				

					dnButton3 =BlockAnalizer.NewDNButton "Find Block" s:[80,30]					
					dnFlow.controls.add dnButton3						
					dotNet.addEventHandler dnButton3 "click" ( fn UpdateList = ( BlockAnalizer.NodeBelongsToBlock() ) )
					dotNet.setLifetimeControl dnButton3 #dotnet	

					dnButton4 =BlockAnalizer.NewDNButton "Replace Block" s:[80,30]					
					dnFlow.controls.add dnButton4						
					dotNet.addEventHandler dnButton4 "click" ( fn UpdateList = ( BlockAnalizer.ReplaceSelected BlockAnalizer.currentSelectedName ) )
					dotNet.setLifetimeControl dnButton4 #dotnet	


					dnButton5 =BlockAnalizer.NewDNButton "Clear Nested Blocks" s:[80,30]					
					dnFlow.controls.add dnButton5						
					dotNet.addEventHandler dnButton5 "click" ( fn UpdateList = ( BlockAnalizer.ClearNestedBlocks() ) )
					dotNet.setLifetimeControl dnButton5 #dotnet	


		),
		
		fn initSplicContainer sender =
		(
			sender.backColor =dnColor c:[125,150,60] a:255
			sender.orientation = sender.orientation.horizontal
			sender.splitterDistance=300
			sender.splitterWidth=5
			sender.isSplitterFixed=true
			
			myPanel1=sender.panel1
			myPanel2=sender.panel2
			
			UpdateBlockListView()
			
			UpdateToolList sender.panel2
		),
	--------------------------------------------
	--------------------------------------------
	-- LAUNCH  UI
	-- LAUNCH  UI
	--------------------------------------------
	--------------------------------------------
	fn ui =
	(	
		rollout uiR "Block Analizer" width:380 height:400
		(			
			dotnetcontrol splitCon "system.windows.forms.splitContainer"  \
			width: (uiR.width)\
			height:(uiR.height)\
			offset:[-14,-5]

			
			on uiR open do
			(
				initSplicContainer splitCon

			)
			
		)		
		createDialog uiR
		myInst =uiR
	),
	
	--INITIALIZATION FUNCTION
	--INITIALIZATION FUNCTION
	fn run=
	(
		if(myInst == undefined) then
		(
			--GetAllUniqueBlocks()
			ui()
		)
		else
		(
			destrotDialog myInst
			myInst=undefined
		)
		
	)
	
)

global BlockAnalizer=BlockAnalizer()
BlockAnalizer.run()