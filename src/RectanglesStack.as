/**
 * 
 * When was doing the task, came up with idea of optimizing the Left and Right functions
 * This is not a human readble approach, and can not be used in the team with other developers
 * 
 * (pattern for expandLeft and expandRight functions)
 * <code>
 * 		private function reversing(rect$, target$, xRule, defineTarget, definePartner) {
 *			expandBaseRectangle(rect$, target$, xRule,
 *				function(rect$_:SimpleRectangle$, target$_:SimpleRectangle$):SimpleRectangle$ {
 *					* on loop proceed with new target instance
 *					var targetTarget$_:SimpleRectangle$ = defineTarget(target$_);
 *					if(targetTarget$_) {
 *						(function(targetTarget$_, target$_, defineTarget, definePartner) {
 *							targetTarget$_.switchBack = function() {
 *								defineTarget(target$_, this);
 *								definePartner(this, target$_);
 *							};
 *						})(targetTarget$_, target$_, defineTarget, definePartner);
 *						definePartner(targetTarget$_, rect$);
 *					}
 *
 *					defineTarget(rect$_, targetTarget$_);
 *					return targetTarget$_;
 *				});
 *		}
 * 
 * 	  defineTarget = defineTarget || function(rect$_:SimpleRectangle$,
 *		assignment$_:SimpleRectangle$ = null):SimpleRectangle$ {
 *			// assigns left neighbour to the new neighbour, or leave default
 *			// returns the neighbor on the left
 *			return (rect$_.left$ = assignment$_ || rect$_.left$);
 *		};
 *
 *	  definePartner = definePartner || function(rect$_:SimpleRectangle$,
 *		assignment$_:SimpleRectangle$ = null):SimpleRectangle$ {
 *	 		// assigns right neighbour to the new neighbour, or leave default
 *			// returns the neighbor on the right
 *			return (rect$_.right$ = assignment$_ || rect$_.right$);
 *		};
 * </code>
 * 
 */
package
{
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;

	public class RectanglesStack extends RectanglesBasic {
		
		public function RectanglesStack() {
			super();
			
			// default values
			y = 550;
		}
		
		/**
		 * Create new set of rectangles from existing ones 
		 * to form the stacked blocks, without a position change
		 * @param cashedRects$
		 * @param reverseFlag should the function be reversed with different side
		 * 
		 */
		public function create(rects$_:Array,
							   xRule:Function=null):void {
			var i:int = 0;
			// first go through rects on the left
			while(rects$_.length > 0) {
				var rect$:SimpleRectangle$ = rects$_[0] as SimpleRectangle$;
				rect$.index = i;
				
				// move left and right, then go to next rectangle
				extendLeft(rect$);
				extendRight(rect$);
				
				rects$_.shift();
				i++;
			}
		}
		
		/**
		 * General function to handle walk trough 
		 * the childs from Left or Right 
		 * 
		 * @param rect
		 * @param target the nearest neighbour
		 * @param xRule function for x direction (to left)
		 * @param Func_WhatNext
		 * 
		 */		
		private function extend_(rect$_:SimpleRectangle$,
								 target$_:SimpleRectangle$,
								 xRule:Function,
								 neighbour:Function):void {
			var container_:Sprite;
			function redrawRect():void {
				// try to get the child container
				// if fails crates new instance
				try {
					container_ = container.getChildAt(rect$_.index) as Sprite;
				} catch(e:RangeError) {
					container_ = container.addChildAt(new Sprite(), rect$_.index) as Sprite;
				}
				
				// be sure the items complete deleted, clean them all
				for (var j:int = 0; j < container_.numChildren; j++) {
					container_.removeChildAt(j);
				}
				
				// adding child to the container
				var rect_:Shape = container_.addChild(draw(rect$_.width,
																	  rect$_.height)) as Shape;
				// setting the coordinates from simple rectangle object
				rect_.x = rect$_.x;
				rect_.y = rect$_.y;
			}
			
			xRule = xRule || function(target:SimpleRectangle$):int { return 0 }
			
			while(target$_ != null) {
				// proceed to the neighbour that only has less height than you
				// and position is lower than yours
				if(!(target$_.y <= rect$_.y &&
					(rect$_.height + rect$_.y <= target$_.height + target$_.y))) {
					
					target$_ = null;
					break;					
				}
				
				// increasing width
				// simultaneously with xRule (ment for left direction,
				// when x coordinate must be involved
				rect$_.width += target$_.width;
				rect$_.x += xRule(target$_);
				target$_.height = Math.abs(target$_.height - rect$_.height);
				target$_.y += rect$_.height
				
				redrawRect();
				if(target$_.switchBack != null)
					target$_.switchBack();
				target$_ = neighbour(rect$_, target$_);
			}
			
			// redraw rectangle again in case no naigbours at the very beginning
			if(target$_ == null) {
				redrawRect();
			}
		}
		
		/**
		 * Expands a rectangle to neighbours on the right side
		 * @param rect$ SimpleRectangle$
		 * 
		 */
		public final function extendLeft(rect$:SimpleRectangle$):void {
			extend_(rect$, rect$.left$,
				function(target$_:SimpleRectangle$):int {
					// rule for moving x-axis on the left, it is minus from origin
					return -target$_.width;
				},
				function(rect$_:SimpleRectangle$, target$_:SimpleRectangle$):SimpleRectangle$ {
					var targetTarget$_:SimpleRectangle$ = target$_.left$;
					if(targetTarget$_) {
						// !important
						// after neighbour was visited, his left 
						// neighbour should return to original
						(function(targetTarget$_:SimpleRectangle$, target$_:SimpleRectangle$):void {
							targetTarget$_.switchBack = function():void {
								target$_.left$ = this;
								SimpleRectangle$(this).right$ = target$_;
							};
						})(targetTarget$_, target$_);
						targetTarget$_.right$ = rect$_;
					}
					
					rect$_.left$ = targetTarget$_;
					return targetTarget$_;
				});
		}
		
		/**
		 * Expands a rectangle to neighbours on the left side
		 * @param rect$ SimpleRectangle$
		 * 
		 */		
		public final function extendRight(rect$:SimpleRectangle$):void {
			extend_(rect$, rect$.right$, null,
				function(rect$_:SimpleRectangle$, target$_:SimpleRectangle$):SimpleRectangle$ {
					var targetTarget$_:SimpleRectangle$ = target$_.right$;
					if(targetTarget$_) {
						// !important
						// after neighbour was visited, his right 
						// neighbour should return to original
						(function(targetTarget$_:SimpleRectangle$, target$_:SimpleRectangle$):void {
							targetTarget$_.switchBack = function():void {
								target$_.right$ = this;
								SimpleRectangle$(this).left$ = target$_;
							};
						})(targetTarget$_, target$_);
						targetTarget$_.left$ = rect$_;
					}
					
					rect$_.right$ = targetTarget$_;
					return targetTarget$_;
				});
		}
		
		/**
		 * Performs cleanup for rectangles container,
		 * rectangles must be deleted before new set of 
		 * rectangles will be created
		 * @param evt
		 * 
		 */		
		public function onRemoveChilds(evt:Event):void {
			__clearRectangles();
		}
	}
}