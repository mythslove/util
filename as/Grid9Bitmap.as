package
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class Grid9Bitmap extends Bitmap
	{
		/**
		 * 默认方式
		 */
		public static const CONVERTTYPE_NONE : int = 0;
		/**
		 * 九宫格平铺方式
		 */
		public static const CONVERTTYPE_REPEAT : int = 1;
		/**
		 * 九宫格拉伸方式
		 */
		public static const CONVERTTYPE_GRID9 : int = 2;
		
		private var _type : int;
		
		private var _data : BitmapData;
		
		private var _width : Number;
		private var _height : Number;
		private var _top : Number = 5;
		private var _bottom : Number = 5;
		private var _left : Number = 5;
		private var _right : Number = 5;
		
		private var _pieces : Vector.<BitmapData> = new Vector.<BitmapData>();
		
		public function BitmapGrid9(bitmapData:BitmapData=null,type:int = CONVERTTYPE_NONE, pixelSnapping:String="auto", smoothing:Boolean=false)
		{
			super(bitmapData,pixelSnapping,smoothing)
			_type = type;
			init();
		}
		
		public function dispose():void
		{
			if (_pieces.length > 0)
			{
				_pieces.splice(0,_pieces.length);
			}
			if (bitmapData)
			{
				bitmapData.dispose();
				bitmapData = null;
			}
			if (_data)
			{
				_data.dispose();
				_data = null;
			}
		}
		/**
		 * 设置转换数据
		 * @param width
		 * @param height
		 * @param top
		 * @param bottom
		 * @param left
		 * @param right
		 */
		public function setGridData(width:Number, height:Number,top : Number = 5, bottom : Number = 5, left : Number = 5, right : Number = 5,type:int = CONVERTTYPE_GRID9) : void
		{
			_type = type;
			_width = width;
			_height = height;
			_top = top;
			_bottom = bottom;
			_left = left;
			_right = right;
			
			init();
		}
		/**
		 * 初始化状态并重绘
		 * 重置拼接方式后调用
		 */
		private function init():void
		{
			if (_data == null)
			{
				if (bitmapData == null)
				{
					return;
				}
				_data = bitmapData.clone();
			}
			slice();
			
			invalidate();
		}
		/**
		 * 图片切片
		 */		
		private function slice():void
		{
			if (_pieces.length > 0)
			{
				_pieces.splice(0,_pieces.length);
			}
			
			if (_width <= _left + _right)
			{
				_left = _right = (_width-2)/2;
			}
			if (_height <= _top + _bottom)
			{
				_top = _bottom = (_height-2)/2;
			}
			
			var arrSX : Array = [0,_left,_data.width - _right];
			var arrSY : Array = [0,_top,_data.height - _bottom];
			var arrSW : Array = [_left,_data.width - _left - _right,_right];
			var arrSH : Array = [_top,_data.height - _top - _bottom,_bottom];
			
			var pic : BitmapData;
			for (var i:int = 0; i < 3; i++) 
			{
				for (var j:int = 0; j < 3; j++) 
				{
					pic = new BitmapData(arrSW[j],arrSH[i],_data.transparent,0);
					pic.copyPixels(_data,new Rectangle(arrSX[j],arrSY[i],arrSW[j],arrSH[i]),new Point(0,0));
					_pieces.push(pic);
				}
			}
		}
		/**
		 * 重绘
		 */
		public function validate():void
		{
			var arrX : Array = [0,_left,_width - _right];
			var arrY : Array = [0,_top,_height - _bottom];
			var arrW : Array = [_left,_width - _left - _right,_right];
			var arrH : Array = [_top,_height - _top - _bottom,_bottom];
			
			var result : BitmapData = new BitmapData(_width,_height,_data.transparent,0);
			
			var tempBmd : BitmapData;
			for (var k:int = 0,n : int = 0; k < 3; k++)
			{
				for (var u:int = 0; u < 3; u++,n++)
				{
					if (_type == CONVERTTYPE_REPEAT)
					{
						tempBmd = concatBitmapData(_pieces[n],arrW[u],arrH[k]);//九宫格平铺方式拼接图片
					}
					else if (_type == CONVERTTYPE_GRID9)
					{
						tempBmd = scale(_pieces[n],arrW[u],arrH[k]);//九宫格缩放方式拼接图片
					}
					if (tempBmd)
					{
						result.copyPixels(tempBmd,new Rectangle(0,0,tempBmd.width,tempBmd.height),new Point(arrX[u],arrY[k]));
						tempBmd.dispose();
					}
				}
			}
			
			if (bitmapData)
			{
				bitmapData.dispose();
			}
			super.bitmapData = result;
		}
		/**
		 * 使生效，将在下一帧中更新
		 */
		public function invalidate () : void
		{
			addEventListener(Event.ENTER_FRAME, onEnterFrameHandler , false ,0 , true);
		}
		
		protected function onEnterFrameHandler (e : Event) : void
		{
			removeEventListener(Event.ENTER_FRAME, onEnterFrameHandler);
			validate();
		}
		
		public function set type(value:int):void
		{
			if (_type == value)
				return;
			_type = value;
			
			init();
		}
		
		public function get isNone():Boolean
		{
			return _type == CONVERTTYPE_NONE;
		}
		
		public function get isRepeat():Boolean
		{
			return _type == CONVERTTYPE_REPEAT;
		}
		
		public function get isGrid9():Boolean
		{
			return _type == CONVERTTYPE_GRID9;
		}
		
		override public function set bitmapData(value:BitmapData):void
		{
			if (isNone) 
			{
				super.bitmapData = value;
			}
			else
			{
				_data = value.clone();
				init();
			}
		}
		
		/**
		 * 平铺
		 * @param src
		 * @param width
		 * @param height
		 * @param offsetX
		 * @param offsetY
		 * @param disposeSource
		 * @return 
		 */
		public static function concatBitmapData(src : BitmapData,width : Number, height : Number,offsetX : Number=0,offsetY : Number=0,disposeSource : Boolean=false):BitmapData
		{
			var result : BitmapData = concatBitmapDataH(src,width);
			result = concatBitmapDataV(result,height,0,true);
			if (src && disposeSource)
			{
				src.dispose();
			}
			return result;
		}
		/**
		 * 横向平铺
		 * */
		public static function concatBitmapDataH(src : BitmapData,destWidth : Number,offset : Number=0,disposeSource : Boolean=false):BitmapData
		{
			var srcWidth : Number = src.width;
			var result : BitmapData;
			if(srcWidth == destWidth)
			{
				result = src.clone();
			}
			else
			{
				var srcHeight : Number = src.height;
				result = new BitmapData(destWidth,srcHeight,src.transparent,0);
				
				var n : uint = destWidth/srcWidth;
				for (var i:int = 0; i < n; i++)
				{
					result.copyPixels(src,new Rectangle(0,0,srcWidth,srcHeight),new Point(srcWidth * i + offset * (i - 1),0));
				}
				var rest : Number = destWidth - srcWidth * n;
				if (rest > 0)
					result.copyPixels(src,new Rectangle(0,0,rest,srcHeight),new Point(srcWidth * n + offset * (n - 1),0));
			}
			if (src && disposeSource)
			{
				src.dispose();
			}
			return result;
		}
		/**
		 * 纵向平铺
		 * */
		public static function concatBitmapDataV(src : BitmapData,destHeight : Number,offset : Number=0,disposeSource:Boolean=false):BitmapData
		{
			var srcHeight : Number = src.height;
			var result : BitmapData;
			if(srcHeight == destHeight)
			{
				result = src.clone();
			}
			else
			{
				var srcWidth : Number = src.width;
				result = new BitmapData(srcWidth,destHeight,src.transparent,0);
				var n : uint = destHeight/srcHeight;
				for (var i:int = 0; i < n; i++)
				{
					result.copyPixels(src,new Rectangle(0,0,srcWidth,srcHeight),new Point(0,srcHeight * i + offset * (i - 1)));
				}
				var rest : Number = destHeight - srcHeight * n;
				if (rest > 0)
					result.copyPixels(src,new Rectangle(0,0,srcWidth,rest),new Point(0,srcHeight * n + offset * (n - 1)));
			}
			if (src && disposeSource)
			{
				src.dispose();
			}
			return result;
		}
		/**
		 * 缩放BitmapData
		 * @param src ：BitmapData 数据源
		 * @param width:Number =1.0 横向拉伸宽度
		 * @param height:Number =1.0 纵向拉伸长度
		 * @param disposeSource :Boolean = true 是否释放src的内存
		 * @return 
		 */
		public static function scale(src:BitmapData,width:Number,height:Number,disposeSource:Boolean = false):BitmapData
		{
			var result:BitmapData;
			if (src.width == width && src.height == height)
			{
				result = src.clone();
			}
			else
			{
				result = new BitmapData(width,height,src.transparent,0);
				var m:Matrix = new Matrix();
				m.scale(width/src.width,height/src.height);
				result.draw(src,m);
			}
			if (src && disposeSource)
				src.dispose()
			return result;
		}
	}
}