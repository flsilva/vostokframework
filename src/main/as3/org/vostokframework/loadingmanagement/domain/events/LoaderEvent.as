/*
 * Licensed under the MIT License
 * 
 * Copyright 2011 (c) Flávio Silva, flsilva.com
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 * 
 * http://www.opensource.org/licenses/mit-license.php
 */
package org.vostokframework.loadingmanagement.domain.events
{
	import flash.events.Event;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class LoaderEvent extends Event
	{
		public static const CANCELED:String = "VostokFramework.LoaderEvent.CANCELED";
		public static const COMPLETE:String = "VostokFramework.LoaderEvent.COMPLETE";
		public static const CONNECTING:String = "VostokFramework.LoaderEvent.CONNECTING";
		public static const FAILED:String = "VostokFramework.LoaderEvent.FAILED";
		public static const INIT:String = "VostokFramework.LoaderEvent.INIT";
		public static const OPEN:String = "VostokFramework.LoaderEvent.OPEN";
		public static const STOPPED:String = "VostokFramework.LoaderEvent.STOPPED";
		
		/**
		 * @private
 		 */
		private var _data:*;
		
		public function get data():* { return _data; }
		
		/**
		 * description
		 * 
		 * @param type
		 * @param loadedAssetData
		 */
		public function LoaderEvent(type:String, data:* = null)
		{
			super(type, true);
			_data = data;
		}
		
		override public function clone():Event
		{
			return new LoaderEvent(type, _data);
		}
		
		public static function typeBelongs(type:String):Boolean
		{
			return type == CANCELED ||
			       type == COMPLETE ||
			       type == CONNECTING ||
			       type == FAILED ||
			       type == INIT ||
			       type == OPEN ||
			       type == STOPPED;
		}
		
	}

}