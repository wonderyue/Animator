package com.wonder
{
	import flash.display.Sprite;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	
	public class AnimTransition
	{
		private var m_from:AnimState;
		private var m_to:AnimState;
		private var m_arrow:Sprite;
		private var m_isSelected:Boolean = false;
		private var m_conditionArray:Array;
		
		public function AnimTransition(from:AnimState)
		{
			super();
			m_from = from;
			m_arrow = new Sprite();
			EditController.getInstance().arrowContainer.addChild(m_arrow);
			m_arrow.addEventListener(MouseEvent.CLICK,onMouseClick);
			m_arrow.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			m_arrow.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			m_arrow.addEventListener(Event.REMOVED_FROM_STAGE,onDestroy);
			m_conditionArray = new Array();
			initMenu();
		}
		
		private function initMenu():void
		{
			var contextMenu:ContextMenu = new ContextMenu();
			var contextItem1:ContextMenuItem = new ContextMenuItem("Delete");
			var self:AnimTransition = this;
			contextItem1.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, function(e:ContextMenuEvent):void{
				EditController.getInstance().removeTransition(self);
				EditController.getInstance().curArrow = null;
			});
			contextMenu.customItems.push(contextItem1);
			contextMenu.hideBuiltInItems();
			m_arrow.contextMenu = contextMenu;
		}
		
		public function get conditionArray():Array
		{
			return m_conditionArray;
		}

		public function addCondition():Condition
		{
			var condition:Condition = new Condition(EditController.getInstance().completeParam);
			m_conditionArray.push(condition);
			return condition;
		}
		
		public function removeCondition(condition:Condition):void
		{
			for (var i:int = 0; i < m_conditionArray.length; i++)
			{
				var element:Condition = m_conditionArray[i] as Condition;
				if (element == condition) 
				{
					m_conditionArray.splice(i,1);
					return;
				}
			}
		}
		
		public function get from():AnimState
		{
			return m_from;
		}
		
		public function get to():AnimState
		{
			return m_to;
		}
		
		public function set to(value:AnimState):void
		{
			m_arrow.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			m_to = value;
		}
		
		private function onDestroy(e:Event):void
		{
			m_arrow.removeEventListener(MouseEvent.CLICK,onMouseClick);
			m_arrow.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			m_arrow.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}
		
		public function destroy():void
		{
			if (m_arrow.parent) 
			{
				m_arrow.parent.removeChild(m_arrow);
			}
		}
		
		public function get isSelected():Boolean
		{
			return m_isSelected;
		}
		
		public function set isSelected(bool:Boolean):void
		{
			if (bool) 
			{
				var filter:Array = [new GlowFilter(0xff0000, 1.0, 2.0, 2.0, 20, 1, true, false)];
				m_arrow.filters = filter;
			} else {
				m_arrow.filters = null;
			}
			m_isSelected = bool;
		}
		
		public function draw():void
		{
			var fromCenter:Point = new Point(m_from.x + m_from.width / 2, m_from.y + m_from.height / 2);
			var toCenter:Point;
			if(m_to){
				toCenter = new Point(m_to.x + m_to.width / 2, m_to.y + m_to.height / 2); 
			}else{
				toCenter = new Point(m_arrow.stage.mouseX, m_arrow.stage.mouseY);
				toCenter = m_arrow.parent.globalToLocal(toCenter);
			}
			m_arrow.graphics.clear();
			m_arrow.graphics.lineStyle(3,0x000000,0.7);
			var len:int = 10;//箭头长度
			var _a:int = 8;//箭头与直线的夹角
			var angle:int = Math.atan2((fromCenter.y-toCenter.y), (fromCenter.x-toCenter.x))*(180/Math.PI);
			//防止双向Transition重合，重新确定端点
			var begin:Point = fromCenter;
			var end:Point = toCenter;
			if(m_to){
				begin = new Point(fromCenter.x + 5*Math.cos((angle+90)*(Math.PI/180)), fromCenter.y + 5*Math.sin((angle+90)*(Math.PI/180)));
				end = new Point(toCenter.x + 5*Math.cos((angle+90)*(Math.PI/180)), toCenter.y + 5*Math.sin((angle+90)*(Math.PI/180)));
			}
			var arrowPt:Point = new Point((begin.x+end.x)/2, (begin.y+end.y)/2);
			m_arrow.graphics.moveTo(arrowPt.x, arrowPt.y);
			m_arrow.graphics.lineTo(arrowPt.x+len*Math.cos((angle-_a)*(Math.PI/180)), arrowPt.y+len*Math.sin((angle-_a)*(Math.PI/180)));
			m_arrow.graphics.moveTo(arrowPt.x, arrowPt.y);
			m_arrow.graphics.lineTo(arrowPt.x+len*Math.cos((angle+_a)*(Math.PI/180)), arrowPt.y+len*Math.sin((angle+_a)*(Math.PI/180)));
			m_arrow.graphics.moveTo(begin.x,begin.y);
			m_arrow.graphics.lineTo(end.x,end.y);
		}
		
		private function onMouseMove(e:MouseEvent):void
		{
			draw();
		}
		
		private function onMouseUp(e:MouseEvent):void
		{
			var state:AnimState = EditController.getInstance().getStateByMouse(new Point(m_arrow.stage.mouseX, m_arrow.stage.mouseY));
			if(state && !to && !state.isAnyState){
				to = state;
				draw();
				EditController.getInstance().checkTransitionExist(this);
			}
		}
		
		private function onMouseClick(e:MouseEvent):void
		{
			if(m_to){
				EditController.getInstance().curArrow = this;
			}
		}
	}
}