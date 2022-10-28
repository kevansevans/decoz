package;

import haxe.io.Bytes;
import types.MapInfo;

import types.ZDoomFile;
import types.EdNum;

import sys.io.File;
import sys.FileSystem;

/**
 * ...
 * @author Kaelan
 */
class Main
{
	
	public static var ZDFile:ZDoomFile;
	public static var mapinfo:MapInfo;
	
	static function main() 
	{
		Sys.println("Decorate to ZScript converter by kevansevans.");
		Sys.println("Please view instructions at: https://github.com/kevansevans/decoz");
		Sys.println("");
		Sys.println("Please provide the file path:");
		Sys.print(":> ");
		
		//var path:String = Sys.stdin().readLine();
		
		ZDFile = new ZDoomFile("Decorate", "./");
		mapinfo = new MapInfo();
		
		ZDoomFile.parseFile(File.getBytes('./DECORATE.txt').toString());
		
		File.saveBytes('./ZSCRIPT.txt', Bytes.ofString(ZDFile.toZScriptFile()));
		File.saveBytes('./MAPINFO.txt', Bytes.ofString(mapinfo.toString()));
	}

	static function parse()
	{
		//ZDFile = new ZDoomFile();
		//ZDoomFile.parseFile(File.getBytes('./testdeco.txt').toString());
		
		//File.saveBytes('./ZSCRIPT.zsc', Bytes.ofString(ZDFile.toZScriptFile()));
	}
}