package types.propvalues;

/**
 * ...
 * @author Kaelan
 */
class Combo extends PropData 
{

	public var value:String;
	
	public function new(_value:String) 
	{
		value = _value;
		super();
	}
	
	override public function toString():String 
	{
		return value;
	}
}