package types;

/**
 * ...
 * @author Kaelan
 */
class StateBlock 
{
	public var label:String;
	public var states:Array<State>;
	public var EndCondition:Null<String> = null;
	
	public function new(_label:String) 
	{
		label = _label;
		states = new Array();
	}
	
}