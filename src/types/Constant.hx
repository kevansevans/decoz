package types;

/**
 * ...
 * @author Kaelan
 */
class Constant 
{
	var name:String;
	var value:String;
	
	public function new(_name:String, _value:String) 
	{
		name = _name;
		value = _value;
	}
	
	public function toString():String
	{
		return 'const $name = $value';
	}
	
}