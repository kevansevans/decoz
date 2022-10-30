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
	
	public var name:String;
	public var localpath:String;
	public var filepath:String;
	
	public function new(_name:String, _localPath:String, _filePath:String) 
	{
		actors = new Array();
		const = new Array();
		
		name = _name;
		localpath = _localPath;
		filepath = _filePath;
	}
	
	public function toZScriptFile():String
	{
		var result:String = '';
		
		if (const.length > 0)
		{
			for (con in const)
			{
				result += con.toString() + '\n';
			}
			result += '\n';
		}
		
		for (actor in actors)
		{
			result += actor.toZScriptActor();
		}
		
		return result;
	}
	
	static var activeActor:Actor;
	static var activeStateBlock:StateBlock;
	
	public static function parseFile(_file:ZDoomFile, _text:String)
	{
		var file:ZDoomFile = _file;
		
		var decolines:Array<String> = _text.split('\n');
		
		var parseState:ParseState = NONE;
		
		for (linepos in 0...decolines.length)
		{
			if (decolines[linepos].indexOf('//') == 0) continue;
			
			var items:Array<String> = [];
			var preSplit = decolines[linepos].split(' ');
			
			for (index in 0...preSplit.length)
			{
				if (preSplit[index] != '')
				{
					items.push(sanitize(preSplit[index]));
				}
			}
			
			if (items.length == 0) continue;
			
			switch (parseState)
			{
				case NONE:
					
					switch (items[0].toUpperCase())
					{
						case '#INCLUDE':
							var secs:Array<String> = items[1].split('"');
							Main.importIncluded(secs[1]);
							continue;
						case 'CONST':
							file.const.push(new Constant(items[2], items[4]));
							continue;
						case 'ACTOR':
							
							var newActor:Actor = new Actor();
							activeActor = newActor;
							file.actors.push(activeActor);
							
							var line:Array<String> = [];
							
							for (item in items)
							{
								if (item.indexOf(':') == 0 && item.length > 1)
								{
									line.push(':');
									line.push(item.substr(1, item.length));
									continue;
								}
								
								line.push(item);
							}
							
							var length = line.length;
							if (line[length - 1] == '{') {
								length -= 1;
							}
							
							switch (length)
							{
								case 2:
									activeActor.name = line[1];
								case 3:
									activeActor.name = line[1];
									Main.mapinfo.ednums.push({name : line[1], value : Std.parseInt(line[2])});
								case 4:
									activeActor.name = line[1];
									activeActor.inherits = line[3];
								case 5:
									activeActor.name = line[1];
									activeActor.inherits = line[3];
									Main.mapinfo.ednums.push({name : line[1], value : Std.parseInt(line[4])});
								case 6:
									activeActor.name = line[1];
									activeActor.inherits = line[3];
									activeActor.replaces = line[5];
								case 7:
									activeActor.name = line[1];
									activeActor.inherits = line[3];
									activeActor.replaces = line[5];
									Main.mapinfo.ednums.push({name : line[1], value : Std.parseInt(line[6])});
								default:
									throw 'HWAT!? ${line.length}, $linepos'; 
							}
							
							parseState = PROPERTIES;
							
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
				case PROPERTIES:
					
					var prop = items[0];
					
					if (prop.toUpperCase().indexOf("STATES") != -1)
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
								//trace('Unsupported property: ${prop.toUpperCase()}');
						}
						continue;
					}
					
					if (items.length > 1)
					{
						var value:String = items[1];
						
						function reinjectSpaces(_commas:Bool = false)
						{
							value = '';
							for (index in 1...items.length)
							{
								if (items[index] != '') {
									value += items[index];
									if (index < items.length - 1)
									{
										value += (_commas ? ', ' : ' ');
									}
								}
							}
						}
						
						var subtypes:Array<String> = prop.split('.');
						if (subtypes.length > 1)
						{
							prop = '';
							for (word in subtypes)
							{
								prop += word;
							}
						}
						
						//To help future proof changes, and also to take an oppourtunity to clean the lines,
						//Rather than inlining each line and slap a ; at the end of it, we'll make a check
						//for every type so they can be handled correctly. Stuff like PainChance can either
						//have a single int, or a string and an int in it's line.
						switch (prop.toUpperCase())
						{
							case PropName.HEALTH:
								activeActor.properties.push(new SingleInteger('Health', Std.parseInt(value)));
							case PropName.SPAWNID:
								activeActor.properties.push(new SingleInteger('SpawnID', Std.parseInt(value)));
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
							case PropName.WEAPONSELECTIONORDER:
								activeActor.properties.push(new SingleInteger('Weapon.SelectionOrder', Std.parseInt(value)));
							case PropName.WEAPONAMMOUSE:
								activeActor.properties.push(new SingleInteger('Weapon.AmmoUse', Std.parseInt(value)));
							case PropName.WEAPONAMMOGIVE:
								activeActor.properties.push(new SingleInteger('Weapon.AmmoGive', Std.parseInt(value)));
							case PropName.INVENTORYAMOUNT:
								activeActor.properties.push(new SingleInteger('Inventory.Amount', Std.parseInt(value)));
							case PropName.INVENTORYMAXAMOUNT:
								activeActor.properties.push(new SingleInteger('Inventory.MaxAmount', Std.parseInt(value)));
							case PropName.AMMOBACKPACKAMOUNT:
								activeActor.properties.push(new SingleInteger('Ammo.BackpackAmount', Std.parseInt(value)));
							case PropName.AMMOBACKPACKMAXAMOUNT:
								activeActor.properties.push(new SingleInteger('Ammo.BackpackMaxAmount', Std.parseInt(value)));
							case PropName.SCALE:
								activeActor.properties.push(new SingleFloat('Scale', Std.parseFloat(value)));
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
							case PropName.GAME:
								reinjectSpaces();
								activeActor.properties.push(new SingleString("Game", value));
							case PropName.DAMAGETYPE:
								reinjectSpaces();
								activeActor.properties.push(new SingleString('DamageType', value));
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
							case PropName.ATTACKSOUND:
								reinjectSpaces();
								activeActor.properties.push(new SingleString("AttackSound", value));
							case PropName.DEATHSOUND:
								reinjectSpaces();
								activeActor.properties.push(new SingleString("DeathSound", value));
							case PropName.WEAPONAMMOTYPE:
								reinjectSpaces();
								activeActor.properties.push(new SingleString("Weapon.AmmoType", value));
							case PropName.INVENTORYPICKUPMESSAGE:
								reinjectSpaces();
								activeActor.properties.push(new SingleString("Inventory.PickupMessage", value));
							case PropName.INVENTORYICON:
								reinjectSpaces();
								activeActor.properties.push(new SingleString("Inventory.Icon", value));
							case PropName.PLAYERWEAPONSLOT:
								reinjectSpaces(true);
								activeActor.properties.push(new MultiValue("Player.WeaponSlot", value.split(', ')));
							case "" | "//":
								continue;
							default:
								//trace('Unsupported property: ${prop.toUpperCase()}');
						}
						
						continue;
					}
					
				case STATES:
					
					if (activeActor.stateblocks == null) {
						activeActor.stateblocks = new Array();
					}
					
					if (items[0].indexOf('}') != -1) {
						parseState = NONE;
						continue;
					}
					if (items[0].indexOf('//') != -1) continue;
					
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
		
		while (input.lastIndexOf(',') != -1)
		{
			input = input.substr(0, input.length - 1);
		}
		
		return input;
	}
	
}