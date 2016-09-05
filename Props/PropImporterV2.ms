macroscript propImporterV2
	category:"Matanga"
(	
	print "run propImporter"
	
	
	
struct PropImporterV2
(	
	--UI REFERENCES
	unInst=undefined,					--The instance of this rollout
	mainSplitContainer= undefined,
	myLV = undefined,
	myComboBox = undefined,

	--Utilities
	propsRootPath ="\\\\COMPARTIDA\Renderings\Resources\KispTools_Props",		--Root folder of all the props	
	maxBackColor=colorMan.getColor #background,
	
	--The selected indeces
	theCategoryIndex= -1,
	selectedItem=undefined, 		--The currently selected Item

	--CATEGORIES VARIABLES
	myCategories=#(),				--Array con las categorias
	myCategoriesNames=#(),		--Array con los nombres de las categorias
	
	--PROPS VARIABLES
	myProps=#(),		
	myPropsNames=#(),	
	myPropsImages=#(),
	
	--------------------------------------------
	-- DOTNET UTILITIES
	-- DOTNET UTILITIES
	--------------------------------------------
		include "\\\\COMPARTIDA\Renderings\Resources\KispTools\KispToolsUtils.ms" 

		fn dnImageList theImagesPaths =
		(
			theImageList = dotNetObject "ImageList"
			theImageList.ColorDepth = theImageList.ColorDepth.Depth24Bit
			theImageList.ImageSize = dnSize s:[75,75]		
			
			for imagePath in theImagesPaths do 
			(
				thumb = dotNetObject "System.Drawing.Bitmap" imagePath
				theImageList.images.add thumb
			)	
			
			theImageList		
		),

	--------------------------------------------
	--------------------------------------------
	-- TOOLS SCRIPTS
	-- TOOLS SCRIPTS
	--------------------------------------------
	--------------------------------------------
		--Funcion que encuentra todas las carpetas que van a ser las categorias
		fn GetCategories=
		(		
			
			dotDirectory = dotNetClass "System.IO.Directory"									--Dotnet Object Directory
			dotPath = dotNetClass "System.IO.Path"												--Dotnet Object Path
			
			myCategories=dotDirectory.GetDirectories(propsRootPath)		--Referencio todas las carpetas dentro de la carpeta de categorias
			for o in myCategories do												
			(					
				append 	myCategoriesNames ( dotPath.GetFileName( o))		--Guardo sus nombres en un array
			)
		),
		
		--Get all the path for the files with the given extension in the given path
		fn GetFilesFromPath thePath theExtension =
		(
			--theFiles = getFiles ((thePath)+"\\*.jpg" )					--Referencio los archivos max demtro del path en el array myProps
			theFiles = getFiles ((thePath)+theExtension )					--Referencio los archivos max demtro del path en el array myProps
			theFiles
		),
		
		--GET ALL MAX FILES FROM THE GIVEN PATH INTO AN ARRAY
		fn GetMaxFilesFromPath thePath =
		(
			PropImporterV2.myProps=#()															--Vacio el array de props
			PropImporterV2.myPropsNames=#()													--Vacio el array de nombres de props
			PropImporterV2.myProps = getFiles ((thePath)+"\\*.max" )					--Referencio los archivos max demtro del path en el array myProps
			
			dotPath = dotNetClass "System.IO.Path"						--Dotnet Object Path
			for o in myProps do													--Referencio los nombres(string) de los archivos en myProps
			(	
				append 	PropImporterV2.myPropsNames ( dotPath.GetFileNameWithoutExtension(o))	
			)
			
			PropImporterV2.myPropsNames
		),

		
		--FUNCTION THAT POPULATES THE MAIN LIST VIEW 
		fn PopulateList theLv thePath=
		(
			PropImporterV2.myLV.clear()		
			
			--Get all the Max files paths and names from the given path
			propList = PropImporterV2.GetMaxFilesFromPath thePath 
			
			--Get all the jpg files from the same path			
			PropImporterV2.myPropsImages = GetFilesFromPath thePath "\\*.jpg"
			
			--Creo la lista de imagenes
			theLv.SmallImageList = dnImageList PropImporterV2.myPropsImages			

			--Agrego los items a la lista
			for x =1  to propList.count do
			(
				theLv.items.add myPropsNames[x] (x-1)		--Add the array of rows to the listView control. 		
				theLv.items.item[x-1].backcolor= dnColor c:[20,50,60] a:255
				print theLv.items.item[x-1].index
			)			
		),
		
		
	--------------------------------------------
	--------------------------------------------
	-- MAIN PANELS
	-- MAIN PANELS
	--------------------------------------------
	--------------------------------------------
	fn DrawHeader =
	(
					--------------------------------
					--FLOW LAYOUT
					--FLOW LAYOUT
					--------------------------------
					/*Create the flow layout*/dnFlowHorizontal= dotNetObject "flowLayoutPanel"
					/*Set the backcolor*/dnFlowHorizontal.backColor= dnColor c:(PropImporterV2.maxBackColor*255) a:255
					/*Set the flow direction*/dnFlowHorizontal.Flowdirection = dnFlowHorizontal.Flowdirection.TopDown
					/*Set the bounds*/dnFlowHorizontal.bounds =PropImporterV2.dnRec s:[PropImporterV2.mainSplitContainer.panel1.width, PropImporterV2.mainSplitContainer.panel1.height]
					/*Set the border style*/dnFlowHorizontal.BorderStyle=dnFlowHorizontal.BorderStyle.none
		
					/*Add it to its parent`s controls*/PropImporterV2.mainSplitContainer.panel1.controls.add dnFlowHorizontal
							
							--------------------------------
							--LABEL
							--LABEL
							--------------------------------
							/*Create the label*/theCategoryLabel = dotnetObject"label"
							/*Set the height*/theCategoryLabel.height=dnFlowHorizontal.height
							/*Set the width*/theCategoryLabel.width=90
							/*Set the Text*/theCategoryLabel.text= "Categories"
							/*Set the font*/theCategoryLabel.font= dotNetObject("System.Drawing.Font") "Times new roman" 13
							/*Align the text*/theCategoryLabel.textalign= theCategoryLabel.textalign.MiddleLeft

							/*Add it to its parent`s controls*/dnFlowHorizontal.controls.add theCategoryLabel
														
							--------------------------------
							--COMBO BOX
							--COMBO BOX
							--------------------------------
							/*Create the combo box*/theComboBox= dotnetObject "Combobox"							
							/*Set the margins*/theComboBox.margin= PropImporterV2.dnPadding l:0 t:8 r:0 b:0							
							/*Set the height*/theComboBox.height=dnFlowHorizontal.height								
							/*Set the width*/theComboBox.width=100							
							/*Set the dropdown style*/theComboBox.dropdownstyle = theComboBox.dropdownstyle.DropDown							
							/*Add the items*/theComboBox.items.addRange myCategoriesNames						
							/*Add it to its parent`s controls*/dnFlowHorizontal.controls.add theComboBox
							
							/*Set the current selected index in the combobox based on the reference in the struct*/theComboBox.selectedIndex=PropImporterV2.theCategoryIndex
							
							/*SET THE REFERENCE FOR THE COMBOBOX IN THE STRUCT*/myComboBox=theComboBox
					
							
							dotNet.addEventHandler theComboBox "SelectedIndexChanged" ( fn ChangedSelectedCategory = 
																														(
																															/*Update the current Index*/PropImporterV2.theCategoryIndex=PropImporterV2.myComboBox.selectedIndex					
																															PropImporterV2.UpdateUI()
																															--PropImporterV2.PopulateList PropImporterV2.myLV PropImporterV2.myCategories[PropImporterV2.myComboBox.selectedIndex+1]	
																														)  
																												)				
		
		
		
	),
	
	fn DrawContent =
	(
			--------------------------------
			--SPLIT CONTAINER
			--SPLIT CONTAINER
			--------------------------------
					myPanel2SplitCon = dotNetObject "splitContainer"
					myPanel2SplitCon.bounds =KispToolsV3.dnRec s:[PropImporterV2.mainSplitContainer.panel2.width, PropImporterV2.mainSplitContainer.panel2.height-5]

					--myPanel2SplitCon.backColor =dnColor c:(maxBackColor*255) a:255
					myPanel2SplitCon.orientation = myPanel2SplitCon.orientation.horizontal
					myPanel2SplitCon.splitterDistance=450
					myPanel2SplitCon.splitterWidth=5
					myPanel2SplitCon.isSplitterFixed=true
				
					PropImporterV2.mainSplitContainer.panel2.controls.add myPanel2SplitCon

							--------------------------------
							--------------------------------
							--LISTVIEW
							--LISTVIEW
							--------------------------------
							--------------------------------
							--Setup the forms view
							theLv= dotNetObject "ListView"		
							theLv.width=PropImporterV2.mainSplitContainer.panel2.width
							theLv.height=PropImporterV2.mainSplitContainer.panel2.height-40

							theLv.view=(dotNetClass "system.windows.forms.view").SmallIcon
							theLv.FullRowSelect=true		--Set so full width of listView is selected and not just first column.
							theLv.GridLines=true				--Show lines between the items. 
							theLv.MultiSelect=false			--Only one item can be selected 
							
							theLv.Alignment   = theLv.Alignment.Top
							theLv.AutoArrange = true
							
							PropImporterV2.myLV= theLV
																																	
							theLv.Columns.add "Image" 164
							theLv.Columns.add "Name" 196																										
							
						
							--Add the LV control to the panel
							myPanel2SplitCon.panel1.controls.add theLv							
							
							
							dotNet.addEventHandler theLv "ItemSelectionChanged" ( fn ChangeSelectedItem = 
																							(
																								if(PropImporterV2.myLV.FocusedItem != undefined) do
																								(
																									--print("ItemSelectionChanged "+ PropImporterV2.myLV.FocusedItem.index as string)
																									--print("The item Path: "+ PropImporterV2.myProps[PropImporterV2.myLV.FocusedItem.index+1])
																									PropImporterV2.selectedItem=PropImporterV2.myProps[PropImporterV2.myLV.FocusedItem.index+1]																									
																								)
																							)  
																					)		
							dotNet.setLifetimeControl theLv #dotnet
							
							--------------------------------
							--------------------------------
							--PANEL 2 BUTTONS FLOW HORIZONTAL
							--PANEL 2 BUTTONS FLOW HORIZONTAL
							--------------------------------
							--------------------------------
							
							Panel2FlowHorizontal= dotNetObject "flowLayoutPanel"
							Panel2FlowHorizontal.backColor= dnColor c:[125,98,205] a:255
							Panel2FlowHorizontal.Flowdirection = Panel2FlowHorizontal.Flowdirection.LeftToRight
							Panel2FlowHorizontal.bounds =PropImporterV2.dnRec s:[myPanel2SplitCon.panel2.width, myPanel2SplitCon.panel2.height]
							Panel2FlowHorizontal.BorderStyle=Panel2FlowHorizontal.BorderStyle.none
							
							--Add the control to its Parent
							myPanel2SplitCon.panel2.controls.add Panel2FlowHorizontal
									
									--------------------------------
									--------------------------------
									--BUTTON PLACE SINGLE
									--BUTTON PLACE SINGLE
									--------------------------------
									--------------------------------					
							
										--Create a new Button 
									PlaceSingleButton = dotNetObject "button"
									--Set the Text
									PlaceSingleButton.text="Place Single"
									--Set the size
									PlaceSingleButton.Size = dnSize s:[80, 30]		
									--Set the Margin
									PlaceSingleButton.Margin= PlaceSingleButton.Margin.empty
									
									
									--Set the backcolor
									PlaceSingleButton.backcolor = dnColor c:[200,200,200] a:255
									--Set Hover Colors
									PlaceSingleButton.flatStyle=PlaceSingleButton.flatStyle.popup
									
									Panel2FlowHorizontal.controls.add PlaceSingleButton
								
									dotNet.addEventHandler PlaceSingleButton "MouseDown" ( fn PlaceSelectedItem eve = 
																																	(		
																																		
																																			global thePlane = Plane length:10000 lengthsegs:1 width:10000 widthsegs:1 pos:[0,0,0] isSelected:off name:"plainito" wirecolor:(color 128 128 128)
																																			myMaterial= StandardMaterial()
																																			myMaterial.opacity=0
																																			thePlane.material=myMaterial	
																																																															
																																			--DEFINE THE OBJECT TO BE PLACED
																																			mergemaxfile PropImporterV2.selectedItem  #select #mergeDups #useSceneMtlDups    -- Merge in the objects and select them																																			
																																			--Declare the global for the tool
																																			global importedProp =selection[1]	
																																			global startMousePos= Mouse.pos.x
																																			global propPlaced=false
																																			global placeMultiple=false
																																			global aborted=false

																																		
																																			--Run the Tool
																																			fileIn "\\\\COMPARTIDA\Renderings\Resources\KispTools\Scripts\Props\Tool_PlaceProp.ms"
																																			--startTool PlaceProp prompt:"Hello!"	

																																	)  
																																)
									dotNet.setLifetimeControl PlaceSingleButton #dotnet
																																
	),
	
	fn UpdateUI =
	(
		
		/*Clear all controls in the  panel1*/PropImporterV2.mainSplitContainer.panel1.controls.clear()
		/*Clear all controls in the  panel2*/PropImporterV2.mainSplitContainer.panel2.controls.clear()
		
		--Main rollout
		/*Set the height*/PropImporterV2.mainSplitContainer.height=600
		/*Set the splitter distance*/PropImporterV2.mainSplitContainer.splitterDistance=40
		/*Set the splitter widjt*/PropImporterV2.mainSplitContainer.splitterWidth=2
		/*Fix the splitter*/PropImporterV2.mainSplitContainer.isSplitterFixed=true
		
		
		--Update rollout size
		if(propImporterV2.theCategoryIndex != -1 )do
		(
			PropImporterV2.unInst.height=600
		)		

		------------------------
		--Draw header	
		--Draw header				
		------------------------
		DrawHeader()						
			
		------------------------
		--Draw Content	
		--Draw Content	
		------------------------
		if(propImporterV2.theCategoryIndex != -1 )do
		(
			DrawContent()
			PropImporterV2.PopulateList PropImporterV2.myLV PropImporterV2.myCategories[PropImporterV2.myComboBox.selectedIndex+1]	
		)			
	),
	
	fn InitUI sender =
	(			
			--------------------------------
			--INITIAL SETUP 
			--INITIAL SETUP 
			--------------------------------	
			sender.panel1.backColor =dnColor c:(PropImporterV2.maxBackColor*255) a:255
			sender.panel2.backColor =dnColor c:(PropImporterV2.maxBackColor*255) a:255
			sender.orientation = sender.orientation.horizontal
			
			--SET THE UI REFERENCES IN THE STRUCT
			PropImporterV2.mainSplitContainer= sender		
	),
	
	--------------------------------------------
	--------------------------------------------
	-- LAUNCH  UI
	-- LAUNCH  UI
	--------------------------------------------
	--------------------------------------------
	fn ui =
	(	
		rollout PropImporter "Prop Importer" width:200 height:40
		(
			
			dotnetcontrol splitCon "system.windows.forms.splitContainer"  \
			width: (PropImporter.width)\
			height:(PropImporter.height)\
			offset:[-13,-5]

			
			on PropImporter open do
			(
				GetCategories()
				InitUI splitCon
				PropImporterV2.UpdateUI()

			)
			
		)		
		
		createDialog PropImporter
		unInst =PropImporter
	),
	
	fn run=
	(
		if(unInst == undefined) then
		(
			ui()
		)
		else
		(
			destrotDialog unInst
			unInst=undefined
		)
		
	)
	
)

global PropImporterV2=PropImporterV2()
PropImporterV2.run()
)