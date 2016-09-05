
struct SceneWizard
(
	myInst=undefined,	
	--------------------------------------------
	--------------------------------------------
	-- TOOL VARIABLES
	-- TOOL VARIABLES
	--------------------------------------------
	--------------------------------------------	
	
		allObjects=#(),				--FIXED

		allObjectsArrays=#(),	
				
	
		currentClassifyMode=undefined,		--The currentWay in wich the objects were classified ///  1== By Name // 2 == By Instance
		currentIndex=undefined,
	
	
		-------------------------------------------
		---Replace Tool Variables
		-----------------------------------------
		replaceSuccesful=false,
		replaceCanceled=false,
		newPositions = #(),
		newRotations = #()	,
		createdObjects = #(),
		translateOffset=[0,0,0],
		rotateOffset=(EulerAngles 0 0 0),

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
		
	
	--------------------------------------------
	--------------------------------------------
	-- DOTNET UTILITIES
	-- DOTNET UTILITIES
	--------------------------------------------
	--------------------------------------------	
		include "\\\\COMPARTIDA\Renderings\Resources\KispTools\KispToolsUtils.ms" 	
	
	--------------------------------------------
	--------------------------------------------
	-- TOOL METHODS
	-- TOOL METHODS
	--------------------------------------------
	--------------------------------------------

		/************************************
			USE: Attempts to find and select the item in the list that represents the picked object
		*/
		fn FindObjectInList =
		(			
			theObj= PickObject()	
			if(theObj != undefined) do 	--If the object exists
			(
				if (SceneWizard.currentClassifyMode==2) do		--If the scene is classified by instance
				(
					theIndex=1
					matchFound=false
					for o in allObjects do
					(
						if(matchFound==false)do
						(
							if(theObj.baseobject == o.baseobject) 	then matchFound=true
																	else theIndex=theIndex+1																		
						)
					)
					--This Highlights the Item
					SceneWizard.myLV.FocusedItem= SceneWizard.myLV.Items.Item[theIndex-1]
					SceneWizard.myLV.Items.Item[theIndex-1].Selected = true;
					SceneWizard.currentIndex=theIndex
				)
				if (SceneWizard.currentClassifyMode==1) do		--If the scene is classified by name
				(
					theIndex=1
					matchFound=false
					for o in allObjects do
					(
						if(matchFound==false)do
						(
							if(theObj.name == o.name) 	then matchFound=true
														else theIndex=theIndex+1																		
						)
					)
					--This Highlights the Item
					SceneWizard.myLV.FocusedItem= SceneWizard.myLV.Items.Item[theIndex-1]
					SceneWizard.myLV.Items.Item[theIndex-1].Selected = true;	
					SceneWizard.currentIndex=theIndex					
				)
			)
			
		),		
		/************************************
			USE:Function to select all Objects with the provided name and its children
			ARGUMENTS : theIndex== the index in the arrays
		*/
		fn SelectAllInstances theIndex =
		(				
			newSel= SceneWizard.allObjectsArrays[SceneWizard.myLV.FocusedItem.index+1] as array 
			select newSel		
		),
		/************************************
			USE: Replace all instances of the selected object in the list
			ARGUMENTS :
		*/
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
					SelectAllInstances theName
					delete selection
					select createdObjects
					SceneWizard.GetNewListView()
				)		
			)
		),		


	--------------------------------------------
	--------------------------------------------
	-- TOOL UTILITIES
	-- TOOL UTILITIES
	--------------------------------------------
	--------------------------------------------
		
		function UpdateObjectListsByName =	
		(
			SceneWizard.currentClassifyMode=1
			SceneWizard.allObjects=#()
			SceneWizard.allObjectsArrays=#()
			
			--First find all unique Blocks
			for o in objects do
			(
				isInArray=false																--Creamos un flag para saber si el objeto ya esta en la lista
				for x in SceneWizard.allObjects do											--Por cada objeto en la lista
				(
					if( isInArray==false ) do												--Si todavia no lo encontramos ==> isInArray ==false
						if( o.name ==x.name ) do isInArray= true							--Nos fijamos si el nombre de este objeto esta en la lista										
				)
				
				if( isInArray == false ) do													--Si terminamos el loop y el objeto no estaba en la lista
				(
					append SceneWizard.allObjects o											--Agregamos el objeto a la lista
					allInstances= for x in objects where x.name ==o.name collect x
					append SceneWizard.allObjectsArrays allInstances
				)							
			)
			--print("Different Objects by name: "+ SceneWizard.allObjects.count as string )		
		),
		
		function UpdateObjectListsByInstance =	
		(			
			SceneWizard.currentClassifyMode=2
			SceneWizard.allObjects=#()
			SceneWizard.allObjectsArrays=#()
			
			for o in objects do
			(
				isInArray = SceneWizard.IsObjectInArray o
				if (isInArray == false ) do  			--Si no existe
				(
					append SceneWizard.allObjects o
					allInstances= SceneWizard.FindObjectInstances o
					append SceneWizard.allObjectsArrays (allInstances)
				)		
			)	
			--print("Different Objects by Instance: "+ SceneWizard.allObjects.count as string )		
			
		),
		
		fn FindObjectInstances theObj =
		(
			--print "Get All instances"
			InstanceMgr.GetInstances theObj &instances
			/*
			ss = #()										--Un array con la seleccion
			ss2 = #()										--Un array con la seleccion, este va a ser el array donde guardamos la seleccion final
			exclud = #(0)									--Un Array con un int =0 EXCLUD
			for i=1 to ss.count do (						--De i= 1 a ss.count
				if findItem exclud i != 0 do continue		--Si i ya esta en el array EXCLUD (el numero, salteamos el loop
				InstanceMgr.GetInstances ss[i] &instances	--Creamos un array con las instancias de este objeto
					for j in instances do (					--Por cada una de las instancias 
						k = findItem ss j					--k = tratamos de encontrar  esta instancia es un objeto que ya existe en nuestro primer array
						if k != 0 do (						--si el objeto existe en la lista
							appendIfUnique exclud k			--agregamos el indice
							continue						--Salteamos el resto del loop
						)
						if findItem ss2 j != 0 do continue	--Si el objeto ya existe en el array ss2 salteamos el resto del loop
						if j.isHiddenInVpt==false do ( 		--Si el objeto no esta escondido
							--ss2 = ss2 + j					--Lo agregamos al segundo array
							append ss2 j
						)
					)
			)
			makeUniqueArray ss2*/
			--for o in instances do print o
				
			newInstances = deepcopy instances			
			return newInstances
			
		),
		
		fn IsObjectInArray theObj =
		(
			isInArray=false
			for o in SceneWizard.allObjects do
			(
				if(isInArray==false) do
				(
					if(theObj.baseObject == o.baseObject) do isInArray = true
				)
			)
			return isInArray		
		),

	--------------------------------------------
	--------------------------------------------
	-- UI UTILITIES 
	-- UI UTILITIES 
	--------------------------------------------
	--------------------------------------------
		
		--Function that fills the ListView
		--ListType   	1 == NAME
		--			2 == INSTANCE
		fn GetNewListView listType  = 
		(
			--print("GetNewListView")
            rows=#()
			SceneWizard.myLV.Clear()
			SceneWizard.myLV.Update()
			
			SceneWizard.myLV.HideSelection = false
			
			--addColumns theLv #("Name","Image")
			if( listType==1 ) do SceneWizard.myLV.Columns.add "By Name" 225
			if( listType==2 ) do SceneWizard.myLV.Columns.add "By Instance" 225
			SceneWizard.myLV.Columns.add "Amount" 50
			SceneWizard.myLV.Columns.add "Type" 75
			
			if( listType==1 ) do SceneWizard.UpdateObjectListsByName()			---MAKE OBJECT LIST BASED ON INSTANCES
			if( listType==2 ) do SceneWizard.UpdateObjectListsByInstance()		---MAKE OBJECT LIST BASED ON NAMES
			
			
            for t=1 to SceneWizard.allObjects.count do 
			(
				li=dotNetObject "System.Windows.Forms.ListViewItem" (SceneWizard.allObjects[t].name)
				li.UseItemStyleForSubItems=true
				--The amount of instances of this block
				li.subitems.add (SceneWizard.allObjectsArrays[t].count as string )
				--The Type of this block
				li.subitems.add ( classof SceneWizard.allObjects[t] as string  )
				
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
		

		fn ReplaceDialog theIndex =
		(
			SceneWizard.currentIndex= theIndex
			SceneWizard.replaceSuccesful=false
			SceneWizard.replaceCanceled=false

			rollout RollReplaceObjects "Replace Object"
			(
				pickbutton pbTheObj "Pick New Object"  toolTip:"Object must be Geometry" align:#center
				label lblSpace ""
				label lblTranslateOffsets "Transform Offsets" align:#center				
				spinner spnTranslateX "X" width:70 align:#left range:[-100.0,100.0,0.0] across:3
				spinner spnTranslateY "Y" width:70 align:#left range:[-100.0,100.0,0.0]
				spinner spnTranslateZ "Z" width:70 align:#left range:[-100.0,100.0,0.0]
				label lblSpace2 ""
				label lblRotateOffsets "Transform Offsets" align:#center				
				spinner spnRotateX "X" width:70 align:#left range:[-180.0,180.0,0.0] across:3
				spinner spnRotateY "Y" width:70 align:#left range:[-180.0,180.0,0.0]
				spinner spnRotateZ "Z" width:70 align:#left range:[-180.0,180.0,0.0]

				button btnApply "Accept" enabled:false across:2
				button btnCancel "Cancel" enabled:false

				on pbTheObj picked val do
				(
					btnApply.enabled =true																	--Enable the ACCEPT Button
					btnCancel.enabled = true																--Enable the CANCEL Button
					for o in SceneWizard.allObjectsArrays[SceneWizard.currentIndex] do	o.isHidden =true	--Hide all the instances of the object we are going to replace
															
					SceneWizard.newPositions = #()
					SceneWizard.newRotations = #()	
					SceneWizard.createdObjects = #()
					SceneWizard.translateOffset=[0,0,0]
					SceneWizard.rotateOffset=(EulerAngles 0 0 0)
					selection= undefined
					
					for o in SceneWizard.allObjectsArrays[SceneWizard.currentIndex] do 
					(
						append SceneWizard.newPositions o.position
						append SceneWizard.newRotations (o.rotation as EulerAngles)
					)				
					for inst=1 to SceneWizard.newPositions.count do
					(
						newObj= copy val
						newObj.baseObject=val.baseObject
						if(val.material != undefined) do newObj.material=val.material
						newObj.rotation= SceneWizard.newRotations[inst]							
						newObj.position= SceneWizard.newPositions[inst]
						append SceneWizard.createdObjects newObj
					)				
				)
				on spnTranslateX changed val do
				(
					SceneWizard.translateOffset.x=val					
					for o=1 to SceneWizard.createdObjects.count by 1 do	
						SceneWizard.createdObjects[o].pos=SceneWizard.newPositions[o]+SceneWizard.translateOffset											
				)
				on spnTranslateY changed val do
				(
					SceneWizard.translateOffset.y=val						
					for o=1 to SceneWizard.createdObjects.count by 1 do
						SceneWizard.createdObjects[o].pos=SceneWizard.newPositions[o]+SceneWizard.translateOffset											
				)
				on spnTranslateZ changed val do
				(
					SceneWizard.translateOffset.z=val					
					for o=1 to SceneWizard.createdObjects.count by 1 do
						SceneWizard.createdObjects[o].pos=SceneWizard.newPositions[o]+SceneWizard.translateOffset					
				)
				on spnRotateX changed val do
				(
					SceneWizard.rotateOffset.x=val
					for o=1 to SceneWizard.createdObjects.count by 1 do
					(
						currentMatrix=SceneWizard.createdObjects[o].transform
						preRotate currentMatrix (eulertoquat (SceneWizard.rotateOffset))
						SceneWizard.createdObjects[o].transform=currentMatrix
					)
				)
				on spnRotateY changed val do
				(
					SceneWizard.rotateOffset.y=val
					for o=1 to SceneWizard.createdObjects.count by 1 do
					(
						currentMatrix=SceneWizard.createdObjects[o].transform
						preRotate currentMatrix (eulertoquat (SceneWizard.rotateOffset))
						SceneWizard.createdObjects[o].transform=currentMatrix
					)
				)
				on spnRotateZ changed val do
				(
					SceneWizard.rotateOffset.z=val
					for o=1 to SceneWizard.createdObjects.count by 1 do
					(
						currentMatrix=SceneWizard.createdObjects[o].transform
						preRotate currentMatrix (eulertoquat (SceneWizard.rotateOffset))
						SceneWizard.createdObjects[o].transform=currentMatrix
					)
				)
				
				on btnApply pressed do
				(
					SceneWizard.replaceSuccesful =true
				)
				
				on btnCancel pressed do
				(
					SceneWizard.replaceSuccesful =false
					SceneWizard.replaceCanceled=true
					for o in SceneWizard.allObjectsArrays[SceneWizard.currentIndex] do	o.isHidden =false	--Hide all the instances of the object we are going to replace
						delete SceneWizard.createdObjects 
						--delete selection
						SceneWizard.createdObjects=#()
					DestroyDialog RollReplaceObjects
				)	
				
				on RollReplaceObjects close do 
				(
					if(SceneWizard.replaceCanceled == false and pbTheObj.object != undefined ) do
					(
						for o in SceneWizard.allObjectsArrays[SceneWizard.currentIndex] do	o.isHidden =false	--Hide all the instances of the object we are going to replace
						--for o =SceneWizard.createdObjects.count to 1 by -1 do delete SceneWizard.createdObjects[o]
							delete SceneWizard.createdObjects 
							--delete selection
							SceneWizard.createdObjects=#()
					)
				)
				
			)
			
			CreateDialog RollReplaceObjects width:250 height:220
			
		),
		
		
	--------------------------------------------
	--------------------------------------------
	-- UI METHODS 
	-- UI METHODS 
	--------------------------------------------
	--------------------------------------------
		
		fn DoClassifyPanel sender =
		(
						--------------------------------
						--------------------------------
						-- STARTING OPTIONS
						-- STARTING OPTIONS
						--------------------------------
						--------------------------------	
			
							dnFlowSecondary= dotNetObject "flowLayoutPanel"
							dnFlowSecondary.Flowdirection = dnFlowSecondary.Flowdirection.LeftToRight
							dnFlowSecondary.margin = dnFlowSecondary.margin.empty							
							dnFlowSecondary.bounds =SceneWizard.dnRec s:[SceneWizard.myPanel1.width, 50]

							dnFlowSecondary.backColor =SceneWizard.dnColor c:[20,20,20] a:255
							dnFlowSecondary.BorderStyle=dnFlowSecondary.BorderStyle.none		
							
							sender.controls.add dnFlowSecondary

							--------------------------------
							-- BUTTON CLASSIFY BY NAME
							-- BUTTON CLASSIFY BY NAME
							--------------------------------
				
									dnButton1=dotNetObject "button"
									dnButton1.backColor =SceneWizard.dnColor c:[120,120,120] a:255
									dnbutton1.flatStyle=dnbutton1.flatStyle.Flat
									dnButton1.margin= dnbutton1.margin.empty
									
									dnButton1.bounds = SceneWizard.dnRec s:[190, 50]
									dnButton1.text="Classify by Name"
									
									dnFlowSecondary.controls.add dnbutton1
									dotNet.addEventHandler dnbutton1 "Click" ( fn ClassifyByName =  ( SceneWizard.GetNewListView 1 ) )	
							--------------------------------
							-- BUTTON CLASSIFY BY INSTANCE
							-- BUTTON CLASSIFY BY INSTANCE
							--------------------------------
									dnButton2=dotNetObject "button"
									dnButton2.backColor =SceneWizard.dnColor c:[120,120,120] a:255
									dnbutton2.flatStyle=dnbutton2.flatStyle.Flat
									dnButton2.margin= dnbutton2.margin.empty
									
									dnButton2.bounds = SceneWizard.dnRec s:[190, 50]
									dnButton2.text="Classify by Instance"
									
									dnFlowSecondary.controls.add dnbutton2
									dotNet.addEventHandler dnbutton2 "Click" ( fn ClassifyByInstance = (SceneWizard.GetNewListView 2 ) )
						
		),
		
		
		fn UpdateListPanel =
		(			
			--print "UpdateListPanel"		
			SceneWizard.myPanel1.backColor =dnColor c:[75,50,90] a:255			

			--------------------------------
			--------------------------------
			--MAIN FLOW
			--MAIN FLOW
			--------------------------------
			--------------------------------	

			dnFlowMain= dotNetObject "flowLayoutPanel"
			dnFlowMain.Flowdirection = dnFlowMain.Flowdirection.TopDown
			dnFlowMain.margin = dnFlowMain.margin.empty
			
			dnFlowMain.bounds =SceneWizard.dnRec s:[SceneWizard.myPanel1.width, SceneWizard.myPanel1.height]

			dnFlowMain.backColor =SceneWizard.dnColor c:[100,20,20] a:255
			dnFlowMain.BorderStyle=dnFlowMain.BorderStyle.none		
			
			SceneWizard.myPanel1.controls.add dnFlowMain	
			
			-------------------------------------------
			-----------------------------------------
			--CLASSIFY PANEL
			-------------------------------------------
			-------------------------------------------
			
			SceneWizard.DoClassifyPanel dnFlowMain

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
							theLv.height=SceneWizard.myPanel1.height-60
							theLv.margin = theLv.margin.empty							

							theLv.view=(dotNetClass "system.windows.forms.view").details
							theLv.FullRowSelect=true			--Set so full width of listView is selected and not just first column.
							theLv.GridLines=true				--Show lines between the items. 
							theLv.MultiSelect=false				--Only one item can be selected 
							theLv.AllowDrop=true
						
						
							--Add the LV control to the panel
							dnFlowMain.controls.add theLv
							
							--LLenar la lista
							--SceneWizard.GetNewListView 1
							
							dotNet.addEventHandler theLv "ItemSelectionChanged" ( fn ChangeSelectedItem = 
																							(	
																								--print "Selecting"		
																								--print SceneWizard.allObjects[SceneWizard.myLV.FocusedItem.index+1].name
																								
																								--print ("Selected Indeces count "+SceneWizard.myLV.SelectedIndices.count as string)
																								--print ("Focused item "+ SceneWizard.myLV.FocusedItem as string )
																								if(SceneWizard.myLV.FocusedItem != undefined) do
																								(
																									--print ("Focused item "+ SceneWizard.myLV.FocusedItem.index as string )
																									--select SceneWizard.allObjectsArrays[SceneWizard.myLV.FocusedItem.index+1]
																									SceneWizard.currentIndex=SceneWizard.myLV.FocusedItem.index+1
																								)
																							)  
																					)		

							dotNet.addEventHandler theLv "DoubleClick" ( fn SelectDoubleClicked = 
																							(	
																								
																								--for o in  SceneWizard.allObjectsArrays[SceneWizard.myLV.FocusedItem.index+1] do print o
																								newSel= SceneWizard.allObjectsArrays[SceneWizard.myLV.FocusedItem.index+1] as array 
																								select newSel
																								/*
																								print ("Selecting")
																								print SceneWizard.allObjectsArrays[SceneWizard.myLV.FocusedItem.index+1].count
																								--newSel= for o in SceneWizard.allObjectsArrays[SceneWizard.myLV.FocusedItem.index+1] collect o
																								select SceneWizard.allObjectsArrays[SceneWizard.myLV.FocusedItem.index+1]
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
		
					/*
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
									dotNet.addEventHandler dnButton3 "click" ( fn UpdateList = ( SceneWizard.FindObjectInList() ) )
									dotNet.setLifetimeControl dnButton3 #dotnet		

						*/

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

								--------------------------------
								--FIND IN LIST
								--FIND IN LIST
								--------------------------------

									dnButton3 =SceneWizard.NewDNButton "Find in List" s:[80,30]					
									dnFlowObject.controls.add dnButton3						
									dotNet.addEventHandler dnButton3 "click" ( fn UpdateList = ( SceneWizard.FindObjectInList() ) )
									dotNet.setLifetimeControl dnButton3 #dotnet	

								--------------------------------
								--REPLACE SELECTED
								--REPLACE SELECTED
								--------------------------------
									dnButton4 =SceneWizard.NewDNButton "Replace " s:[80,30]					
									dnFlowObject.controls.add dnButton4						
									dotNet.addEventHandler dnButton4 "click" ( fn UpdateList = ( --SceneWizard.ReplaceSelected SceneWizard.currentSelectedName 
																									try(
																										SceneWizard.ReplaceDialog (SceneWizard.myLV.FocusedItem.index+1))catch()
										) )
									dotNet.setLifetimeControl dnButton4 #dotnet	

								--------------------------------
								--RENAME SELECTED
								--RENAME SELECTED
								--------------------------------
									dnButton5 =SceneWizard.NewDNButton "Rename" s:[80,30]					
									dnFlowObject.controls.add dnButton5						
									dotNet.addEventHandler dnButton5 "click" ( fn UpdateList = ( 
															try (SelectAllInstances (SceneWizard.currentIndex) )catch()
															fileIn "\\\\COMPARTIDA\Renderings\Resources\KispTools\Scripts\Utilities\RenameToolV2.ms" 	
															macros.run "Matanga" "RenameTool"	
											) )
									dotNet.setLifetimeControl dnButton5 #dotnet	
											
								--------------------------------
								--MOVE TO LAYER
								--MOVE TO LAYER
								--------------------------------
									dnButton6 =SceneWizard.NewDNButton "Move to Layer" s:[80,30]					
									dnFlowObject.controls.add dnButton6						
									dotNet.addEventHandler dnButton6 "click" ( fn UpdateList = (
											try (SelectAllInstances (SceneWizard.currentIndex) )catch()
											fileIn "\\\\COMPARTIDA\Renderings\Resources\KispTools\Scripts\Utilities\LayerUtility.ms" 	
											macros.run "Matanga" "LayerUtility"		
										) 
									)
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
			GC()
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

	SceneWizard=SceneWizard()
	SceneWizard.run()