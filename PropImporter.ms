macroscript propImporter
	category:"Matanga"
(	
		try(DestroyDialog PropLister)catch()		--Destruyo el dialog si es que ya existe
	
		local PropLister							--El nombre del Rollout
		local propPos								--El lugar donde va a aparecer el prop
		local myRay =#()						--Array de rayos
		local myProps=#()						--Array de props
		local myPropsNames=#()				--Array de los nombres de los props
	
		local myCategories=#()				--Array con las categorias
		local myCategoriesNames=#()		--Array con los nombres de las categorias

		local categoriesPath ="\\\\COMPARTIDA\Renderings\Resources\Prop_Proxies"		--El Path de adonde estan los props
		local dotDirectory = dotNetClass "System.IO.Directory"									--Dotnet Object Directory
		local dotPath = dotNetClass "System.IO.Path"												--Dotnet Object Path
	
	
		--Funcion que Updatea el dialog
		function UpdateGUI newPos=										
		(			
			DestroyDialog PropLister											--Lo destruyo 
			CreateDialog PropLister width:400 pos:newPos	--Lo vuelvo a crear
		)
		--Funcion que encuentra todas las carpetas que van a ser las categorias
		fn GetCategories=
		(
			myCategories=dotDirectory.GetDirectories(categoriesPath)		--Referencio todas las carpetas dentro de la carpeta de categorias
			for o in myCategories do												
			(					
				append 	myCategoriesNames ( dotPath.GetFileName( o))		--Guardo sus nombres en un array
			)
		)

		--Funcion que define la posicion en donde va a entrar el prop
		fn GetPropPosition2 myPath =
		(
			myObj =PickObject()																--Click to select an object
			if(myObj != undefined) do														--If an object has been selected
			(
				mergemaxfile myPath  #select #mergeDups #useSceneMtlDups    -- Merge in the objects and select them
				mergedObj= selection[1]														--Select the merged  object
				print(mergedObj)
				mouseray = mapScreenToWorldRay mouse.pos							--Creamos un rayo desde el mouse hacia la escena
				myRay2=intersectRay myObj mouseray
				print(myRay2)
				--print(myRay2[1])
				--print(myRay2[2])
				--print(myRay2[3])
				--propPos = myRay2.pos			
				mergedObj.pos =myRay2.pos
			)
		)
		--Funcion que  consigue los archivos MAX (props)  dentro de la carpeta que le paso
		fn GetProps myPath myNewPos =
		(
			myProps=#()															--Vacio el array de props
			myPropsNames=#()													--Vacio el array de nombres de props
			myProps = getFiles ((myPath)+"\\*.max" )					--Referencio los archivos max demtro del path en el array myProps
			for o in myProps do													--Referencio los nombres(string) de los archivos en myProps
			(	
				append 	myPropsNames ( dotPath.GetFileNameWithoutExtension(o))	-- 
			)
			UpdateGUI(myNewPos)															--Updateo el rollout
		)		
		GetCategories()		--Corro el script de conseguir las categorias
		rollout PropLister "Props"
		(			
			listbox lb_Categories "Category :" items:myCategoriesNames width:100 across:2
			on lb_Categories selected value do 
			(				
				GetProps(myCategories[lb_Categories.selection ])(GetdialogPos(PropLister))
			)			
			listbox lb_myProps "Props :" items:myPropsNames		
			on lb_myProps selected value do 
			(
				GetPropPosition2(myProps[lb_myProps.selection ] )
			)
		)
	
		createdialog PropLister  width:400
		
)