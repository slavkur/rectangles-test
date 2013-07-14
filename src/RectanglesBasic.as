package {
	
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class RectanglesBasic extends Sprite {
		
		protected const borderSize:int = 2;
		
		public var container:Sprite;
		
		protected const maximumRectSize:int = 200;

		protected const minimumRectSize:int = 30;
		
		public var rects$:Array = [];
		
		public function RectanglesBasic() {
			super();
			
			// default values
			container = addChildAt(new Sprite(), 0) as Sprite;
			rotation = 180;
			scaleX = -1;
			x = 50;
			y = 300;
		}
		
		/**
		 * Internal method to wipe out previous instances of rectangles
		 */		
		protected function __clearRectangles():void {
			// wipe before inserting rectangles
			removeChild(container);
			container = addChildAt(new Sprite(), 0) as Sprite;
		}
		
		/**
		 * Internal method for random number between ranges
		 * @param from Any integer can be negative
		 * @param to Any positive number
		 * 
		 */		
		protected function _random(from:uint, to:uint):uint {
			return Math.floor(Math.random() * (to - from + 1) + from);
		}
		
		/**
		 * Creates basic rectangle with borders, no background is applied
		 * @param width
		 * @param height
		 * @param borderSize (optional)
		 * @return Shape of the rectangle
		 * 
		 */		
		protected function draw(width:Number, height:Number):Shape {
			var rect:Shape = new Shape();
			rect.graphics.lineStyle(borderSize, 0x000000);
			
			// initial position is Point(0,0)
			// random values between 10 and 200 for width and height
			rect.graphics.drawRect(0, 0, width, height);
			
			return rect;
		}
		
		/**
		 * Event listener method triggered when number of 
		 * requested rectangles has changed.
		 * Forces to redraw rectangles, wipes out the old
		 * 
		 * @param evt Event
		 * @param minimumWidth (optional)
		 * @param minimumHeight (optional)
		 * 
		 */		
		public function onUpdateNumber(evt:Event):void {
			/*
			Initialize instances for processing heights
			*/
			__clearRectangles();

			for (var i:int = 0; i < evt.currentTarget.value; i++) {
				var rect$:SimpleRectangle$ = new SimpleRectangle$();
				var rect:Shape = container.addChildAt(
					draw(_random(minimumRectSize, maximumRectSize),
						_random(minimumRectSize, maximumRectSize)), i) as Shape;
				
				rect$.x = rect.x;
				rect$.width = rect.width;
				if(container.numChildren > 1) {
					// taking information about x-position from previous rect
					var index:int = container.getChildIndex(rect) - 1;
					var prevRect:Shape = container.getChildAt(index) as Shape;
					
					// adjust nicer view by folding the border-to-border connection
					rect.x = prevRect.x + prevRect.width - borderSize;
					rect$.x = rect.x + borderSize;
					rect$.width = rect.width - borderSize;
					
					// updating information about nighbour rectangle on the Left
					rect$.left$ = rects$[index];
					// updating information about nighbour rectangle on the Right
					if(rect$.left$) {
						SimpleRectangle$(rect$.left$).right$ = rect$;
					}
				}
				
				// updating cached rect with rect instance
				rect$.height = rect.height;
				rect$.y = rect.y;
				
				// push rectangles to the array to read
				rects$.push(rect$);
			}
			
			// fire the stack rectangles event to the stage
			stage.dispatchEvent(new Event("onStackedRectangles"));
			stage.dispatchEvent(new Event("onZoom"));
		}
	}
}