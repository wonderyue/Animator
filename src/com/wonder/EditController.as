package com.wonder
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
	import spark.components.supportClasses.SkinnableComponent;
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
		private var m_skeletonName:String;
		private var LOGIC_ID:String = "logic";
		private var VALUE_ID:String = "value";
		private var REMOVE_ID:String = "remove";
		
		public function EditController(editLayer:UIComponent,inspector:VGroup)
		{
			m_editLayer = editLayer;
			m_inspector = inspector;
			_instance = this;
			initStates();
		}

		public function get skeletonName():String
		{
			return m_skeletonName;
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
				m_inspector.addElement(createConditionContent(element,transition));
			}
			var hGroup:HGroup = new HGroup();
			var add:Button = new Button();
			add.width = 150;
			add.label = "+ Add Condition";
			add.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void{
				transition.addCondition();
				updateInspector(transition);
			});
			hGroup.addElement(add);
			m_inspector.addElement(add);
		}
		
		private function createConditionContent(condition:Condition,transition:AnimTransition):HGroup
		{
			var hGroup:HGroup = new HGroup();
			var input:TextInput = new TextInput();
			input.width = 50;
			input.text = condition.id;
			input.addEventListener(TextEvent.TEXT_INPUT,function(e:TextEvent):void{
				condition.id = e.target.text + e.text;
			})
			var type:DropDownList = new DropDownList();
			type.dataProvider = new ArrayCollection([  
				{id:Condition.TYPE_BOOL,label:'bool'},  
				{id:Condition.TYPE_NUMBER,label:'number'},  
				{id:Condition.TYPE_TRIGGER,label:'trigger'}  
			]); 
			type.width = 80;
			type.selectedIndex = condition.type;
			type.addEventListener(IndexChangeEvent.CHANGING,function(e:IndexChangeEvent):void{
				typeChange(condition,transition,hGroup,e.newIndex);
			});
			hGroup.addElement(input);
			hGroup.addElement(type);
			typeChange(condition,transition,hGroup,condition.type);
			return hGroup;
		}
		
		private function typeChange(condition:Condition,transition:AnimTransition,hGroup:HGroup,index:int):void
		{
			condition.type = index;
			for (var i:int = 0; i < hGroup.numElements; i++) 
			{
				var element:SkinnableComponent = hGroup.getElementAt(i) as SkinnableComponent;
				if (element.id == LOGIC_ID || element.id == VALUE_ID || element.id == REMOVE_ID) 
				{
					hGroup.removeElementAt(i);
				}
			}
			switch(index)
			{
				case Condition.TYPE_BOOL:
				{
					var boolValue:DropDownList = new DropDownList();
					boolValue.dataProvider = new ArrayCollection([  
						{id:1,label:'true'},  
						{id:0,label:'false'}
					]); 
					boolValue.width = 80;
					boolValue.addEventListener(IndexChangeEvent.CHANGING,function(e:IndexChangeEvent):void{
						condition.value = e.newIndex;
					})
					boolValue.id = LOGIC_ID;
					hGroup.addElement(boolValue);
					condition.logic = Condition.LOGIC_EQUAL;
					boolValue.selectedIndex = condition.value;
					break;
				}
				case Condition.TYPE_NUMBER:
				{
					var numLogic:DropDownList = new DropDownList();
					numLogic.dataProvider = new ArrayCollection([  
						{id:Condition.LOGIC_EQUAL,label:'='},  
						{id:Condition.LOGIC_GREATER,label:'>'},  
						{id:Condition.LOGIC_LESS,label:'<'},  
						{id:Condition.LOGIC_NOTEQUAL,label:'≠'}
					]); 
					numLogic.width = 80;
					numLogic.addEventListener(IndexChangeEvent.CHANGING,function(e:IndexChangeEvent):void{
						condition.logic = e.newIndex;
					});
					var numValue:TextInput = new TextInput();
					numValue.width = 50;
					numValue.text = condition.value.toString();
					numValue.addEventListener(TextEvent.TEXT_INPUT,function(e:TextEvent):void{
						condition.value = parseInt(e.target.text + e.text);
					})
					numLogic.id = LOGIC_ID;
					numValue.id = VALUE_ID;
					hGroup.addElement(numLogic);
					hGroup.addElement(numValue);
					numLogic.selectedIndex = condition.logic;
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
			var remove:Button = new Button();
			remove.width = 25;
			remove.label = "-";
			remove.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void{
				transition.removeCondition(condition);
				updateInspector(transition);
			});
			remove.id = REMOVE_ID;
			hGroup.addElement(remove);
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
		
		public function initStates(input:Array = null,skeletonName:String = "fsm"):void
		{
			m_skeletonName = skeletonName;
			m_editLayer.removeChildren()
			m_inspector.removeAllElements();
			m_stateArray = new Array();
			m_transitionArray = new Array();
			m_arrowContainer = new Sprite();
			m_editLayer.addChild(m_arrowContainer);
			if (input && input.length > 0) 
			{
				for (var i:int = 0; i < input.length; i++) 
				{
					var stateName:String = input[i];
					var state:AnimState = new AnimState(stateName);
					state.x = m_editLayer.width / 5 * 3;
					state.y = m_editLayer.height / input.length * i;
					m_editLayer.addChild(state);
					m_stateArray.push(state);
				}
				var anyState:AnimState = new AnimState("AnyState");
				anyState.x = m_editLayer.width / 5;
				anyState.y = m_editLayer.height / 2;
				m_editLayer.addChild(anyState);
				m_stateArray.push(anyState);
				setDefaultState(AnimState(m_stateArray[0]));
			}
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
			for each (var state:AnimState in m_stateArray)
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
			for each (var transition:AnimTransition in m_transitionArray)
			{
				if(transition.from == state || transition.to == state){
					transition.draw();
				}
			}
		}
		
		public function checkTransitionExist(transition:AnimTransition):void
		{
			for each (var oneTransition:AnimTransition in m_transitionArray)
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
			for each (var state:AnimState in m_stateArray)
			{
				if (state.isDrag) 
				{
					return true;
				}
			}
			return false;
		}
		
		public function save():void
		{
			DataParser.saveFsmJson("test",m_stateArray, m_transitionArray);
		}
	}
}