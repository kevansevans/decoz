package types.propvalues;

/**
 * ...
 * @author Kaelan
 */
class SingleFloat extends PropData 
{
	var name:String;
	var value:Float;
	
	public function new(_name:String, _value:Float) 
	{
		super();
		
		name = _name;
		value = _value;
	}
	
	override public function toString():String 
	{
		var ret:String = '$name $value';
		if (ret.indexOf('.') == -1) ret += '.0';
		return ret;
	}
}