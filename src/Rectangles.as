package  {
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class Rectangles extends MovieClip {
		
		public var rectangleNums:Object;
		
		public var rectanglesBasic:RectanglesBasic;
		
		public var rectanglesStack:RectanglesStack;
		
		public var sliderZoom:Object;
		
		public function Rectangles() {
			/*
			initial values for the Number range
			*/
			rectangleNums.value = 4;
			rectangleNums.minimum = 3;
			rectangleNums.maximum = 30;
			
			/*
			initial values for the slider
			*/
			//sliderZoom.size(400, sliderZoom.height);
			sliderZoom.minimum = 0.1;
			sliderZoom.maximum = 1.5;
			sliderZoom.snapInterval = 0.1;
			sliderZoom.tickInterval = 0.2;
			sliderZoom.value = 1;
			
			//trace("input", rectangleNums.value);
			//trace("sliderZoom", sliderZoom.minimum, sliderZoom.maximum); 
			
			/*
			register evenst for controllers
			*/

			rectanglesBasic = stage.addChildAt(new RectanglesBasic(), 0) as RectanglesBasic;
			rectanglesStack = stage.addChildAt(new RectanglesStack(), 1) as RectanglesStack;

			/*
			providing events, all of them must live as long as possible
			*/
			rectangleNums.addEventListener("change", rectanglesStack.onRemoveChilds);
			rectangleNums.addEventListener("change", rectanglesBasic.onUpdateNumber);
			sliderZoom.addEventListener("change", onUpdateSlider);
			stage.addEventListener("onStackedRectangles", function(evt:Event):void {
				/*
				Sort the array Numericly using height property
				*/
				rectanglesStack.x = rectanglesBasic.x;
				rectanglesStack.scaleX = rectanglesBasic.scaleX;
				rectanglesStack.scaleY = rectanglesBasic.scaleY;
				// create vertically stacked rectangles
				rectanglesStack.create(
					 rectanglesBasic.rects$.sortOn("height", Array.NUMERIC));
			});
			stage.addEventListener("onZoom", function(evt:Event):void {
				// zoom out rectangles if they over the scene
				var container:Sprite = rectanglesBasic.container;
				if(container.width + container.x > stage.stageWidth) {
					_scale(stage.stageWidth - 200);
					sliderZoom.value = Math.abs(container.scaleX);
					trace("zoomed", sliderZoom.value);
				} else {
					// quickly reset to 1 if no zoom applied
					sliderZoom.value = 1;
				}
			});
		}
		
		/**
		 * Round number with strict presicion of 1 decimal point
		 * @param num Any number, can be negative
		 * 
		 */		
		protected function _roundNumber(num:Number):Number {
			return Math.round(num * 10) / 10
		}
		
		/**
		 * Scales object proportionally
		 * @param width Object desired width
		 * 
		 */		
		protected function _scale(width:Number):void {
			for each (var rectangles:Sprite in [rectanglesBasic.container,
												rectanglesStack.container]) {
				var height:Number = (width * rectangles.height) / rectangles.width;
				// incase we deal with inverse orientation
				if(rectangles.scaleX < 0) {
					rectangles.scaleX = -_roundNumber(Math.abs(width/rectangles.width));
				} else {
					rectangles.scaleX = _roundNumber(Math.abs(width/rectangles.width));
				}
				rectangles.scaleY = _roundNumber(height/rectangles.height);
			}
		}
		
		/**
		 * Triggered when slider value changed, scales rectangles when moved
		 * @param evt Event
		 * 
		 */		
		protected function onUpdateSlider(evt:Event):void {
			_scale(rectanglesBasic.container.width * (evt.currentTarget.value));
		}
	}
}
