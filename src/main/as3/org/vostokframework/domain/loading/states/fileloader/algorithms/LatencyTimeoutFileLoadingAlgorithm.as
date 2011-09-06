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
package org.vostokframework.domain.loading.states.fileloader.algorithms
{
	import org.as3collections.IListMap;
	import org.as3collections.maps.ArrayListMap;
	import org.vostokframework.domain.loading.LoadError;
	import org.vostokframework.domain.loading.states.fileloader.FileLoadingAlgorithmErrorEvent;
	import org.vostokframework.domain.loading.states.fileloader.FileLoadingAlgorithmEvent;
	import org.vostokframework.domain.loading.states.fileloader.IFileLoadingAlgorithm;

	import flash.events.TimerEvent;
	import flash.utils.Timer;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class LatencyTimeoutFileLoadingAlgorithm extends FileLoadingAlgorithmBehavior
	{
		/**
		 * @private
 		 */
		private static const LATENCY_TIMEOUT_ERROR_MESSAGE:String = "Internal VostokFramework Latency Timeout Error: Timeout of $LATENCY_TIMEOUT milliseconds.";
		
		private var _latencyTimeout:Number;
		private var _timer:Timer;
		
		/**
		 * description
		 * 
		 * @param loader
		 * @param request
		 * @param context
		 */
		public function LatencyTimeoutFileLoadingAlgorithm(wrapAlgorithm:IFileLoadingAlgorithm, latencyTimeout:Number = 12000)
		{
			super(wrapAlgorithm);
			
			if (latencyTimeout < 1000) throw new ArgumentError("Argument <latencyTimeout> must be greater than 999. Received: <" + latencyTimeout + ">");
			
			_latencyTimeout = latencyTimeout;
			createTimer();
			addWrappedAlgorithmListeners();
		}
		
		/**
		 * description
		 * 
		 * @return
 		 */
		override public function cancel(): void
		{
			validateDisposal();
			stopTimer();
			super.cancel();
		}
		
		/**
		 * description
		 * 
		 * @return
 		 */
		override public function load(): void
		{
			validateDisposal();
			startTimer();
			super.load();
		}
		
		/**
		 * description
		 * 
		 * @return
 		 */
		override public function stop(): void
		{
			validateDisposal();
			stopTimer();
			super.stop();
		}
		
		override protected function doDispose():void
		{
			removeWrappedAlgorithmListeners();
			stopTimer();
			
			_timer = null;
		}
		
		private function addWrappedAlgorithmListeners():void
		{
			wrappedAlgorithm.addEventListener(FileLoadingAlgorithmEvent.OPEN, openHandler, false, 0, true);
			wrappedAlgorithm.addEventListener(FileLoadingAlgorithmErrorEvent.FAILED, failedHandler, false, 0, true);
		}
		
		private function createErrorMessage():String
		{
			return LATENCY_TIMEOUT_ERROR_MESSAGE.replace("$LATENCY_TIMEOUT", _latencyTimeout);
		}
		
		private function createTimer():void
		{
			_timer = new Timer(_latencyTimeout);
		}
		
		private function failedHandler(event:FileLoadingAlgorithmErrorEvent):void
		{
			validateDisposal();
			stopTimer();
		}
		
		private function openHandler(event:FileLoadingAlgorithmEvent):void
		{
			validateDisposal();
			stopTimer();
		}
		
		private function startTimer():void
		{
			_timer.addEventListener(TimerEvent.TIMER, timerHandler, false, 0, true);
			_timer.start();
		}
		
		private function stopTimer():void
		{
			_timer.stop();
			_timer.reset();
			_timer.removeEventListener(TimerEvent.TIMER, timerHandler, false);
		}
		
		private function timeout():void
		{
			validateDisposal();
			removeWrappedAlgorithmListeners();
			stop();
			
			var errors:IListMap = new ArrayListMap();
			errors.put(LoadError.LATENCY_TIMEOUT_ERROR, createErrorMessage());
			
			dispatchEvent(new FileLoadingAlgorithmErrorEvent(FileLoadingAlgorithmErrorEvent.FAILED, errors));
		}
		
		private function timerHandler(event:TimerEvent):void
		{
			stopTimer();
			timeout();
		}
		
		private function removeWrappedAlgorithmListeners():void
		{
			wrappedAlgorithm.removeEventListener(FileLoadingAlgorithmEvent.OPEN, openHandler, false);
			wrappedAlgorithm.removeEventListener(FileLoadingAlgorithmErrorEvent.FAILED, failedHandler, false);
		}
		
	}

}