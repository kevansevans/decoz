package;

import hxd.App;
import enums.Func;
import enums.ParseState;
import hxd.File;
import types.Actor;
import types.propvalues.Combo;
import types.propvalues.Flag;
import types.propvalues.PropData;
import types.propvalues.SingleInteger;
import types.propvalues.SingleString;
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
		
		parseDeco(File.getBytes('./testdeco.txt').toString());
	}
	
	var decolines:Array<String>;
	var parseState:ParseState = NONE;
	var actor:Null<Actor> = null;
	
	function parseDeco(_text:String)
	{
		decolines = _text.split('\n');
		
		for (linepos in 0...decolines.length)
		{
			var items = decolines[linepos].split(' ');
			
			for (index in 0...items.length)
			{
				items[index] = sanitize(items[index]);
			}
			
			switch (parseState)
			{
				case NONE:
					
					switch (items[0].toUpperCase())
					{
						case 'ACTOR':
							
							var slot:Int = 1;
							var inherits:Null<String> = null;
							var replaces:Null<String> = null;
							var edNum:Null<Int> = null;
							
							var name = items[slot];
							
							if (items[slot + 1] == ":")
							{
								slot += 2;
								inherits = items[slot];
							}
							
							if (items[slot + 1] == "replaces")
							{
								replaces = items[slot += 2];
							}
							
							if (items[slot += 1] != null)
							{
								edNum = Std.parseInt(items[slot]);
							}
							
							actor = new Actor(name, edNum, true);
							if (inherits != null) actor.inherits = inherits;
							if (replaces != null) actor.replaces = replaces;
							
							parseState = NL_OpenBrace;
							
							continue;
							
						default:
							throw 'Unknown line header: ${items[0].toUpperCase()}';
					}
				case NL_OpenBrace:
					if (decolines[linepos].indexOf('{') != -1)
					{
						parseState = PROPERTIES;
						continue;
					}
					throw "Bad actor! Missing open brace!";
				case PROPERTIES:
					
					var prop = items[0];
					
					if (prop.toUpperCase() == "STATES")
					{
						parseState = STATES;
						continue;
					}
					
					if (prop.indexOf("//$") == 0)
					{
						var meta:UDMFMetaData = new UDMFMetaData();
						meta.value = decolines[linepos].substr(4);
						actor.properties.push(meta);
						continue;
					} 
					
					if (items.length == 1)
					{
						if (prop.charAt(0) == '+')
						{
							actor.properties.push(new Flag(prop.substr(1)));
							continue;
						}
						
						switch (prop.toUpperCase())
						{
							//Single word items;
							case PropName.MONSTER:
								actor.properties.push(new Combo('Monster'));
							default:
								trace('Unsupported property: ${prop.toUpperCase()}');
						}
						continue;
					}
					
					if (items.length > 1)
					{
						var value:String = items[1];
						
						function reinjectSpaces()
						{
							if (items[1].charAt(0) == '"')
							{
								if (items.length > 2 && items[1].charAt(items[1].length - 2) != '"')
								{
									var pos:Int = 2;
									while (true)
									{
										value += ' ' + (items[pos].indexOf(',') == -1 ? items[pos] : items[pos].substr(0, items[pos].length - 2));
										if (items[pos].indexOf('"') != -1 && items[pos].charAt(0) != '"') break;
										++pos;
									}
								} else {
									if (value.indexOf(',') != -1)
									{
										value = value.substr(0, value.length - 1);
									}
								}
							}
						}
						
						switch (prop.toUpperCase())
						{
							case PropName.HEALTH:
								actor.properties.push(new SingleInteger('Health', Std.parseInt(value)));
							case PropName.RADIUS:
								actor.properties.push(new SingleInteger('Radius', Std.parseInt(value)));
							case PropName.HEIGHT:
								actor.properties.push(new SingleInteger('Height', Std.parseInt(value)));
							case PropName.MASS:
								actor.properties.push(new SingleInteger('Mass', Std.parseInt(value)));
							case PropName.GIBHEALTH:
								actor.properties.push(new SingleInteger('GibHealth', Std.parseInt(value)));
							case PropName.MAXTARGETRANGE:
								actor.properties.push(new SingleInteger('MaxTargetRange', Std.parseInt(value)));
							case PropName.PAINCHANCE:
								if (Std.parseInt(value) != null) actor.properties.push(new SingleInteger('PainChance', Std.parseInt(value)));
								else 
								{
									reinjectSpaces();
									actor.properties.push(new StringIntCombo('PainChance', value, Std.parseInt(items[items.length - 1])));
								}
							case PropName.TAG:
								reinjectSpaces();
								actor.properties.push(new SingleString("Tag", value));
							case PropName.BLOODCOLOR:
								reinjectSpaces();
								actor.properties.push(new SingleString("BloodColor", value));
							default:
								trace('Unsupported property: ${prop.toUpperCase()}');
						}
						
						continue;
					}
					
				case STATES:
					
				default:
					throw 'man, what the fuck? Impossible crash in switch(parsestate)';
			}
		}
		
		var output:String = actor.toZScriptActor();
		File.saveBytes('./output.zsc', Bytes.ofString(output));
		
		trace('Done!');
	}
	
	function sanitize(_input:String):String
	{
		var input = _input;
		
		while (input.charAt(0) == '\t')
		{
			input = input.substr(1);
		}
		
		while (input.lastIndexOf('\r') != -1)
		{
			input = input.substr(0, input.length - 1);
		}
		
		while (input.lastIndexOf('\r') != -1)
		{
			input = input.substr(0, input.length - 1);
		}
		
		return input;
	}
}