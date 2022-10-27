package types.propvalues;

/**
 * ...
 * @author Kaelan
 */
class UDMFMetaData extends PropData
{

	public var value:String;
	
	public function new() 
	{
		super();
	}
	
	override public function toString():String
	{
		return "//$" + value;
	}
	
	override public function toZScript():String 
	{
		return toString();
	}
}