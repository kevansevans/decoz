package types.propvalues;

import enums.ZFlag;

/**
 * ...
 * @author Kaelan
 */
class Flag extends PropData 
{
	var value:String;
	public function new(_value:String) 
	{
		value = format(_value);
		super();
	}
	
	function format(_value:String):String
	{
		switch (_value.toUpperCase())
		{
			case ZFlag.DONTHARMCLASS:
				return 'DontHarmClass';
			default:
				return _value;
		}
	}
	
	override public function toString():String 
	{
		return '+' + value;
	}
	
}