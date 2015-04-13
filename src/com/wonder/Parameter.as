package com.wonder
{
	public class Parameter
	{
		public static var COMPLETE_ID:String = "complete";
		public static var DEFAULT_ID:String = "unused";
		
		public static var TYPE_COMPLETE:int = 0;
		public static var TYPE_BOOL:int = 1;
		public static var TYPE_NUMBER:int = 2;
		public static var TYPE_TRIGGER:int = 3;
		
		private var m_id:String = null;
		private var m_type:int = 0;
		
		public function Parameter(id:String="unused",type:int=3)
		{
			m_id = id;
			m_type = type;
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
	}
}