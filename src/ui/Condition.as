package ui
{
	public class Condition
	{
		private var m_id:String = null;
		private var m_type:int = -1;
		private var m_value:int = -1;
		private var m_logic:int = -1;
		public static var TYPE_BOOL = 1;
		public static var TYPE_NUMBER = 2;
		public static var TYPE_TRIGGER = 3;
		
		public static var LOGIC_EQUAL = 1;
		public static var LOGIC_GREATER = 2;
		public static var LOGIC_LESS = 3;
		public static var LOGIC_NOTEQUAL = 4;
		
		public function Condition()
		{
			m_id = id;
			m_type = type;
			m_value = value;
			m_logic = logic;
		}

		public function get id():String
		{
			return m_id;
		}

		public function set id(value:String):void
		{
			m_id = value;
		}

		public function get type():int
		{
			return m_type;
		}

		public function set type(value:int):void
		{
			m_type = value;
		}

		public function get value():int
		{
			return m_value;
		}

		public function set value(value:int):void
		{
			m_value = value;
		}

		public function get logic():int
		{
			return m_logic;
		}

		public function set logic(value:int):void
		{
			m_logic = value;
		}
	}
}