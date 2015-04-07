package ui
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.core.UIComponent;
	
	import spark.components.Button;
	import spark.components.DropDownList;
	import spark.components.HGroup;
	import spark.components.TextInput;
	import spark.components.VGroup;
	import spark.events.IndexChangeEvent;

	public class EditController
	{
		private static var _instance:EditController;
		private var m_editLayer:UIComponent;
		private var m_inspector:VGroup; 
		private var m_stateArray:Array;
		private var m_transitionArray:Array;
		private var m_defaultState:AnimState = null;
		private var m_arrowContainer:Sprite;
		private var m_curArrow:AnimTransition = null;
		
		public function EditController(editLayer:UIComponent,inspector:VGroup)
		{
			m_editLayer = editLayer;
			m_inspector = inspector;
			_instance = this;
			m_stateArray = new Array();
			m_transitionArray = new Array();
			m_arrowContainer = new Sprite();
			m_editLayer.addChild(m_arrowContainer);
			initStates();
		}

		public function get arrowContainer():Sprite
		{
			return m_arrowContainer;
		}
		
		public function get curArrow():AnimTransition
		{
			return m_curArrow;
		}
		
		public function set curArrow(value:AnimTransition):void
		{
			if (m_curArrow) 
			{
				m_curArrow.isSelected = false;
			}
			m_curArrow = value;
			value.isSelected = true;
			updateInspector(m_curArrow);
		}
		
		private function updateInspector(transition:AnimTransition):void
		{
			m_inspector.removeAllElements();
			for (var i:int = 0; i < transition.conditionArray.length; i++)
			{
				var element:Condition = transition.conditionArray[i] as Condition;
				m_inspector.addElement(createConditionContent(element));
			}
			var hGroup:HGroup = new HGroup();
			var add:Button = new Button();
			add.width = 50;
			add.label = "+";
			add.addEventListener(MouseEvent.CLICK, function(e:MouseEvent){
				transition.addCondition();
				updateInspector(transition);
			});
			var remove:Button = new Button();
			remove.width = 50;
			remove.label = "-";
			remove.addEventListener(MouseEvent.CLICK, function(e:MouseEvent){
				transition.conditionArray.pop();
				updateInspector(transition);
			});
			hGroup.addElement(add);
			hGroup.addElement(remove);
			m_inspector.addElement(add);
		}
		
		private function createConditionContent(condition:Condition):HGroup
		{
			var hGroup:HGroup = new HGroup();
			var input:TextInput = new TextInput();
			input.width = 50;
			var type:DropDownList = new DropDownList();
			type.dataProvider = new ArrayCollection([  
				{id:Condition.TYPE_BOOL,label:'bool'},  
				{id:Condition.TYPE_NUMBER,label:'number'},  
				{id:Condition.TYPE_TRIGGER,label:'trigger'}  
			]); 
			type.width = 80;
			type.selectedIndex = condition.type;
			type.addEventListener(IndexChangeEvent.CHANGING,function(e:IndexChangeEvent){
				condition.type = e.newIndex;
				switch(e.newIndex)
				{
					case Condition.TYPE_BOOL:
					{
						var logic:DropDownList = new DropDownList();
						logic.dataProvider = new ArrayCollection([  
							{id:Condition.LOGIC_EQUAL,label:'='},  
							{id:Condition.LOGIC_GREATER,label:'>'},  
							{id:Condition.LOGIC_LESS,label:'<'},  
							{id:Condition.LOGIC_NOTEQUAL,label:'≠'}
						]); 
						logic.width = 80;
						logic.addEventListener(IndexChangeEvent.CHANGING,function(e:IndexChangeEvent){
							condition.logic = e.newIndex;
						})
						hGroup.addElement(logic);
						condition.logic = Condition.LOGIC_EQUAL;
						break;
					}
					case Condition.TYPE_NUMBER:
					{
						var logic:DropDownList = new DropDownList();
						logic.dataProvider = new ArrayCollection([  
							{id:Condition.LOGIC_EQUAL,label:'='},  
							{id:Condition.LOGIC_GREATER,label:'>'},  
							{id:Condition.LOGIC_LESS,label:'<'},  
							{id:Condition.LOGIC_NOTEQUAL,label:'≠'}
						]); 
						logic.width = 80;
						logic.addEventListener(IndexChangeEvent.CHANGING,function(e:IndexChangeEvent){
							condition.logic = e.newIndex;
						});
						var value:TextInput = new TextInput();
						
						value.width = 50;
						value.addEventListener(TextEvent.TEXT_INPUT,function(e:TextEvent){
							condition.value = e.text as int;
						})
						hGroup.addElement(value);
						break;
					}
					case Condition.TYPE_TRIGGER:
					{
						
						break;
					}
					default:
					{
						break;
					}
				}
			});
			var typeChangeEvent:IndexChangeEvent = new IndexChangeEvent("change",false,false,-1,condition.type);
			type.dispatchEvent(typeChangeEvent);
			hGroup.addElement(input);
			hGroup.addElement(type);
			return hGroup;
		}

		public function get editLayer():UIComponent
		{
			return m_editLayer;
		}

		public function get inspector():VGroup
		{
			return m_inspector;
		}

		public static function getInstance():EditController
		{
			return _instance;
		}
		
		private function initStates():void
		{
			var rect1:AnimState = new AnimState("run");
			rect1.y = 200;
			m_editLayer.addChild(rect1);
			m_stateArray.push(rect1);
			var rect2:AnimState = new AnimState("idle");
			m_editLayer.addChild(rect2);
			m_stateArray.push(rect2);
			var rect3:AnimState = new AnimState("attack");
			rect3.x = rect3.y = 200;
			m_editLayer.addChild(rect3);
			m_stateArray.push(rect3);
		}
		
		public function setDefaultState(state:AnimState):void
		{
			if(m_defaultState){
				m_defaultState.isDefaultState = false;
			}
			state.isDefaultState = true;
			m_defaultState = state;
		}
		
		public function getStateByMouse(pt:Point):AnimState
		{
			for each (var state in m_stateArray)
			{
				var rect:Rectangle = state.getRect(state);
				var point:Point = state.globalToLocal(pt);
				if (rect.containsPoint(point)) 
				{
					return state;
				}
			}
			return null;
		}
		
		public function makeTransition(state:AnimState):void
		{
			var transition:AnimTransition = new AnimTransition(state);
			m_transitionArray.push(transition);
		}
		
		public function updateArrow(state:AnimState):void
		{
			for each (var transition in m_transitionArray)
			{
				if(transition.from == state || transition.to == state){
					transition.draw();
				}
			}
		}
		
		public function checkTransitionExist(transition:AnimTransition):void
		{
			for each (var oneTransition in m_transitionArray)
			{
				if(oneTransition != transition && oneTransition.from == transition.from && oneTransition.to == transition.to){
					removeTransition(transition);
					return;
				}
			}
		}
		
		public function removeTransition(transition:AnimTransition):void
		{
			for (var i:int = 0; i < m_transitionArray.length; i++)
			{
				var oneTransition:AnimTransition = m_transitionArray[i];
				if(oneTransition == transition){
					m_transitionArray.splice(i,1);
					oneTransition.destroy();
					Alert.show("Transition Already Exists!")
					return;
				}
			}
		}
		
		public function hasDragState():Boolean
		{
			for each (var state in m_stateArray)
			{
				if (state.isDrag) 
				{
					return true;
				}
			}
			return false;
		}
	}
}