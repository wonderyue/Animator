package com.wonder
{
	import flash.events.Event;
	import flash.events.FileListEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.FileFilter;

	public class DataParser
	{
		private static var FILETYPE_SKELETON:int = 1;
		private static var FILETYPE_FSM:int = 2;
		
		private static function generateJson(stateArr:Array,transitionArr:Array,paramArr:Array,armatureInfo:Object):String
		{
			var output:String = "";
			var stateJsonArr:Array = new Array();
			for each (var state:AnimState in stateArr) 
			{
				var stateObj:Object = new Object();
				stateObj["state"] = state.id;
				stateObj["animation"] = state.animation;
				stateObj["transition"] = new Array();
				stateObj["x"] = state.x;
				stateObj["y"] = state.y;
				if (state.isDefaultState) 
				{
					stateObj.default = true;
				}
				for each (var transition:AnimTransition in transitionArr) 
				{
					if (transition.from == state) 
					{
						var transitionObj:Object = new Object();
						transitionObj["nextState"] = transition.to.id;
						transitionObj.condition = new Array();
						for each (var condition:Condition in transition.conditionArray) 
						{
							if (condition.type == Parameter.TYPE_COMPLETE) 
							{
								condition.id = Parameter.COMPLETE_ID;
							}
							if (condition.id) 
							{
								var conditionObj:Object = new Object();
								conditionObj["id"] = condition.id;
								conditionObj["type"] = condition.type;
								conditionObj["logic"] = condition.logic;
								conditionObj["value"] = condition.value;
								transitionObj.condition.push(conditionObj);
							}
						}
						stateObj.transition.push(transitionObj);
					}
				}
				stateJsonArr.push(stateObj);
			}
			var paramJsonArr:Array = new Array();
			for each (var param:Parameter in paramArr) 
			{
				paramJsonArr.push({"id":param.id, "type":param.type});
			}
			return JSON.stringify({"state":stateJsonArr, "parameter":paramArr, "armatureInfo":armatureInfo});
		}
		
		private static function saveFile(fileName:String, content:String):void
		{
			var fileToSave:File = File.documentsDirectory;
			fileToSave = fileToSave.resolvePath(fileName);
			fileToSave.browseForSave("Select Directory");
			fileToSave.addEventListener(Event.SELECT, directorySelected);
			
			function directorySelected(event:Event):void 
			{
				var file:File = event.target as File;
				var fileStream:FileStream = new FileStream();
				fileStream.open(file, FileMode.WRITE);
				fileStream.writeUTFBytes(content);
			}
		}
		
		public static function browseForOpenFile():void
		{
			var fileToSave:File = File.documentsDirectory;
			fileToSave.browseForOpenMultiple("Select Directory",[new FileFilter("Text", "*.json")]);
			fileToSave.addEventListener(FileListEvent.SELECT_MULTIPLE, onFileSelect);
			function onFileSelect(event:FileListEvent):void 
			{
				parseFiles(event.files);
			}
		}
		
		public static function parseFiles(files:Array):void
		{
			if(files.length == 1){
				parseSingleFile(files[0]);
			}else{
				for (var i:int = 0; i < files.length; i++)
				{
					var file:File = files[i];
					parseSingleFile(file, i>0);
				}
			}
		}
		
		private static function parseSingleFile(file:File, isAppend:Boolean=false):void
		{
			var fs:FileStream = new FileStream(); 
			fs.open(File(file),FileMode.READ); 
			var content:String = fs.readUTFBytes(fs.bytesAvailable); 
			fs.close();
			
			var type:int;
			if (file.name.indexOf("fsm.json") != -1) 
			{
				type = FILETYPE_FSM;
			}
			else if (file.name.indexOf("skeleton.json") != -1) 
			{
				type = FILETYPE_SKELETON;
			}
			
			switch(type)
			{
				case FILETYPE_SKELETON:
				{
					var obj:Object = JSON.parse(content);
					var stateStrArr:Array = new Array();
					var animationArr:Array = new Array();
					for each (var ani:Object in obj["armature"][0]["animation"]) 
					{
						stateStrArr.push({"state":ani["name"],"animation":ani["name"]});
						if (animationArr.indexOf(ani["name"]) == -1) 
						{
							animationArr.push(ani["name"]);
						}
					}
					if (isAppend) 
					{
						EditController.getInstance().addStates(stateStrArr);
						EditController.getInstance().armatureInfo[obj["armature"][0]["name"]] = animationArr;
					}else{
						EditController.getInstance().initStates(stateStrArr,obj["armature"][0]["name"]);
						EditController.getInstance().armatureInfo = new Object();
						EditController.getInstance().armatureInfo[obj["armature"][0]["name"]] = animationArr;
					}
					break;
				}
				case FILETYPE_FSM:
				{
					var contentObj:Object =  JSON.parse(content);
					var stateArr:Array = contentObj["state"];
					var paramArr:Array = contentObj["parameter"];
					var armatureInfo:Object = contentObj["armatureInfo"];
					var stateStrArray:Array = new Array();
					for each (var oneStateObj:Object in stateArr) 
					{
						if (oneStateObj["state"] != AnimState.ANYSTATE_ID) 
						{
							stateStrArray.push({"state":oneStateObj["state"],"animation":oneStateObj["animation"]});
						}
					}
					EditController.getInstance().initStates(stateStrArray,file.name.split(".")[0]);
					for each (var state:AnimState in EditController.getInstance().stateArray) 
					{
						for each (var stateObj:Object in stateArr) 
						{
							if (stateObj["state"] == state.id) 
							{
								state.x = stateObj["x"];
								state.y = stateObj["y"];
								for each (var transitionObj:Object in stateObj["transition"]) 
								{
									var transition:AnimTransition = EditController.getInstance().makeTransition(state,false);
									transition.to = EditController.getInstance().getStateById(transitionObj["nextState"]);
									for each (var conditionObj:Object in transitionObj.condition) 
									{
										var condition:Condition = transition.addCondition();
										condition.id = conditionObj["id"];
										condition.type = conditionObj["type"];
										condition.logic = conditionObj["logic"];
										condition.value = conditionObj["value"];
									}
								}
							}
							EditController.getInstance().updateArrow(state);
						}
					}
					for each (var oneParamObj:Object in paramArr) 
					{
						EditController.getInstance().addParam(new Parameter(oneParamObj["id"], oneParamObj["type"]));
					}
					EditController.getInstance().armatureInfo = armatureInfo;
					break;
				}
				default:
				{
					break;
				}
			}
		}
		
		public static function saveFsmJson(fileName:String,stateArr:Array,transitionArr:Array,paramArr:Array,armatureInfo:Object):void
		{
			saveFile(fileName+(fileName.indexOf("fsm") == -1?"_fsm.json":".json"),generateJson(stateArr,transitionArr,paramArr,armatureInfo));
		}
	}
}