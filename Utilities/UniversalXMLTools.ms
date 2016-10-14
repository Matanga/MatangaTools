macroscript UniversalXMLTools 
	Category:"Matanga"
(

		local RLTUniversalXMLTools = undefined
		local RLTUniversalXMLNodeVisualizer
		local RLTVisualizeSingleNode = undefined
	
		local myXMLTools = undefined
	
		--XML CREATOR VARIABLES
		local newXMLSavePath= undefined
		local theSubNodesCount = undefined
		local subNodesNames = #()
		local newNode= undefined
		local currentSubNodeCounter= undefined
		local currentSubNode = undefined
	
		--XML EDITOR VARIABLES
		local currentSelected= undefined

	
	
		struct XMLTools
		(
			myDBPath=undefined,
			myDB=undefined,
			myRootNode = undefined,

			
			function Initialize thePath =
			(
				myDBPath=thePath
				
				myDB = XMLDocument()				
				myDB.LoadXML myDBPath
				myRootNode=myDB.GetRootNode()
				
				print ( myRootNode.GetTag())
			),
			
			
			function CheckAllChildrenAreEqual =
			(
			
				allChildren= myRootNode.getChildren()
				theName= allChildren[1].GetTag()
				
				subChilds=allChildren[1].GetChildren()
				theChildCount= 	subChilds.count
				
				allEqual=true
				
				for o=2 to allChildren.count by 1 do
				(
				
					if(allChildren[o].GetTag() != theName ) then
					(
						print ("node "+ o as string + " has  different name")
						allEqual=false
					)					
					subChilds=allChildren[o].GetChildren()
					
					if(subChilds.count != theChildCount) then
					(
						print ("node "+ o as string + " has different child count")
						allEqual = false
					)					
					
				)
				
				allEqual
			),
			
			function GetChildHierarchy =
			(
				allChildren= myRootNode.getChildren()
				theChild= allChildren[1].GetTag()
				
				subChilds=allChildren[1].GetChildren()
				
				theHierarchy= #()

				for o in subChilds do
				(
						append theHierarchy (o.GetTag())
				)
				theHierarchy
			),	

			function GetAllChildsList =
			(
				theList=#()
				
				theHierarchy = GetChildHierarchy()
				
				allChildren= myRootNode.getChildren()
				
				counter=0
				
				for o in allChildren do
				(
					append theList (counter as string)
					counter+=1
				)
				theList
				
			)

			
			
		)
	
		function GetXMLPath =
		(
			theDialog = dotNetObject "System.Windows.Forms.OpenFileDialog" --create a OpenFileDialog
			theDialog.title = "Select the file" --set the title
			theDialog.Multiselect = false --allow multiple files to be selected
			theDialog.Filter = "XML Files (*.xml)|*.xml|All Files (*.*)|*.*" --specify the filter
			theDialog.FilterIndex = 1 --set the filter drop-down list to All Files
			result = theDialog.showDialog() --display the dialog, get result into variable
			result.ToString() --when closed, convert the result to string
			result.Equals result.OK --returns TRUE if OK was pressed, FALSE otherwise
			result.Equals result.Cancel --returns TRUE if Cancel was pressed, FALSE otherwise
			theFilename = theDialog.fileNames --the selected filenames will be returned as an array		
			
			--print theFilename
			--print (result.Equals)
			if(theFilename != undefined) then theFilename[1]
										 else "undefined"
		)

		function GetFolderPath =
		(
			theDialog = dotNetObject "System.Windows.Forms.FolderBrowserDialog" --create a OpenFileDialog
			
			result = theDialog.showDialog() --display the dialog, get result into variable
			
			print (theDialog.SelectedPath)
			
			theDialog.SelectedPath
			/*if (!string.IsNullOrWhiteSpace(theDialog.SelectedPath))
			{
				string[] files = Directory.GetFiles(theDialog.SelectedPath);
			}*/
			
		)

		function CreateNewXml thePath theRootNode =
		(			
			--Create a new XML file
			newDB = XMLDocument()	

			newDB.file = thePath		
			newDB.loaded = True	
			rNode = newDB.getNewNode theRootNode			
			newDB.AppendNode rNode	
			
			newDB.PrettySaveXML()

			newDB
			
		)
		
		

		
		/************************************
		ROLLOUT to display the contents of any XML file as long as all Childs of the root node are equal amongst them
		*/
		rollout RLTVisualizeSingleNode "Visualize Single Node"
		(
			
		)

		/************************************
		ROLLOUT to display the contents of any XML file as long as all Childs of the root node are equal amongst them
		*/
		rollout RLTUniversalXMLNodeVisualizer "Node Visualizer"
		(
			fn initLv theLv=
			(
				--Setup the forms view
				theLv.view=(dotNetClass "system.windows.forms.view").details
				theLv.FullRowSelect=true		--Set so full width of listView is selected and not just first column.
				theLv.GridLines=true			--Show lines between the items. 
				theLv.MultiSelect=false			--Allow for multiple selections. 
			)	
			fn addColumns theLv columnsAr=
			(
				w=(theLv.width/columnsAr.count)-1
				for x in columnsAr do
				(
					theLv.columns.add x w
				)
			)
			fn populateList theLv=
			(
				rows=#()		--Empty array to collect rows of data
				allChildren = myXMLTools.myRootNode.getChildren()
				
				theHierarchy = myXMLTools.GetChildHierarchy()
				
				for x in allChildren do		--Loop through all the objects in the scene. 
				(
					
					li=dotNetObject "System.Windows.Forms.ListViewItem" ((x.GetChild(0)).GetText())		--Create a listViewItem object and name it. 
					
					for o= 1 to theHierarchy.count-1 by 1 do						
					(
						li.subitems.add ((x.GetChild(o)).GetText())		--Add data to the second column.						
					)
					
					append rows li		--Added the listViewItem to the rows array	
				)
				theLv.items.addRange rows		--Add the array of rows to the listView control. 
			)			
			label lblFromDB ""

			dotNetControl lv "system.windows.forms.listView" height:270

	
			on RLTUniversalXMLNodeVisualizer open do
			(
				initLv lv
				addColumns lv (myXMLTools.GetChildHierarchy())
				populateList lv
			)
			
		)
	
		Rollout RLTUniversalXMLTools "Universal XML Tools"
		(	
			subrollout SRLTHolder "Project Name"		
		)
		
		--ROLLOUT WITH THE XML READER  UI 
		rollout SRLTXMLReader "XML Reader"
		(
			--Project Number
			button btn_LoadXML "Load XML" width:340 tooltip:""
			
			label lblRootNodeName "Root Node Name : " across:4 align:#left offset:[0,15]
			label lblRootNodeNameVal "" offset:[0,15]
			
			label lblChildCount "Child Count : " align:#left offset:[0,15]
			label lblChildCountVal "" offset:[0,15]
			
			label lblAllNodesEqual "Clone Childs:" across:5 align:#left 
			label lblAllNodesEqualVal "" align:#left 
			
			label lblChildHierarchy "Hierarchy :" align:#left 
			dropdownList dd_ChildHierarchy "" items:(#()) align:#left 
			
			button btnShowXML "Show Full" enabled:false

			on btnShowXML pressed do
			(
					CreateDialog RLTUniversalXMLNodeVisualizer width:450 height:300
			)				
				
			on btn_LoadXML pressed do
			(
				theVal= GetXMLPath()
				if(theVal == undefined ) then
				(
					
				)				
				else
				(
					--GET REFERENCES
					myXMLTools=XMLTools()
					myXMLTools.Initialize theVal
					
					--UPDATE UI
					btn_LoadXML.text = theVal
					btn_LoadXML.tooltip = theVal
					lblRootNodeNameVal.text= myXMLTools.myRootNode.GetTag()
					allChildren= myXMLTools.myRootNode.getChildren()
					lblChildCountVal.text = allChildren.count as string
					
					lblAllNodesEqualVal.text= myXMLTools.CheckAllChildrenAreEqual() as string
					
					dd_ChildHierarchy.items = myXMLTools.GetChildHierarchy()
					
					if(myXMLTools.CheckAllChildrenAreEqual() ) 	then btnShowXML.enabled=true
																else  btnShowXML.enabled=false
					
				)
			)
		)
		
		--ROLLOUT WITH THE XML CREATOR  UI 
		rollout SRLTXMLCreator "XML Creator"
		(
			
			--FILE OPTIONS
			button btnGetFolder "Get Folder" across:2 align:#left	offset:[0,15]			
			label lblSavePath ""  width:250 align:#right offset:[0,18]

			editText et_DatabaseName "Database Name : " align:#left 
			
			label lblFinalName "Final:" across:2 align:#left
			label lblFinalNameVal "" align:#left offset:[-135,0]
			
			on btnGetFolder pressed do
			(
				newXMLSavePath = GetFolderPath()
				lblSavePath.text = newXMLSavePath
				lblFinalNameVal.text=lblSavePath.text+"\\"+lblFinalNameVal.text+".xml"
			)			
			
			--CONTENT OPTIONS			
			
			editText etRootNodeName  "Root Node Name:" align:#left offset:[0,30]

			editText etChildNodeName  "Child Node Name:" align:#left 
			
			spinner spnSubNodeCount "Sub Node Count: " range:[0,10,0] type:#integer align:#left width:100 across:2
			
			dropdownlist ddTheSubNodes "" items:#() align:#right width:150
			
			editText etNewSubNodeName "" align:#right width:150
			
			button btnCreateDB "Create" align:#middle width:120 height:40
			
			groupBox group1 "File Options" pos:[5,5] width:350 height:90

			groupBox group2 "Content Options" pos:[5,100] width:350 height:160


			on spnSubNodeCount changed val do
			(
				if(val==0) then
				(
					etNewSubNodeName.enabled=false
				)
				else
				(
					etNewSubNodeName.enabled=true
				)
				
				
				theSubNodesCount = val
				subNodesNames = #()
				for o=1 to theSubNodesCount by 1 do
				(
					append subNodesNames "SubNode"
				) 
				ddTheSubNodes.items= subNodesNames
			)

			on et_DatabaseName changed val do
			(
				lblFinalNameVal.text=lblSavePath.text+"\\"+val+".xml"
			)
			
			on ddTheSubNodes selected val do
			(
				etNewSubNodeName.text = ddTheSubNodes.selected
			)
			
			on etNewSubNodeName changed val do
			(
				subNodesNames[ddTheSubNodes.selection]= val
				ddTheSubNodes.items=subNodesNames
			)
			
			on btnCreateDB pressed do
			(
				--print (lblFinalNameVal.text)
				--print  (etRootNodeName.text)
				newDB=CreateNewXml (lblFinalNameVal.text) (etRootNodeName.text)
				if(spnSubNodeCount.value>0)then
				(
					theRootNode= newDB.GetRootNode()
					
					templateNode= newDB.getNewNode etChildNodeName.text	
					
					theRootNode.AppendNode templateNode	
					
					for o in subNodesNames do
					(
						newNode= newDB.getNewNode o
						templateNode.AppendNode newNode	
					)
				)					
			
				newDB.PrettySaveXML()
				newDB				
			)
			

		)	

		--ROLLOUT WITH THE XML EDITOR  UI 
		rollout SRLTXMLEditor "XML Editor"
		(
			--LOAD AND READ UI OPTIONS
			--LOAD AND READ UI OPTIONS
			--LOAD AND READ UI OPTIONS

			button btn_LoadXML "Load XML" width:340 tooltip:"" offset:[0,15]	
			
			label lblRootNodeName "Root Node Name : " across:4 align:#left offset:[0,15]
			label lblRootNodeNameVal "" offset:[0,15]
			
			label lblChildCount "Child Count : " align:#left offset:[0,15]
			label lblChildCountVal "" offset:[0,15]
			
			label lblAllNodesEqual "Clone Childs:" across:5 align:#left 
			label lblAllNodesEqualVal "" align:#left 
			
			label lblChildHierarchy "Hierarchy :" align:#left 
			dropdownList dd_ChildHierarchy "" items:(#()) align:#left 
			
			button btnShowXML "Show Full" enabled:false

			--ADD NODE UI	OPTIONS
			--ADD NODE UI	OPTIONS
			--ADD NODE UI	OPTIONS

			button btnAddNode "New Node" offset:[-5,32] align:#left enabled:false across:5
				
			label lblSubNode "Sub Node : " offset:[0,35] align:#left
			label lblCurrSubnode "Value Val" offset:[-10,35] align:#left 
			editText etCurrSubNodeText offset:[0,35]align:#left enabled:false width:90
			button btnNextAction "Next" offset:[0,32] align:#right enabled:false
				
			--REMOVE NODE UI	OPTIONS
			--REMOVE NODE UI	OPTIONS
			--REMOVE NODE UI	OPTIONS	
				
			label lblTheChilds "Children:" across:4 align:#left offset:[0,32]
			dropdownList ddlTheChilds "" align:#left enabled:false offset:[-25,30] width:100
			button btnViewChildData "View" enabled:false align:#left offset:[0,30]
			button btnRemoveChild "Remove" enabled:false align:#right offset:[0,30]
				
				
			--GROUPS
			--GROUPS
			--GROUPS
			groupBox group1 "Load/Read" pos:[5,5] width:350 height:110
			groupBox group2 "Add Node" pos:[5,120] width:350 height:50	
			groupBox group3 "Remove Node" pos:[5,175] width:350 height:50	

		
				
			--LOAD AND READ UI EVENTS
			--LOAD AND READ UI EVENTS
			--LOAD AND READ UI EVENTS
			on btnShowXML pressed do
			(
					CreateDialog RLTUniversalXMLNodeVisualizer width:450 height:340
			)
			
			on btn_LoadXML pressed do
			(
				theVal= GetXMLPath()
				if(theVal != undefined ) then
				(
					--GET REFERENCES
					myXMLTools=XMLTools()
					myXMLTools.Initialize theVal
					
					--UPDATE UI
					btn_LoadXML.text = theVal
					btn_LoadXML.tooltip = theVal
					lblRootNodeNameVal.text= myXMLTools.myRootNode.GetTag()
					allChildren= myXMLTools.myRootNode.getChildren()
					lblChildCountVal.text = allChildren.count as string					
					lblAllNodesEqualVal.text= myXMLTools.CheckAllChildrenAreEqual() as string
					
					dd_ChildHierarchy.items = myXMLTools.GetChildHierarchy()
					
					if(myXMLTools.CheckAllChildrenAreEqual() ) 	then btnShowXML.enabled=true
																else  btnShowXML.enabled=false
					
					etCurrSubNodeText.enabled=true
					btnAddNode.enabled=true
					
					subNodesNames = myXMLTools.GetChildHierarchy()
					
					
					--REMOVE OPTIONS
					ddlTheChilds.items = myXMLTools.GetAllChildsList()
					ddlTheChilds.enabled=true
					btnRemoveChild.enabled=true
				)
			)
				
			--ADD NODE UI	EVENTS
			--ADD NODE UI	EVENTS
			--ADD NODE UI	EVENTS
			on btnNextAction pressed do 
			(
				--Si el counter es menor a la cantidad de subnodos
				if(currentSubNodeCounter < subNodesNames.count) then
				(
					--Si hay texto para agregar al subnodo
					if(etCurrSubNodeText.text != "") then
					(
						--print ("Adding  to subnode "+currentSubNode.GetTag()+" the text "+etCurrSubNodeText.text)
						currentSubNode.SetText (etCurrSubNodeText.text)
						currentSubNodeCounter+=1
					
						currentSubNode =	myXMLTools.myDB.GetNewNode (subNodesNames[currentSubNodeCounter])	
						newNode.AppendNode currentSubNode	
						
						lblCurrSubnode.text = subNodesNames[currentSubNodeCounter]
						etCurrSubNodeText.text =""
						
						if(currentSubNodeCounter < subNodesNames.count)do
						(
							btnNextAction.text="Add"
						)
					)
				)
				else
				(
					print ("Saving New Node")
					currentSubNode.SetText (etCurrSubNodeText.text)

					myXMLTools.myRootNode.AppendNode newNode
					
					myXMLTools.myDB.PrettySaveXML()
					currentSubNodeCounter=1
					btnNextAction.enabled=false
					btnNextAction.text="Next"					
					btnAddNode.enabled=true	
				)

			)
			on 	btnAddNode pressed do
			(
				
				newNode=myXMLTools.myDB.GetNewNode ((myXMLTools.myRootNode.GetChild (0)).GetTag())
				currentSubNodeCounter=1
				
				currentSubNode =	myXMLTools.myDB.GetNewNode (subNodesNames[currentSubNodeCounter])	
				newNode.AppendNode currentSubNode	
	
				lblCurrSubnode.text = subNodesNames[currentSubNodeCounter]
					
				btnAddNode.enabled=false
				btnNextAction.enabled=true
			)
				
				
			--REMOVE NODE UI	EVENTS
			--REMOVE NODE UI	EVENTS
			--REMOVE NODE UI	EVENTS	
				
			on ddlTheChilds selected val do 
			(
				print val
			)
			on btnRemoveChild pressed do
			(
				try(DestroyDialog RLTVisualizeSingleNode)catch()
				
				myXMLTools.myRootNode.DeleteChild (myXMLTools.myRootNode.GetChild(ddlTheChilds.selection-1))
				myXMLTools.myDB.PrettySaveXml()
					
					--GET REFERENCES
				myXMLTools.Initialize (myXMLTools.myDBPath)
					
				--UPDATE UI
				btn_LoadXML.text = myXMLTools.myDBPath
				btn_LoadXML.tooltip = myXMLTools.myDBPath
				lblRootNodeNameVal.text= myXMLTools.myRootNode.GetTag()
				allChildren= myXMLTools.myRootNode.getChildren()
				lblChildCountVal.text = allChildren.count as string					
				lblAllNodesEqualVal.text= myXMLTools.CheckAllChildrenAreEqual() as string
				
				dd_ChildHierarchy.items = myXMLTools.GetChildHierarchy()
				
				if(myXMLTools.CheckAllChildrenAreEqual() ) 	then btnShowXML.enabled=true
															else  btnShowXML.enabled=false
				
				etCurrSubNodeText.enabled=true
				btnAddNode.enabled=true
				
				subNodesNames = myXMLTools.GetChildHierarchy()
				
				
				--REMOVE OPTIONS
				ddlTheChilds.items = myXMLTools.GetAllChildsList()
				ddlTheChilds.enabled=true					
					
			)



			
		)	




		
		on execute do
		(
			
			--Try to destroy the Rollout in case it already exists
			try(t=windows.getChildHWND 0 "Universal XML Tools"
			UIAccessor.CloseDialog t[1])catch()
			
			--Create the Rollout
			createDialog RLTUniversalXMLTools width:400 height:420 
			
			--Add the XML Universal Reader SubRollout
			AddSubRollout RLTUniversalXMLTools.SRLTHolder SRLTXMLReader
			RLTUniversalXMLTools.SRLTHolder.SRLTXMLReader.open=false
			--Add the XML Universal Creator SubRollout
			AddSubRollout RLTUniversalXMLTools.SRLTHolder SRLTXMLCreator
			RLTUniversalXMLTools.SRLTHolder.SRLTXMLCreator.open=false
			--Add the XML Universal Creator SubRollout
			AddSubRollout RLTUniversalXMLTools.SRLTHolder SRLTXMLEditor
	
			
			
			RLTUniversalXMLTools.SRLTHolder.height += 420			
		)		
	
)