
struct SceneWizard
(
	myInst=undefined,
	
	--------------------------------------------
	--------------------------------------------
	-- TOOL VARIABLES
	-- TOOL VARIABLES
	--------------------------------------------
	--------------------------------------------	

	
	BlockArray=#(),
	
	allObjects=#(),				--FIXED
	
	allObjectsAmount=#(),		--FIXED

	allObjectsFullNames=#(), 	--FIXED
	
	allObjectsTypes=#(),	
	
	selectedBlocks=#(),

	allSplineBlocks=#(),

	allSelected =#(),
	
	--------------------------------------------
	--------------------------------------------
	-- UI REFERENCES
	-- UI REFERENCES
	--------------------------------------------
	--------------------------------------------		
	myPanel1= undefined,		--The first panel of the split container
	myPanel2=undefined,			--The second  panel of the split container
	myLV =undefined,			--The List view with all the objects
	theNewNameButton=undefined,	--Reference to the button that will contain the new name of the selected objects

	theNewName=undefined,
	
	currentSelectedName= undefined,
	currentSelectedIndex= undefined,
	

	
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
		fn GetObjectType theIndex =	--FIXED		
		(
			--print ("testing index "+theIndex as string)
			theType=""
			if(theIndex==0)do theType="TEST"
			if(theIndex==1)do theType="Empty"
			if(theIndex==2)do theType="Spline"
			if(theIndex==3)do theType="Nested"
			if(theIndex==4)do theType="Geometry"
			if(theIndex==5)do theType="Child"
			theType
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

					theIndex=1
					matchFound=false
					for o in allObjectsFullNames do
					(
						if(matchFound==false)do
						(
							if(theObj.name == o) then matchFound=true
												else theIndex=theIndex+1																		
						)
					)
					--This Highlights the Item
					SceneWizard.myLV.FocusedItem= SceneWizard.myLV.Items.Item[theIndex-1]
					SceneWizard.myLV.Items.Item[theIndex-1].Selected = true;						
				

						
				)				
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
						SceneWizard.GetNewListView()
					)
		
			)
		),
			
		function GetAllObjectsAmounts =		--FIXED
		(
			--Populate the List with empty Values
			for o in SceneWizard.allObjects do append SceneWizard.allObjectsAmount 0
					
			for o in objects  do
			(
				theIndex = findItem SceneWizard.allObjectsFullNames o.name 						
				SceneWizard.allObjectsAmount[theIndex]=SceneWizard.allObjectsAmount[theIndex]+1					
			)	
		),

		--Block Types  0: undefined  1:empty  2: spline  3:nested  4:Geometry 5:Child
		function GetAllObjectsTypes =  --FIXED
		(
			--Populate the List with empty Values
			for o in SceneWizard.allObjects do append SceneWizard.allObjectsTypes 0
					
			for o in objects do
			(

				theIndex = findItem SceneWizard.allObjectsFullNames o.name
				
				if(SceneWizard.allObjectsTypes[theIndex] == 0)do
				(
					typeFound=false
					/*
					--Is this an Empty Block??
					if(o.children.count ==0 and typeFound==false) do
					(
						--print"block is Empty"
						SceneWizard.allBlocksTypes[theIndex]=1
						typeFound=true
					)
					
					
					
					--Is this a block that has a block as a child (nested Block )
					if(o.children.count ==1 and IsObjectBlock o.children[1].name ==true  and typeFound==false) do
					(
						--print"block is Nested"
						SceneWizard.allBlocksTypes[theIndex]=3
						typeFound=true
					)
					--Is this a block whose childs are all splines?
					if(AreAllChildrenShapes o and typeFound==false) do
					(
						--print"block is Spline"
						SceneWizard.allBlocksTypes[theIndex]=2
						typeFound=true
					)
					--Is this a block that has at least one child that is Geometry
					if(BlockHasGeometry o==true and typeFound==false) do
					(
						--print"block is Geometry"
						SceneWizard.allBlocksTypes[theIndex]=4
						typeFound=true
					)*/					
				)					
				
			)	
		),
				
		
		function UpdateObjectLists =	--FIXED
		(
			print "UpdateObjectLists"
			SceneWizard.allObjects=#()
			SceneWizard.allObjectsFullNames =#()
			SceneWizard.allObjectsAmount =#()			
			SceneWizard.allObjectsTypes=#()
						
			
			--First find all unique Blocks
			for o in objects do
			(
				theIndex=findItem SceneWizard.allObjectsFullNames o.name
				if(theIndex ==0 ) do
				(
					append SceneWizard.allObjects o
					append SceneWizard.allObjectsFullNames o.name		
				)					
					
			)
			print("DIfferent Objects: "+ SceneWizard.allObjects.count as string )
			
			SceneWizard.GetAllObjectsAmounts()
			SceneWizard.GetAllObjectsTypes()
		
		),
		
		--------------------------------------------
		--------------------------------------------
		-- UI UTILITIES 
		-- UI UTILITIES 
		--------------------------------------------
		--------------------------------------------
		
		--Function that fills the ListView
		fn GetNewListView  = 
		(
			print("GetNewListView")
            rows=#()
			SceneWizard.myLV.Clear()
			SceneWizard.myLV.Update()
			
			SceneWizard.myLV.HideSelection = false
			
			--addColumns theLv #("Name","Image")
			SceneWizard.myLV.Columns.add "Name" 225
			SceneWizard.myLV.Columns.add "Amount" 50
			SceneWizard.myLV.Columns.add "Type" 75
			SceneWizard.UpdateObjectLists()
			
            for t=1 to SceneWizard.allObjects.count do 
			(
				li=dotNetObject "System.Windows.Forms.ListViewItem" (SceneWizard.allObjectsFullNames[t])
				li.UseItemStyleForSubItems=true
				--The amount of instances of this block
				li.subitems.add (SceneWizard.allObjectsAmount[t] as string )
				--The Type of this block
				li.subitems.add (SceneWizard.GetObjectType SceneWizard.allObjectsTypes[t] )
				
				append rows li
            )
           
       
			SceneWizard.myLV.items.addRange rows
			SceneWizard.myLV.Update()
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
		-- UI SUBROLLOUTS 
		-- UI SUBROLLOUTS 
		--------------------------------------------
		--------------------------------------------
		fn RenameSelected theName =
		(
			for o in objects where o.name==currentSelectedName do
			(
					o.name=theName
			)
			--SceneWizard.UpdateListPanel()
			DestroyDialog SceneWizard.myInst
			SceneWizard.myInst=undefined
			SceneWizard.Run()
		),
		

		fn RenameDialog =
		(
				Rollout NewNameDialog "Choose new Name"
				(
					editText etNewName "New Name" align:#left
					button btnApply "Apply&Close" align:#center
					
					on etNewName changed val do
					(
							SceneWizard.theNewName=val
					)
					
					on btnApply pressed do
					(
						if(etNewName.text!="") do
						(
								SceneWizard.RenameSelected etNewName.text
								DestroyDialog NewNameDialog
						)
					)
				)
				try(DestroyDialog NewNameDialog)catch()
				CreateDialog NewNameDialog width:250 height:75 pos:mouse.screenpos
			
		),
		--------------------------------------------
		--------------------------------------------
		-- UI METHODS 
		-- UI METHODS 
		--------------------------------------------
		--------------------------------------------
		
		
		fn UpdateListPanel =
		(			
			print "UpdateListPanel"
			--------------------------------
			--------------------------------
			--PANEL 1
			--PANEL 1
			--------------------------------
			--------------------------------	
			SceneWizard.myPanel1
			SceneWizard.myPanel1.backColor =dnColor c:[75,50,90] a:255			
			
						--------------------------------
						--------------------------------
						--LIST VIEW
						--LIST VIEW
						--------------------------------
						--------------------------------			
			
							--Setup the forms view
							theLv= dotNetObject "ListView"
							myLV=theLV			
							theLv.width=SceneWizard.myPanel1.width
							theLv.height=SceneWizard.myPanel1.height

							theLv.view=(dotNetClass "system.windows.forms.view").details
							theLv.FullRowSelect=true			--Set so full width of listView is selected and not just first column.
							theLv.GridLines=true				--Show lines between the items. 
							theLv.MultiSelect=false				--Only one item can be selected 
							theLv.AllowDrop=true
						
						
							--Add the LV control to the panel
							SceneWizard.myPanel1.controls.add theLv
							--LLenar la lista
							SceneWizard.GetNewListView()
							
							dotNet.addEventHandler theLv "ItemSelectionChanged" ( fn ChangeSelectedItem = 
																							(																								
																								if(SceneWizard.myLV.FocusedItem != undefined) do
																								(
																									SceneWizard.currentSelectedName=SceneWizard.allObjectsFullNames[SceneWizard.myLV.FocusedItem.index+1]
																									print("Selected "+ SceneWizard.currentSelectedName)
																									
																									--print(SceneWizard.myLv.FocusedItem.index)
																									
																									
																								)
																							)  
																					)		

							dotNet.addEventHandler theLv "DoubleClick" ( fn SelectDoubleClicked = 
																							(	
																								--print "DoubleClicked"
																								--print SceneWizard.currentSelectedName
																								SceneWizard.currentSelectedIndex=SceneWizard.myLv.FocusedItem.index																								
																								SceneWizard.SelectAllBlocksAndChilds SceneWizard.currentSelectedName
																								/*
																									print SceneWizard.myLv.Items.Item[SceneWizard.currentSelectedIndex]
																									SceneWizard.myLv.Items.Item[SceneWizard.currentSelectedIndex].Selected = true
																									SceneWizard.myLv.Select()
																								*/
																							)  
																					)	
							
							dotNet.setLifetimeControl theLv #dotnet
												
			
			
		),
		
		fn UpdateToolPanel sender =
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
					mainDnFlow= dotNetObject "flowLayoutPanel"
					mainDnFlow.Flowdirection = mainDnFlow.Flowdirection.TopDown
					--dnFlow.bounds =KispTools.dnRec s:[kispTools.theContentPanel.width, kispTools.theContentPanel.height]
					mainDnFlow.BorderStyle=mainDnFlow.BorderStyle.none
					mainDnFlow.width=sender.width
					mainDnFlow.height=sender.height
					mainDnFlow.backcolor= dnColor c:[50,200,200] a:255
					sender.controls.add mainDnFlow
		
					
							--------------------------------
							--FLOW GLOBAL TOOLS
							--FLOW GLOBAL TOOLS
							--------------------------------			
							--Flow Layout		
							dnFlowGlobal= dotNetObject "flowLayoutPanel"
							dnFlowGlobal.Flowdirection = dnFlowGlobal.Flowdirection.LeftToRight
							--dnFlow.bounds =KispTools.dnRec s:[kispTools.theContentPanel.width, kispTools.theContentPanel.height]
							dnFlowGlobal.BorderStyle=dnFlowGlobal.BorderStyle.none
							dnFlowGlobal.width=sender.width-5
							dnFlowGlobal.height= 35
							dnFlowGlobal.backcolor= dnColor c:[150,150,150] a:255
							
							mainDnFlow.controls.add dnFlowGlobal							
							
									dnButton1 =SceneWizard.NewDNButton "Update List" s:[80,30]					
									dnFlowGlobal.controls.add dnButton1						
									dotNet.addEventHandler dnButton1 "click" ( fn UpdateList = ( SceneWizard.GetNewListView() ) )
									dotNet.setLifetimeControl dnButton1 #dotnet
								

									dnButton3 =SceneWizard.NewDNButton "Find in List" s:[80,30]					
									dnFlowGlobal.controls.add dnButton3						
									dotNet.addEventHandler dnButton3 "click" ( fn UpdateList = ( SceneWizard.NodeBelongsToBlock() ) )
									dotNet.setLifetimeControl dnButton3 #dotnet	

							--------------------------------
							--FLOW OBJECT TOOLS
							--FLOW OBJECT TOOLS
							--------------------------------
							
							--Flow Layout		
							dnFlowObject= dotNetObject "flowLayoutPanel"
							dnFlowObject.Flowdirection = dnFlowObject.Flowdirection.LeftToRight
							--dnFlow.bounds =KispTools.dnRec s:[kispTools.theContentPanel.width, kispTools.theContentPanel.height]
							dnFlowObject.BorderStyle=dnFlowObject.BorderStyle.none
							dnFlowObject.width=sender.width-5
							dnFlowObject.height= 100
							dnFlowObject.backcolor= dnColor c:[75,50,75] a:255

							mainDnFlow.controls.add dnFlowObject	

									
									dnButton4 =SceneWizard.NewDNButton "Replace " s:[80,30]					
									dnFlowObject.controls.add dnButton4						
									dotNet.addEventHandler dnButton4 "click" ( fn UpdateList = ( SceneWizard.ReplaceSelected SceneWizard.currentSelectedName ) )
									dotNet.setLifetimeControl dnButton4 #dotnet	


									dnButton5 =SceneWizard.NewDNButton "Rename" s:[80,30]					
									dnFlowObject.controls.add dnButton5						
									dotNet.addEventHandler dnButton5 "click" ( fn UpdateList = ( 
										SceneWizard.RenameDialog()
																				
											) )
									dotNet.setLifetimeControl dnButton5 #dotnet	

									dnButton6 =SceneWizard.NewDNButton "Move to Layer" s:[80,30]					
									dnFlowObject.controls.add dnButton6						
									dotNet.addEventHandler dnButton6 "click" ( fn UpdateList = (  ) )
									dotNet.setLifetimeControl dnButton6 #dotnet	
											
											
									
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
			
			UpdateListPanel()
			
			UpdateToolPanel sender.panel2
		),
	--------------------------------------------
	--------------------------------------------
	-- LAUNCH  UI
	-- LAUNCH  UI
	--------------------------------------------
	--------------------------------------------
	fn ui =
	(	
		rollout uiR "Kisp Scene Wizard" width:380 height:800--400
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
messageBox "This script depends on the scene having been cleaned up first\nThere shouldnt be any blocks."
		--t=windows.getChildHWND 0 "Kisp Scene Wizard"
		--UIAccessor.CloseDialog t[1]
global SceneWizard=SceneWizard()
SceneWizard.run()