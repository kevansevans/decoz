package types.propvalues;

/**
 * ...
 * @author Kaelan
 */
class SingleString extends PropData 
{

	var name:String;
	var value:String;
	
	public function new(_name:String, _value:String) 
	{
		super();
		
		name = _name;
		value = _value;
		
	}
	
	override public function toString():String 
	{
		return '$name $value';
	}
	
}