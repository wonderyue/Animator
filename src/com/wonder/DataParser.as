package com.wonder
{
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;

	public class DataParser
	{
		private static var FILETYPE_SKELETON:int = 1;
		
		private static function generateJson(stateArr:Array,transitionArr:Array):String
		{
			var output:String = "";
			var stateJsonArr:Array = new Array();
			for each (var state:AnimState in stateArr) 
			{
				var stateObj:Object = new Object();
				stateObj.state = state.id;
				stateObj.transition = new Array();
				if (state.isDefaultState) 
				{
					stateObj.default = true;
				}
				for each (var transition:AnimTransition in transitionArr) 
				{
					if (transition.from == state) 
					{
						var transitionObj:Object = new Object();
						transitionObj.nextState = transition.to.id;
						transitionObj.condision = new Array();
						for each (var condition:Condition in transition.conditionArray) 
						{
							if (condition.id) 
							{
								var conditionObj:Object = new Object();
								conditionObj.id = condition.id;
								conditionObj.type = condition.type;
								conditionObj.logic = condition.logic;
								conditionObj.value = condition.value;
								transitionObj.condision.push(conditionObj);
							}
						}
						stateObj.transition.push(transitionObj);
					}
				}
				stateJsonArr.push(stateObj);
			}
			return JSON.stringify(stateJsonArr);
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
		
		private static function readFile(type:int):void
		{
			var fileToSave:File = File.documentsDirectory;
			fileToSave.browseForOpen("Select Directory");
			fileToSave.addEventListener(Event.SELECT, onFileSelect);
			
			function onFileSelect(event:Event):void 
			{
				var fs:FileStream = new FileStream(); 
				fs.open(File(event.target),FileMode.READ); 
				var content:String = fs.readUTFBytes(fs.bytesAvailable); 
				fs.close();
				switch(type)
				{
					case FILETYPE_SKELETON:
					{
						var obj:Object = JSON.parse(content);
						var stateStrArr:Array = new Array();
						for each (var ani:Object in obj.armature[0].animation) 
						{
							stateStrArr.push(ani.name);
						}
						EditController.getInstance().initStates(stateStrArr,obj.armature[0].animation.name);
						break;
					}
					default:
					{
						break;
					}
				}
			}
		}
		
		public static function saveFsmJson(fileName:String,stateArr:Array,transitionArr:Array):void
		{
			saveFile(fileName+".json",generateJson(stateArr,transitionArr));
		}
		
		public static function parseSkeletonJson():void
		{
			readFile(FILETYPE_SKELETON);
		}
	}
}