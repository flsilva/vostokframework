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
package org.vostokframework.domain.loading.monitors
{
	import org.as3coreaddendum.system.IEquatable;
	import org.as3utils.StringUtil;

	/**
	 * @author Flavio
	 * @version 1.0
	 * @created 14-mai-2011 12:02:52
	 */
	public class EventListener implements IEquatable
	{
		private var _listener:Function;
		private var _type:String;
		private var _priority:int;
		private var _useCapture:Boolean;
		private var _useWeakReference:Boolean;
		
		public function get listener():Function { return _listener; }
		
		public function get type():String { return _type; }
		
		public function get priority():int { return _priority; }
		
		public function get useCapture():Boolean { return _useCapture; }
		
		public function get useWeakReference():Boolean { return _useWeakReference; }
		
		/**
		 * 
		 * @param assetId
		 * @param assetType
		 * @param loader
		 */
		public function EventListener(type: String, listener: Function, useCapture: Boolean = false, priority: int = 0, useWeakReference: Boolean = false)
		{
			if (StringUtil.isBlank(type)) throw new ArgumentError("Argument <type> must not be null nor an empty String.");
			if (listener == null) throw new ArgumentError("Argument <listener> must not be null.");
			
			_listener = listener;
			_type = type;
			_priority = priority;
			_useCapture = useCapture;
			_useWeakReference = useWeakReference;
		}
		
		public function equals(other : *): Boolean
		{
			if (this == other) return true;
			if (!(other is EventListener)) return false;
			
			var otherEnvetListener:EventListener = other as EventListener;
			
			return type == otherEnvetListener.type
				&& listener == otherEnvetListener.listener
				&& useCapture == otherEnvetListener.useCapture;
				//&& priority == otherEnvetListener.priority
				//&& useWeakReference == otherEnvetListener.useWeakReference;
		}
		
	}

}