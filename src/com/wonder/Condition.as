package com.wonder
{
	public class Condition
	{
		private var m_id:String = null;
		private var m_type:int = -1;
		private var m_value:int = 0;
		private var m_logic:int = -1;
		public static var TYPE_BOOL:int = 0;
		public static var TYPE_NUMBER:int = 1;
		public static var TYPE_TRIGGER:int = 2;
		
		public static var LOGIC_EQUAL:int = 0;
		public static var LOGIC_GREATER:int = 1;
		public static var LOGIC_LESS:int = 2;
		public static var LOGIC_NOTEQUAL:int = 3;
		
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