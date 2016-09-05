macroScript AddUVW8Inches
category:"Matanga"
(	
		fn AddUVW size type =
		(
			myUVW = Uvwmap ()
			myUVW.length = size
			myUVW.width = size
			myUVW.height = size	
			if(type==1) do myUVW.maptype = 0
			if(type==2) do myUVW.maptype = 4
			
			for o in $ do
			(		
				try(	addmodifier o myUVW		)
				catch (print "couldnt add UVW")
			)				
		)	
		
		fn GetUnit unit UnitType =
		(
			test=""
			
			if(UnitType== 1) do test= "cm"
			if(UnitType== 2) do test= "\""
			if(UnitType== 3) do test = "'"
			if(UnitType== 4) do test ="m"
			
			--print test
			valueToDecode= unit as string+ test
			--print valueToDecode
			theUnit = units.decodeValue valueToDecode
			--print theUnit
			return  theUnit		
		)

		-- MAPPING TYPES ("Planar", "Box") 		
		--UNIT TYPES  ("cm", "Inches","Feet","Meter") 
		
		--First values is size, second value is unit type
		theValue =GetUnit 8 2
		--First values is size, second value is mapping type
		AddUVW theValue 2
		
)