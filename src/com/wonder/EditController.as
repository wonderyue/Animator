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
	import spark.components.Image;
	import spark.components.Panel;
	import spark.components.Scroller;
	import spark.components.TextInput;
	import spark.components.VGroup;
	import spark.components.supportClasses.SkinnableComponent;
	import spark.events.IndexChangeEvent;
	import spark.events.TextOperationEvent;
	import spark.layouts.VerticalAlign;

	public class EditController
	{
		private static var _instance:EditController;
		private var m_editLayer:Sprite;
		private var m_inspector:VGroup; 
		private var m_stateInputer:TextInput;
		private var m_animationInputer:TextInput;
		private var m_stateArray:Array;
		private var m_transitionArray:Array;
		private var m_paramArray:Array;
		private var m_defaultState:AnimState = null;
		private var m_arrowContainer:Sprite;
		private var m_curArrow:AnimTransition = null;
		private var m_skeletonName:String;
		private var m_curState:AnimState = null;
		private var INPUT_ID:String = "input";
		private var LOGIC_ID:String = "logic";
		private var VALUE_ID:String = "value";
		private var REMOVE_ID:String = "remove";
		private var m_paramList:VGroup;
		private var m_paramScroller:Scroller;
		private var m_paramPanel:Panel;
		
		public static function getInstance():EditController
		{
			return _instance;
		}
		
		public function EditController(main:Animator)
		{
			m_editLayer = main.editLayer;
			m_inspector = main.transitionInspector;
			m_stateInputer = main.stateIdInputer;
			m_animationInputer = main.animationInputer;
			m_paramList = main.paramList;
			m_paramScroller = main.paramScroller;
			m_paramPanel = main.paramPanel;
			_instance = this;
			initStates();
			m_stateInputer.addEventListener(TextOperationEvent.CHANGE,function(e:TextOperationEvent):void{
				m_curState.id = e.target.text;
			})
			m_animationInputer.addEventListener(TextOperationEvent.CHANGE,function(e:TextOperationEvent):void{
				m_curState.animation = e.target.text;
			})
		}
		
		public function addState(id:String = "Untitled", x:Number = 0, y:Number = 0):AnimState
		{
			var state:AnimState = new AnimState(id);
			state.x = x;
			state.y = y;
			m_editLayer.addChild(state);
			m_stateArray.push(state);
			return state;
		}
		
		public function initStates(input:Array = null,skeletonName:String = "fsm"):void
		{
			m_skeletonName = skeletonName;
			m_editLayer.removeChildren()
			m_inspector.removeAllElements();
			m_paramList.removeAllElements();
			m_stateArray = new Array();
			m_transitionArray = new Array();
			m_arrowContainer = new Sprite();
			m_curArrow = null;
			m_curState = null;
			m_editLayer.addChild(m_arrowContainer);
			if (input && input.length > 0) 
			{
				for (var i:int = 0; i < input.length; i++) 
				{
					var stateName:String = input[i];
					addState(stateName, m_editLayer.width / 2 - 200 + 250*Math.cos(i/input.length*Math.PI-Math.PI*0.75), m_editLayer.height / 2 + 250*Math.sin(i/input.length*Math.PI-Math.PI*0.75));
				}
				var anyState:AnimState = addState(AnimState.ANYSTATE_ID, m_editLayer.width / 7 * 3, m_editLayer.height / 2);
				setDefaultState(AnimState(m_stateArray[0]));
			}
			m_paramArray = new Array();
			m_paramArray.push(new Parameter(Parameter.COMPLETE_ID, Parameter.TYPE_COMPLETE));
		}
		
		public function addStates(input:Array):void
		{
			if (input && input.length > 0) 
			{
				for (var i:int = 0; i < input.length; i++) 
				{
					var stateName:String = input[i];
					addState(stateName, m_editLayer.width / 2 - 200 + 250*Math.cos((i+m_stateArray.length)/input.length*Math.PI-Math.PI*0.75), m_editLayer.height / 2 + 250*Math.sin((i+m_stateArray.length)/input.length*Math.PI-Math.PI*0.75));
				}
			}
		}

		public function set paramArray(value:Array):void
		{
			m_paramArray = value;
		}

		public function get paramArray():Array
		{
			return m_paramArray;
		}

		public function get stateArray():Array
		{
			return m_stateArray;
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
			if (value) 
			{
				value.isSelected = true;
			}
			updateTransitionInspector(m_curArrow);
		}
		
		public function get curState():AnimState
		{
			return m_curState;
		}

		public function set curState(value:AnimState):void
		{
			if (m_curState) 
			{
				m_curState.isSelected = false;
			}
			m_curState = value;
			if (value) 
			{
				value.isSelected = true;
			}
			updateStateInfo(m_curState);
		}
		
		public function addParam(param:Parameter):void
		{
			m_paramArray.push(param);
			var hGroup:HGroup = new HGroup();
			hGroup.verticalAlign = VerticalAlign.MIDDLE;
			var input:TextInput = new TextInput();
			input.text = param.id;
			input.addEventListener(TextOperationEvent.CHANGE,function(e:TextOperationEvent):void{
				param.id = e.target.text;
			})
			input.width = 60;
			var type:DropDownList = new DropDownList();
			type.dataProvider = new ArrayCollection([
				{id:Parameter.TYPE_BOOL,label:'bool'},  
				{id:Parameter.TYPE_NUMBER,label:'number'},  
				{id:Parameter.TYPE_TRIGGER,label:'trigger'}
			]); 
			type.width = 80;
			type.selectedIndex = param.type - Parameter.TYPE_BOOL;
			type.addEventListener(IndexChangeEvent.CHANGING,function(e:IndexChangeEvent):void{
				param.type = type.selectedItem.id;
			});
			var remove:Image = new Image();
			remove.source = "assets/-.png";
			remove.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void{
				EditController.getInstance().removeParam(param);
				m_paramList.removeElement(hGroup);
			});
			hGroup.addElement(input);
			hGroup.addElement(type);
			hGroup.addElement(remove);
			m_paramList.addElement(hGroup);
			if (m_paramPanel.height < m_paramPanel.maxHeight) 
			{
				m_paramPanel.height += 30;
			}
			m_paramScroller.validateNow();
			m_paramScroller.viewport.verticalScrollPosition=m_paramScroller.viewport.contentHeight;
		}
		
		public function removeParam(param:Parameter):void
		{
			for (var i:int = 0; i < m_paramArray.length; i++)
			{
				var oneParam:Parameter = m_paramArray[i];
				if(param == oneParam){
					m_paramArray.splice(i,1);
					return;
				}
			}
		}

		private function updateTransitionInspector(transition:AnimTransition):void
		{
			m_inspector.removeAllElements();
			if (transition) 
			{
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
					updateTransitionInspector(transition);
				});
				hGroup.addElement(add);
				m_inspector.addElement(add);
			}
		}
		
		private function createConditionContent(condition:Condition,transition:AnimTransition):HGroup
		{
			var hGroup:HGroup = new HGroup();
			hGroup.verticalAlign = VerticalAlign.MIDDLE;
			var type:DropDownList = new DropDownList();
			type.dataProvider = new ArrayCollection([
				{id:Parameter.TYPE_COMPLETE,label:'complete'},
				{id:Parameter.TYPE_BOOL,label:'bool'},  
				{id:Parameter.TYPE_NUMBER,label:'number'},  
				{id:Parameter.TYPE_TRIGGER,label:'trigger'}
			]); 
			type.width = 90;
			type.selectedIndex = condition.type;
			type.addEventListener(IndexChangeEvent.CHANGING,function(e:IndexChangeEvent):void{
				typeChange(condition,transition,hGroup,type.selectedItem.id);
			});
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
				if (element.id == LOGIC_ID || element.id == VALUE_ID || element.id == REMOVE_ID || element.id == INPUT_ID) 
				{
					hGroup.removeElementAt(i);
					i--;
				}
			}
			switch(index)
			{
				case Parameter.TYPE_BOOL:
				{
					var boolId:TextInput = new TextInput();
					boolId.width = 50;
					boolId.text = condition.id;
					boolId.addEventListener(TextOperationEvent.CHANGE,function(e:TextOperationEvent):void{
						condition.id = e.target.text;
					})
					boolId.id = INPUT_ID;
					hGroup.addElement(boolId);	
					var boolValue:DropDownList = new DropDownList();
					boolValue.dataProvider = new ArrayCollection([  
						{id:0,label:'false'},
						{id:1,label:'true'}
					]); 
					boolValue.width = 65;
					boolValue.id = VALUE_ID;
					boolValue.addEventListener(IndexChangeEvent.CHANGING,function(e:IndexChangeEvent):void{
						condition.value = boolValue.selectedItem.id;
					})
					hGroup.addElement(boolValue);
					condition.logic = Condition.LOGIC_EQUAL;
					boolValue.selectedIndex = condition.value;
					break;
				}
				case Parameter.TYPE_NUMBER:
				{
					var numId:TextInput = new TextInput();
					numId.width = 50;
					numId.text = condition.id;
					numId.addEventListener(TextOperationEvent.CHANGE,function(e:TextOperationEvent):void{
						condition.id = e.target.text;
					})
					numId.id = INPUT_ID;
					hGroup.addElement(numId);
					var numLogic:DropDownList = new DropDownList();
					numLogic.dataProvider = new ArrayCollection([  
						{id:Condition.LOGIC_EQUAL,label:'='},  
						{id:Condition.LOGIC_GREATER,label:'>'},  
						{id:Condition.LOGIC_LESS,label:'<'},  
						{id:Condition.LOGIC_NOTEQUAL,label:'≠'}
					]); 
					numLogic.width = 65;
					numLogic.addEventListener(IndexChangeEvent.CHANGING,function(e:IndexChangeEvent):void{
						condition.logic = numLogic.selectedItem.id;;
					});
					var numValue:TextInput = new TextInput();
					numValue.width = 50;
					numValue.id = VALUE_ID;
					numValue.text = condition.value.toString();
					numValue.addEventListener(TextOperationEvent.CHANGE,function(e:TextOperationEvent):void{
						condition.value = parseInt(e.target.text);
					})
					numLogic.id = LOGIC_ID;
					hGroup.addElement(numLogic);
					hGroup.addElement(numValue);
					numLogic.selectedIndex = condition.logic;
					break;
				}
				case Parameter.TYPE_TRIGGER:
				{
					var triggerId:TextInput = new TextInput();
					triggerId.width = 50;
					triggerId.text = condition.id;
					triggerId.addEventListener(TextOperationEvent.CHANGE,function(e:TextOperationEvent):void{
						condition.id = e.target.text;
					})
					triggerId.id = INPUT_ID;
					hGroup.addElement(triggerId);
					break;
				}
				case Parameter.TYPE_COMPLETE:
				{
					break;
				}
				default:
				{
					break;
				}
			}
			var remove:Image = new Image();
			remove.source = "assets/-.png";
			remove.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void{
				transition.removeCondition(condition);
				updateTransitionInspector(transition);
			});
			remove.id = REMOVE_ID;
			hGroup.addElement(remove);
		}

		public function get editLayer():Sprite
		{
			return m_editLayer;
		}

		public function get inspector():VGroup
		{
			return m_inspector;
		}

		public function setDefaultState(state:AnimState):void
		{
			if(m_defaultState){
				m_defaultState.isDefaultState = false;
			}
			state.isDefaultState = true;
			m_defaultState = state;
		}
		
		public function getStateById(id:String):AnimState
		{
			for each (var state:AnimState in m_stateArray)
			{
				if (state.id == id) 
				{
					return state;
				}
			}
			return null;
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
		
		public function updateStateInfo(state:AnimState):void
		{
			m_stateInputer.text = state.id;
			m_animationInputer.text = state.animation;
		}
		
		public function makeTransition(state:AnimState,addDefaultCondition:Boolean = true):AnimTransition
		{
			var transition:AnimTransition = new AnimTransition(state);
			m_transitionArray.push(transition);
			if (addDefaultCondition) 
			{
				transition.addCondition();
			}
			return transition;
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
					Alert.show("Transition Already Exists!")
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
			DataParser.saveFsmJson(m_skeletonName, m_stateArray, m_transitionArray);
		}
	}
}