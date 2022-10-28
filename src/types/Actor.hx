package types;
import types.propvalues.PropData;

/**
 * ...
 * @author Kaelan
 */
class Actor 
{
	
	public var decoActor:Bool;
	
	public var name:String;
	public var inherits:String = "Actor";
	public var replaces:Null<String> = null;
	
	public var stateblocks:Array<StateBlock>;
	public var properties:Array<PropData>;
	
	public function new() 
	{
		properties = new Array();
	}
	
	public function toZScriptActor():String
	{
		var info = '';
		info += 'Class ${name} : ${inherits}' + (replaces == null ? "\n" : ' replaces ${replaces}\n');
		info += '{\n';
		info += '\tDefault\n';
		info += '\t{\n';
		
		for (prop in properties)
		{
			info += '\t\t' + prop.toZScript() + '\n';
		}
		
		info += '\t}\n\n';
		
		if (stateblocks != null)
		{
			info += '\tStates\n';
			info += '\t{\n';
			
			for (block in stateblocks)
			{
				info += '\t\t${block.label}\n';
				for (state in block.states)
				{
					info += '\t\t\t${state.toZScript()};\n';
				}
				if (block.EndCondition != null)
				{
					info += '\t\t\t${block.EndCondition};\n';
				}
			}
			
			info += '\t}\n';
		}
		
		info += '}\n';
		info += '\n';
		
		return info;
	}
	
}