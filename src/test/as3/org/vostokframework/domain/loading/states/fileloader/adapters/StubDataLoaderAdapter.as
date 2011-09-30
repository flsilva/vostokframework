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
package org.vostokframework.domain.loading.states.fileloader.adapters
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.ProgressEvent;
	import flash.utils.setTimeout;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class StubDataLoaderAdapter extends DataLoaderAdapter
	{
		
		private var _dispatcher:IEventDispatcher;
		private var _openBehaviorSync:Boolean;
		private var _openBehaviorAsync:Boolean;
		private var _successBehaviorAsync:Boolean;
		private var _successBehaviorSync:Boolean;
		
		//public function set openBehaviorSync(value:Boolean):void { _openBehaviorSync = value; }
		
		public function set openBehaviorAsync(value:Boolean):void { _openBehaviorAsync = value; }
		
		public function set successBehaviorAsync(value:Boolean):void { _successBehaviorAsync = value; }
		
		public function set successBehaviorSync(value:Boolean):void { _successBehaviorSync = value; }
		
		/**
		 * description
		 * 
		 */
		public function StubDataLoaderAdapter()
		{
			_dispatcher = new EventDispatcher();
		}
		
		override protected function doCancel(): void
		{
			
		}
		
		override protected function doDispose(): void
		{
			
		}
		
		override protected function doGetData():*
		{
			return new MovieClip();
		}
		
		override protected function getLoadingDispatcher():IEventDispatcher
		{
			return _dispatcher;
		}
		
		override protected function doLoad(): void
		{
			if (_openBehaviorSync)
			{
				dispatchEvent(new Event(Event.OPEN));
			}
			else if (_openBehaviorAsync)
			{
				setTimeout(_dispatcher.dispatchEvent, 25, new Event(Event.OPEN));
			}
			else if (_successBehaviorAsync)
			{
				setTimeout(_dispatcher.dispatchEvent, 25, new Event(Event.OPEN));
				setTimeout(_dispatcher.dispatchEvent, 80, new ProgressEvent(ProgressEvent.PROGRESS, false, false, 500, 750));
				setTimeout(_dispatcher.dispatchEvent, 100, new ProgressEvent(ProgressEvent.PROGRESS, false, false, 750, 750));
				setTimeout(_dispatcher.dispatchEvent, 150, new Event(Event.COMPLETE));
			}
			else if (_successBehaviorSync)
			{
				_dispatcher.dispatchEvent(new Event(Event.OPEN));
				_dispatcher.dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false, false, 500, 750));
				_dispatcher.dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false, false, 750, 750));
				_dispatcher.dispatchEvent(new Event(Event.COMPLETE));
			}
		}
		
		override protected function doStop(): void
		{
			
		}

	}

}