/*
 * Licensed under the MIT License
 * 
 * Copyright 2010 (c) Flávio Silva, http://flsilva.com
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
	import mockolate.mock;
	import mockolate.stub;
	import mockolate.verify;

	import org.vostokframework.loadingmanagement.domain.VostokLoader;

	import flash.events.Event;

	/**
	 * @author Flávio Silva
	 */
	[TestCase]
	public class CompositeLoadingMonitorTests extends LoadingMonitorTests
	{
		
		
		public function CompositeLoadingMonitorTests()
		{
			
		}
		
		
		////////////////////
		// HELPER METHODS //
		////////////////////
		
		override protected function getMonitor(loader:VostokLoader, dispatcher:LoadingMonitorDispatcher):ILoadingMonitor
		{
			return new CompositeLoadingMonitor(loader, dispatcher);
		}
		
		///////////////////////////////////////////////
		// LoadingMonitor().addEventListener() TESTS //
		///////////////////////////////////////////////
		
		private function helperListener(event:Event):void
		{
			
		}
		
		[Test]
		public function addEventListener_loadingDispatcherReturnsFalseForTypeBelongs_shouldForwardsCallToChildMonitor(): void
		{
			stub(mockDispatcher).method("typeBelongs").anyArgs().returns(false);
			
			var eventType:String = "EVENT_NAME";
			var eventListener:Function = helperListener;
			var useCapture:Boolean = false;
			var priority:int = 0;
			var weakReference:Boolean = true;
			
			var mockChild:ILoadingMonitor = getFakeMonitor();
			mock(mockChild).method("addEventListener").args(eventType, eventListener, useCapture, priority, weakReference);
			
			monitor.addMonitor(mockChild);
			monitor.addEventListener(eventType, eventListener, useCapture, priority, weakReference);
			
			verify(mockChild);
		}
	}

}