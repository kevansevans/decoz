package types;

/**
 * ...
 * @author Kaelan
 */

@:publicFields
@:structInit
class EdNum
{
	var name:String;
	var value:Int;
	
	public function toString():String
	{
		return '$value = $name';
	}
}