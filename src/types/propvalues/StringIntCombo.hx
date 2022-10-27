package types.propvalues;

/**
 * ...
 * @author Kaelan
 */
class StringIntCombo extends PropData 
{
	var name:String;
	var modifier:String;
	var value:Int;
	
	public function new(_name:String, _modifier:String, _value:Int) 
	{
		super();
		
		name = _name;
		modifier = _modifier;
		value = _value;
	}
	
	override public function toString():String 
	{
		return '$name $modifier, $value';
	}
	
}