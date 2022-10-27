package types.propvalues;

/**
 * ...
 * @author Kaelan
 */
class SingleInteger extends PropData 
{
	var name:String;
	var value:Int;
	public function new(_Name:String, _value:Int) 
	{
		super();
		
		name = _Name;
		value = _value;
		
	}
	
	override public function toString():String 
	{
		return '$name $value';
	}
}