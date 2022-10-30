package types.propvalues;

/**
 * ...
 * @author Kaelan
 */
class MultiValue extends PropData 
{
	var name:String;
	var values:Array<String>;

	public function new(_name:String, _values:Array<String>) 
	{
		super();
		
		name = _name;
		values = _values;
		trace(values);
	}
	
	override public function toString():String 
	{
		var result = '$name ';
		for (item in 0...values.length)
		{
			result += values[item];
			if (item < values.length - 1) result += ', ';
		}
		return result;
	}
	
}