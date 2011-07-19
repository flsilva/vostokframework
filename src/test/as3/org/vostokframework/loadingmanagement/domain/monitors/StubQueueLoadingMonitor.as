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
package org.vostokframework.loadingmanagement.domain.monitors
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.setTimeout;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class StubQueueLoadingMonitor extends EventDispatcher implements ILoadingMonitor
	{
		private var _id:String;
		private var _monitoring:LoadingMonitoring;
		
		public function get id():String { return _id; }
		
		public function get monitoring():LoadingMonitoring { return _monitoring; }
		
		public function StubQueueLoadingMonitor(id:String)
		{
			_id = id;
			_monitoring = new LoadingMonitoring(1);
		}
		
		public function asyncDispatchEvent(event:Event, delay:int = 50):int
		{
			return setTimeout(dispatchEvent, delay, event);
		}
		
		public function dispose():void
		{
			
		}
		
		public function equals(other : *): Boolean
		{
			if (this == other) return true;
			if (!(other is ILoadingMonitor)) return false;
			
			var otherMonitor:ILoadingMonitor = other as ILoadingMonitor;
			return id == otherMonitor.id;
		}

	}

}