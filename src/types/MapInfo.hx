package types;

/**
 * ...
 * @author Kaelan
 */
class MapInfo 
{
	public var ednums:Array<EdNum>;
	public function new() 
	{
		ednums = new Array();
	}
	
	public function toString():String
	{
		var result:String = '';
		result += 'DoomEdNums\n';
		result += '{\n';
		
		for (num in ednums)
		{
			result += '\t$num\n';
		}
		
		result += '}';
		
		return result;
	}
}