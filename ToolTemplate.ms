
struct BlockAnalizer
(
	myInst=undefined,
	
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

	
	
	--------------------------------------------
	--------------------------------------------
	-- CATEGORY PANELS
	-- CATEGORY PANELS
	--------------------------------------------
	--------------------------------------------



	--------------------------------------------
	--------------------------------------------
	-- MAIN PANELS
	-- MAIN PANELS
	--------------------------------------------
	--------------------------------------------
	fn initSplicContainer sender =
	(

	),
	
	--------------------------------------------
	--------------------------------------------
	-- LAUNCH  UI
	-- LAUNCH  UI
	--------------------------------------------
	--------------------------------------------
	fn ui =
	(	
		rollout uiR "The UI" width:565 height:600
		(
			
			dotnetcontrol mainContr "MaxCustomControls.MaxUserControl"   \
			width: (uiR.width)\
			height:(uiR.height)\
			offset:[-14,-5]

			
			on uiR open do
			(
				splitCon = dotnetobject "SplitContainer"
				initSplicContainer splitCon
				splitCon.padding= splitCon.padding.empty
				

			)
			
		)		
		createDialog uiR
		myInst =uiR
	),
	
	fn run=
	(
		if(myInst == undefined) then
		(
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