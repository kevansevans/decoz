package types.propvalues;

/**
 * ...
 * @author Kaelan
 */
class StringFloatCombo extends PropData 
{

	var name:String;
	var modifier:String;
	var value:Float;
	
	public function new(_name:String, _modifier:String, _value:Float) 
	{
		super();
		
		name = _name;
		modifier = _modifier;
		value = _value;
	}
	
	override public function toString():String 
	{
		var ret:String = '$name $modifier, $value';
		if (ret.indexOf('.') == -1) ret += '.0';
		return ret;
	}
}