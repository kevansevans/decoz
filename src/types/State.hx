package types;
import enums.Func;

/**
 * ...
 * @author Kaelan
 */
class State 
{
	
	public var sprite:String;
	public var frame:String;
	public var length:Int;
	public var func:String;
	
	public var noDelay:Bool = false;
	public var bright:Bool = false;
	public var canRaise:Bool = false;
	public var light:Bool = false;
	public var fast:Bool = false;
	public var offset:Null<StateOffset>;
	
	public function new(_sprite:String, _frame:String, _length:Int, _function:String) 
	{
		sprite = _sprite;
		frame = _frame;
		length = _length;
		func = clean(_function);
	}
	
	function clean(_function:String):String
	{
		if (_function == "") return "";
		var items:Array<String> = _function.split('(');
		
		if (_function.indexOf('(') == -1) return items[0] + '()';
		else
		{
			var args:Array<String> = _function.split(',');
			var result:String = '';
			
			for (a in 0...args.length)
			{
				result += args[a];
				if (a != args.length - 1) result += ', ';
			}
			
			return result;
		}
		
		throw 'yo dawg you dun goofed';
	}
	
	public function toZScript():String
	{
		return '$sprite $frame $length' + (func == "" ? "" : ' $func');
	}
}