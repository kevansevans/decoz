package enums;

/**
 * @author Kaelan
 */
enum ParseState 
{
	NONE;
	PROPERTIES;
	STATES;
	//Expecting conditions
	NL_OpenBrace;
}