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
package org.vostokframework.loadingmanagement.domain
{
	import org.as3coreaddendum.errors.UnsupportedOperationError;
	import org.as3utils.ReflectionUtil;

	import flash.events.TimerEvent;
	import flash.utils.Timer;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class AsyncLoader extends PlainLoader
	{
		/**
		 * @private
		 */
		private var _delayFirstLoad:int;
		private var _delayLoadAfterError:int;
		private var _timerLoadDelay:Timer;
		
		/**
		 * description
		 */
		public function get delayLoadAfterError(): int { return _delayLoadAfterError; }
		public function set delayLoadAfterError(value:int): void
		{
			if (value < 50) throw new ArgumentError("Value must be greater than 50. Received: <" + value + ">");
			_delayLoadAfterError = value;
		}
		
		/**
		 * description
		 * 
		 * @param asset
		 * @param fileLoader
		 */
		public function AsyncLoader(delayFirstLoad:int = 50)
		{
			if (delayFirstLoad < 50) throw new ArgumentError("Argument <delayFirstLoad> must be greater than 50. Received: <" + delayFirstLoad + ">");
			
			_delayFirstLoad = delayFirstLoad;
			delayLoadAfterError = 5000;
			
			_timerLoadDelay = new Timer(delayFirstLoad);
			_timerLoadDelay.addEventListener(TimerEvent.TIMER, timerLoadDelayHandler, false, 0, true);
		}

		/**
		 * description
		 * 
		 * @return
 		 */
		override public function cancel(): void
		{
			_timerLoadDelay.stop();
			doCancel();
		}
		
		override public function dispose():void
		{
			_timerLoadDelay.removeEventListener(TimerEvent.TIMER, timerLoadDelayHandler, false);
			_timerLoadDelay.stop();

			_timerLoadDelay = null;
			
			super.dispose();
		}
		
		/**
		 * description
		 * 
		 * @return
 		 */
		override public function load(): void
		{
			_timerLoadDelay.start();
		}

		/**
		 * description
		 * 
		 * @return
 		 */
		override public function stop(): void
		{
			_timerLoadDelay.stop();
			doStop();
		}
		
		protected function doCancel():void
		{
			throw new UnsupportedOperationError("Method must be overridden in subclass: " + ReflectionUtil.getClassPath(this));
		}
		
		protected function doLoad():void
		{
			throw new UnsupportedOperationError("Method must be overridden in subclass: " + ReflectionUtil.getClassPath(this));
		}
		
		protected function doStop():void
		{
			throw new UnsupportedOperationError("Method must be overridden in subclass: " + ReflectionUtil.getClassPath(this));
		}
		
		protected function error():void
		{
			_timerLoadDelay.delay = _delayLoadAfterError;
		}

		private function timerLoadDelayHandler(event:TimerEvent):void
		{
			_timerLoadDelay.stop();
			_timerLoadDelay.reset();
			doLoad();
		}

	}

}