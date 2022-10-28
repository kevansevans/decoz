package types;

import enums.ParseState;
import enums.PropName;

import types.propvalues.*;

/**
 * ...
 * @author Kaelan
 */
class ZDoomFile 
{
	public var actors:Array<Actor>;
	public var const:Array<Constant>;
	
	public function new() 
	{
		actors = new Array();
		const = new Array();
	}
	
	public function toZScriptFile():String
	{
		var result:String = '';
		
		for (con in const)
		{
			result += con.toString() + '\n';
		}
		
		result += '\n';
		
		for (actor in actors)
		{
			result += actor.toZScriptActor();
		}
		
		return result;
	}
	
	static var activeActor:Actor;
	static var activeStateBlock:StateBlock;
	
	public static function parseFile(_text:String)
	{
		var file:ZDoomFile = Main.ZDFile;
		
		var decolines:Array<String> = _text.split('\n');
		
		var parseState:ParseState = NONE;
		
		for (linepos in 0...decolines.length)
		{
			if (decolines[linepos].indexOf('//') == 0) continue;
			
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
						case 'CONST':
							file.const.push(new Constant(items[2], items[4]));
							continue;
						case 'ACTOR':
							
							var newActor:Actor = new Actor();
							activeActor = newActor;
							file.actors.push(activeActor);
							
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
							
							activeActor.name = name;
							if (inherits != null) activeActor.inherits = inherits;
							if (replaces != null) activeActor.replaces = replaces;
							
							parseState = NL_OpenBrace;
							
							continue;
							
						case '' | '}':
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
						activeActor.properties.push(meta);
						continue;
					} 
					
					if (items.length == 1)
					{
						if (prop.charAt(0) == '+')
						{
							activeActor.properties.push(new Flag(prop.substr(1)));
							continue;
						}
						
						switch (prop.toUpperCase())
						{
							//Single word items;
							case PropName.MONSTER:
								activeActor.properties.push(new Combo('Monster'));
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
								activeActor.properties.push(new SingleInteger('Health', Std.parseInt(value)));
							case PropName.RADIUS:
								activeActor.properties.push(new SingleInteger('Radius', Std.parseInt(value)));
							case PropName.HEIGHT:
								activeActor.properties.push(new SingleInteger('Height', Std.parseInt(value)));
							case PropName.MASS:
								activeActor.properties.push(new SingleInteger('Mass', Std.parseInt(value)));
							case PropName.GIBHEALTH:
								activeActor.properties.push(new SingleInteger('GibHealth', Std.parseInt(value)));
							case PropName.SPEED:
								activeActor.properties.push(new SingleInteger('Speed', Std.parseInt(value)));
							case PropName.MAXTARGETRANGE:
								activeActor.properties.push(new SingleInteger('MaxTargetRange', Std.parseInt(value)));
							case PropName.PAINCHANCE:
								if (Std.parseInt(value) != null) activeActor.properties.push(new SingleInteger('PainChance', Std.parseInt(value)));
								else 
								{
									reinjectSpaces();
									activeActor.properties.push(new StringIntCombo('PainChance', value, Std.parseInt(items[items.length - 1])));
								}
							case PropName.DAMAGEFACTOR:
								reinjectSpaces();
								activeActor.properties.push(new StringFloatCombo('DamageFactor', value, Std.parseFloat(items[items.length - 1])));
							case PropName.TAG:
								reinjectSpaces();
								activeActor.properties.push(new SingleString("Tag", value));
							case PropName.BLOODCOLOR:
								reinjectSpaces();
								activeActor.properties.push(new SingleString("BloodColor", value));
							case PropName.SPECIES:
								reinjectSpaces();
								activeActor.properties.push(new SingleString("Species", value));
							case PropName.OBITUARY:
								reinjectSpaces();
								activeActor.properties.push(new SingleString("Obituary", value));
							case PropName.SEESOUND:
								reinjectSpaces();
								activeActor.properties.push(new SingleString("SeeSound", value));
							case PropName.ACTIVESOUND:
								reinjectSpaces();
								activeActor.properties.push(new SingleString("ActiveSound", value));
							case PropName.DEATHSOUND:
								reinjectSpaces();
								activeActor.properties.push(new SingleString("DeathSound", value));
							case "":
								continue;
							default:
								trace('Unsupported property: ${prop.toUpperCase()}');
						}
						
						continue;
					}
					
				case STATES:
					
					if (items[0].indexOf('}') != -1) {
						parseState = NONE;
						continue;
					}
					if (items[0].indexOf('//') != -1) continue;
					
					if (activeActor.stateblocks == null) {
						activeActor.stateblocks = new Array();
						continue;
					}
					
					if (items[0].lastIndexOf(':') != -1)
					{
						var stateblock = new StateBlock(items[0]);
						activeStateBlock = stateblock;
						activeActor.stateblocks.push(stateblock);
						continue;
					}
					
					switch (items[0].toUpperCase())
					{
						case "STOP":
							activeStateBlock.EndCondition = "stop";
							continue;
						case "LOOP":
							activeStateBlock.EndCondition = "loop";
							continue;
						case "GOTO":
							activeStateBlock.EndCondition = "goto " + items[1];
							continue;
						case "":
							continue;
						default:
							var sprite = items[0];
							var frames = items[1];
							var ticrat = items[2];
							
							var func:String = items[3] == null ? "" : items[3];
							if (func.indexOf('//') != -1) continue;
							if (items.length > 4)
							{
								for (index in 4...items.length)
								{
									if (items[index].indexOf('//') != -1) break;
									func += items[index];
								}
							}
							
							activeStateBlock.states.push(new State(sprite, frames, Std.parseInt(ticrat), func));
					}
					
				case SKIP:
					//debug state for when I just want the loop to fuck off
				default:
					throw 'man, what the fuck? Impossible crash in switch(parsestate)';
			}
		}
		
		trace('Done!');
	}
	
	static function sanitize(_input:String):String
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