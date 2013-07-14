 package {
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class SimpleRectangle$ {
		
		public var index:Number = -1;

		public var height:Number = 0;
		
		public var left$:SimpleRectangle$ = null;

		public var right$:SimpleRectangle$ = null;

		public var switchBack:Function = null;
		
		public var width:Number = 0;
		
		public var x:Number = 0;
		
		public var y:Number = 0;
		
		/**
		 * Important, in order to sortOn the array with this object type
		 * @return String
		 * 
		 */		
		public function toString():String {
			return String(height);
		}
	}
}