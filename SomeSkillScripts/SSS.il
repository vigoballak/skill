procedure( _SSSLoadConfig()
let( (cfg_path cfg_file line (info "") (toRead nil) block pin layer layers i )
	when( infile(strcat(getShellEnvVar("HOME") "/SSS.config"))
		cfg_path = strcat(getShellEnvVar("HOME") "/SSS.config")
	)
	when( infile(strcat(getWorkingDir() "/SSS.config"))
		cfg_path = strcat(getWorkingDir() "/SSS.config")
	)
	cfg_file = infile(cfg_path)
	SSSCleanUp()
	load( strcat(sssHome "/SSS.defaults") )
	when( cfg_file
		SSSPrint(strcat("Reading config from " cfg_path) "i")
		while( gets(line cfg_file)
			if( line != "\n" then line = car(parseString(line "\n")) else toRead = nil )
			when( toRead
				case( block
					( "tech" when( ddGetObj(line) sssTechFile = techGetTechFile(ddGetObj(line))) )
					( "grid" sssGrid = atof(line) )
					( "feol" sssFEOL = parseString(line) )
					( "beol" sssBEOL = parseString(line) )
					( "cut" sssCuts = parseString(line) )
					( "pin" foreach( pin parseString(line) sssPins = append1(sssPins parseString(pin "."))) )
					( "dummy" foreach( dum parseString(line) sssDummies = append1(sssDummies parseString(dum "."))) )
				)
			)
			when( rexMatchp("^[[].*[]]$" line)
				toRead = t
				block = car(parseString(line "[]"))
			)
		)
		if( sssTechFile then
			SSSPrint( strcat("Getting informaition from " sssTechFile~>libName " tech file") "i")
			layers = techGetLayerFunctions(sssTechFile)
			foreach( layer layers
				if( cadr(layer) == "cut" then sssVias = append1(sssVias car(layer)) )
			)
			SSSLoadScripts()
			SSSLoadBindKeys()
		else
			SSSPrint( "Tech library is missed" "e" )
		)
	)
);let
);procedure

procedure( _SSSEditConfig()
let( (cfg_path)
	when( infile(strcat(getShellEnvVar("HOME") "/SSS.config"))
		cfg_path = strcat(getShellEnvVar("HOME") "/SSS.config")
	)
	when( infile(strcat(getWorkingDir() "/SSS.config"))
		cfg_path = strcat(getWorkingDir() "/SSS.config")
	)
	when( cfg_path
		SSSPrint(strcat("Editing " cfg_path " file") "i")
		edit( sprintf(nil "%s" cfg_path) )
	)
);let
);procedure

procedure( _SSSAbout()
let( (file line (info "") (endOfInfo nil))
	file = infile( strcat(sssHome "/SSS.il") )
	when( file
		while( gets(line file) && !endOfInfo
			if( line == "\n" then endOfInfo = t else line = car(parseString(line "\n")) )
			when( rexMatchp("^/.*$" line)
				SSSPrint( line "i" )
			)
		)
	)
);let
);procedure

/*** Adding main menu to CIW ***/

let( (items)
	createDir( strcat(getWorkingDir() "/.SSS") )
	ciwMenuInit()
	items = list(
			hiCreateMenuItem(
				?name 'itemEditConfig
				?itemText "Edit Config"
				?callback "_SSSEditConfig()"
			)
			hiCreateMenuItem(
				?name 'itemLoadConfig
				?itemText "Load Config"
				?callback "_SSSLoadConfig()"
			)
			hiCreateMenuItem(
				?name 'itemILog
				?itemText "About"
				?callback "_SSSAbout()"
			)
	)
	sssMenu = hiCreatePulldownMenu(
			'sssMenu
			"SSS"
			items
	)
	if( hiInsertBannerMenu( window(1) sssMenu hiGetNumMenus(window(1)) )
		SSSPrint( "Some SKILL Scripts menu has been added to CIW" "i" )
	)
);let
