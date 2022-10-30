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
	public static var fileitems:Array<ZDoomFile>;
	public static var mapinfo:MapInfo;
	public static var providedPath:String;
	
	static function main() 
	{
		Sys.println("Decorate to ZScript converter by kevansevans.");
		Sys.println("Please view instructions at: https://github.com/kevansevans/decoz");
		Sys.println("");
		
		Sys.println("Please provide the file path:");
		Sys.print(":> ");
		
		var path:String = Sys.stdin().readLine();
		providedPath = path;
		
		fileitems = new Array();
		mapinfo = new MapInfo();
		
		recursiveFileRead(path);
		
		for (item in fileitems)
		{
			trace(item.filepath);
			ZDoomFile.parseFile(item, File.getBytes(item.filepath).toString());
		}
		
		for (item in fileitems)
		{
			File.saveBytes('./output/${item.localpath}', Bytes.ofString(item.toZScriptFile()));
		}
		
		//File.saveBytes('./ZSCRIPT.txt', Bytes.ofString(ZDFile.toZScriptFile()));
		//File.saveBytes('./MAPINFO.txt', Bytes.ofString(mapinfo.toString()));
	}
	
	static function recursiveFileRead(_path:String, _actorFolder:Bool = false)
	{
		var files:Array<String> = FileSystem.readDirectory(_path);
		
		for (file in files)
		{
			var filepath = '$_path/$file';
			if (FileSystem.isDirectory(filepath))
			{
				var isInActorFolder = _actorFolder;
				if (file.toUpperCase() == 'ACTORS') isInActorFolder = true;
				recursiveFileRead(filepath, isInActorFolder);
			}
			else
			{
				var name:String = filepath.toUpperCase();
				if (name.indexOf('DECORATE') != -1 || _actorFolder)
				{
					var localpath:String = filepath.substr(providedPath.length, filepath.length);
					fileitems.push(new ZDoomFile(file, localpath, filepath));
				}
			}
		}
	}
	
	public static function importIncluded(_path:String)
	{
		fileitems.push(new ZDoomFile(_path, _path, '$providedPath/$_path'));
	}
	
	static function clear()
	{
		if (!FileSystem.isDirectory('./output'))
		{
			FileSystem.createDirectory('./output');
		}
		else 
		{
			recursiveClearOutput('./output');
		}
	}
	
	static function recursiveClearOutput(_path:String)
	{
		var items:Array<String> = FileSystem.readDirectory(_path);
		
		for (item in items)
		{
			if (FileSystem.isDirectory('$_path/$item'))
			{
				recursiveClearOutput('$_path/$item');
				FileSystem.deleteDirectory('$_path/$item');
			} 
			else
			{
				FileSystem.deleteFile('$_path/$item');
			}
		}
	}

	static function parse()
	{
		//ZDFile = new ZDoomFile();
		//ZDoomFile.parseFile(File.getBytes('./testdeco.txt').toString());
		
		//File.saveBytes('./ZSCRIPT.zsc', Bytes.ofString(ZDFile.toZScriptFile()));
	}
}