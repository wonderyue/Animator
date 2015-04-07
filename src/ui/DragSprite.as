package ui
{
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	public class DragSprite extends Sprite
	{
		private var m_isDrag:Boolean;
		private var m_border:int = 5;
		public function DragSprite()
		{
			addEventListener(Event.ADDED_TO_STAGE,onAdd);
			addEventListener(Event.REMOVED_FROM_STAGE,onRemoveEvent);
		}

		public function get isDrag():Boolean
		{
			return m_isDrag;
		}

		protected function onAdd(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE,onAdd);
			addEventListener(MouseEvent.MOUSE_OVER,onIn);
		}
		
		protected function onRemoveEvent(e:Event=null):void
		{
			removeEventListener(MouseEvent.MOUSE_OVER,onIn);
			onOut();
		}
		
		protected function onIn(event:MouseEvent):void
		{
			addEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
			addEventListener(MouseEvent.MOUSE_UP,onMouseUp);
			addEventListener(MouseEvent.MOUSE_MOVE,onMove);
			addEventListener(MouseEvent.MOUSE_OUT,onOut);
			addEventListener(MouseEvent.RIGHT_MOUSE_DOWN,onOut);
		}
		
		protected function onRelease(event:MouseEvent = null):void
		{
			m_isDrag = false;
		}	
		
		protected function onOut(event:MouseEvent = null):void
		{
			m_isDrag = false;
			removeEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
			removeEventListener(MouseEvent.MOUSE_UP,onMouseUp);
			removeEventListener(MouseEvent.MOUSE_MOVE,onMove);
			removeEventListener(MouseEvent.MOUSE_OUT,onOut);
			removeEventListener(MouseEvent.RIGHT_MOUSE_DOWN,onOut);
			removeEventListener(Event.REMOVED_FROM_STAGE,onRemoveEvent);
		}
		
		protected function onMove(e:MouseEvent):void
		{
			if(m_isDrag){
				var rect:Rectangle = new Rectangle(m_border,m_border,parent.width - width - m_border,parent.height - height - m_border);
				this.startDrag(false,rect);
				if(stage)stage.quality = StageQuality.LOW;
			}
		}
		
		protected function onMouseUp(e:MouseEvent):void
		{
			m_isDrag = false;
			this.stopDrag();
			x = int(x);
			y = int(y);
			if(stage)stage.quality = StageQuality.BEST;
		}
		
		protected function onMouseDown(e:MouseEvent):void
		{
			m_isDrag = true;
		}
	}
}