package types.propvalues;

/**
 * ...
 * @author Kaelan
 */
class PropData 
{

	public function new() 
	{
		
	}
	
	public function toString():String
	{
		throw 'Empty PropData, this should never be called';
	}
	
	public function toZScript():String
	{
		return this.toString() + ';';
	}
}