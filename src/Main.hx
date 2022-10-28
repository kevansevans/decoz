package;

import hxd.App;
import enums.Func;
import enums.ParseState;
import hxd.File;
import types.Actor;
import types.State;
import types.StateBlock;
import types.ZDoomFile;
import types.propvalues.Combo;
import types.propvalues.Flag;
import types.propvalues.PropData;
import types.propvalues.SingleInteger;
import types.propvalues.SingleString;
import types.propvalues.StringFloatCombo;
import types.propvalues.StringIntCombo;
import types.propvalues.UDMFMetaData;
import enums.PropName;
import haxe.io.Bytes;

/**
 * ...
 * @author Kaelan
 */
class Main extends App
{
	
	public static var ZDFile:ZDoomFile;
	
	static function main() 
	{
		new Main();
	}
	
	public function new()
	{
		super();
	}
	
	override function init() 
	{
		super.init();
		
		ZDFile = new ZDoomFile();
		ZDoomFile.parseFile(File.getBytes('./testdeco.txt').toString());
		
		File.saveBytes('./ZSCRIPT.zsc', Bytes.ofString(ZDFile.toZScriptFile()));
	}
}