package types;
import enums.Func;

/**
 * ...
 * @author Kaelan
 */
class State 
{
	
	public var sprite:String;
	public var frame:String;
	public var length:Int;
	public var func:Func;
	
	public var noDelay:Bool = false;
	public var bright:Bool = false;
	public var canRaise:Bool = false;
	public var light:Bool = false;
	public var fast:Bool = false;
	public var offset:Null<StateOffset>;
	
	public function new(_sprite:String, _frame:String, _length:Int, _function:Func) 
	{
		
	}
	
	public static function toZSCState(_state:DecoState):ZSCState
	{
		return new ZSCState(_state.sprite, _state.frame, _state.length, _state.func);
	}
	
}