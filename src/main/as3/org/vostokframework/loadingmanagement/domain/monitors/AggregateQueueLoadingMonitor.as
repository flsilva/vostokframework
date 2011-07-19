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
	import org.as3collections.IList;
	import org.vostokframework.loadingmanagement.domain.StatefulLoader;
	import org.vostokframework.loadingmanagement.domain.events.AggregateQueueLoadingEvent;

	import flash.events.Event;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class AggregateQueueLoadingMonitor extends QueueLoadingMonitor
	{
		
		/**
		 * description
		 * 
		 * @param requestId
		 * @param loaders
		 */
		public function AggregateQueueLoadingMonitor(loader:StatefulLoader, monitors:IList = null): void
		{
			super(loader, monitors);
		}
		
		override protected function createEvent(type:String):Event
		{
			return new AggregateQueueLoadingEvent(type, loader.id, monitoring);
		}
		
		override protected function dispatchCanceledEvent():void
		{
			dispatchEvent(createEvent(AggregateQueueLoadingEvent.CANCELED));
		}
		
		override protected function dispatchCompleteEvent():void
		{
			dispatchEvent(createEvent(AggregateQueueLoadingEvent.COMPLETE));
		}
		
		override protected function dispatchOpenEvent():void
		{
			dispatchEvent(createEvent(AggregateQueueLoadingEvent.OPEN));
		}
		
		override protected function dispatchProgressEvent():void
		{
			dispatchEvent(createEvent(AggregateQueueLoadingEvent.PROGRESS));
		}
		
		override protected function dispatchStoppedEvent():void
		{
			dispatchEvent(createEvent(AggregateQueueLoadingEvent.STOPPED));
		}
		
		override protected function typeBelongs(type:String):Boolean
		{
			return AggregateQueueLoadingEvent.typeBelongs(type);
		}
		
	}

}