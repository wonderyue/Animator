package ui
{
	import flash.display.Sprite;
	import flash.events.ContextMenuEvent;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	
	import flashx.textLayout.formats.TextAlign;
	
	import spark.components.Button;
	import spark.effects.Animate;
	
	public class AnimState extends DragSprite
	{
		private static var DEFAULT_COLOR:int = 0xFFD700;
		private static var NORMAL_COLOR:int = 0xD3D3D3;
		private var m_isDefaultState:Boolean = false;
		
		private var m_textField:TextField;
		private var m_bg:Sprite;
		private var m_id:String;
		
		public function AnimState(id:String)
		{
			super();
			m_id = id;
			initSkin();
			initMenu();
		}
		
		public function get isDefaultState():Boolean
		{
			return m_isDefaultState;
		}
		
		public function set isDefaultState(value:Boolean):void
		{
			if(m_isDefaultState == value) {
				return;
			}
			if (value) {
				m_bg.graphics.clear();
				m_bg.graphics.beginFill(DEFAULT_COLOR);
				m_bg.graphics.drawRoundRect(0,0,150,40,18,18);
				m_bg.graphics.endFill();
			} else {
				m_bg.graphics.clear();
				m_bg.graphics.beginFill(NORMAL_COLOR);
				m_bg.graphics.drawRoundRect(0,0,150,40,18,18);
				m_bg.graphics.endFill();
			}
			m_isDefaultState = value;
		}
		
		public function get id():String{
			return m_id;
		}
		
		private function initSkin():void{
			m_bg = new Sprite();
			m_bg.graphics.clear();
			m_bg.graphics.beginFill(NORMAL_COLOR);
			m_bg.graphics.drawRoundRect(0,0,150,40,18,18);
			m_bg.graphics.endFill();
			addChild(m_bg);
			m_bg.filters = [new DropShadowFilter(2,90,0,0.8)];
			
			m_textField = new TextField();
			m_textField.selectable = false;
			var textFormat:TextFormat = new TextFormat();
			textFormat.font = "Arial";
			textFormat.size = 20;
			m_textField.textColor = 0x000000;
			textFormat.align = TextAlign.CENTER;
			m_textField.defaultTextFormat = textFormat;
			m_textField.text = m_id;
			m_textField.width = m_bg.width;
			m_textField.height = m_bg.height;
			addChild(m_textField);
		}
		
		private function initMenu():void
		{
			var contextMenu:ContextMenu = new ContextMenu();
			var contextItem1:ContextMenuItem = new ContextMenuItem("Make Transition");
			var contextItem2:ContextMenuItem = new ContextMenuItem("Set As Default");
			var self:AnimState = this;
			contextItem1.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, function(e:ContextMenuEvent){
				EditController.getInstance().makeTransition(self);
			});
			contextItem2.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, function(e:ContextMenuEvent){
				EditController.getInstance().setDefaultState(self);
			});
			contextMenu.customItems.push(contextItem1);
			contextMenu.customItems.push(contextItem2);
			contextMenu.hideBuiltInItems();
			this.contextMenu = contextMenu;
		}
		
		override protected function onIn(e:MouseEvent):void
		{
			if (!EditController.getInstance().hasDragState()) 
			{
				super.onIn(e);
			}
		}
		
		override protected function onMove(e:MouseEvent):void
		{
			super.onMove(e);
			EditController.getInstance().updateArrow(this);
		}
		
		override protected function onMouseUp(e:MouseEvent):void
		{
			super.onMouseUp(e);
			EditController.getInstance().updateArrow(this);
		}
	}
}