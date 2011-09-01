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
package org.vostokframework.loadingmanagement.domain.states.fileloader.algorithms
{
	import org.vostokframework.loadingmanagement.domain.LoadError;
	import org.vostokframework.loadingmanagement.domain.states.fileloader.FileLoadingAlgorithmErrorEvent;
	import org.vostokframework.loadingmanagement.domain.states.fileloader.IFileLoadingAlgorithm;

	import flash.events.TimerEvent;
	import flash.utils.Timer;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class DelayableFileLoadingAlgorithm extends FileLoadingAlgorithmBehavior
	{
		/**
		 * @private
 		 */
		private var _delayAfterError:Number;
		private var _currentDelay:Number;
		private var _initialDelay:Number;
		private var _timer:Timer;
		
		/**
		 * description
		 * 
		 * @param loader
		 * @param request
		 * @param context
		 */
		public function DelayableFileLoadingAlgorithm(wrapAlgorithm:IFileLoadingAlgorithm, initialDelay:Number = 10, delayAfterError:Number = 5000)
		{
			super(wrapAlgorithm);
			
			if (initialDelay < 0) throw new ArgumentError("Argument <initialDelay> must not be a negative number. Received: <" + initialDelay + ">");
			if (delayAfterError < 0) throw new ArgumentError("Argument <delayAfterError> must not be a negative number. Received: <" + delayAfterError + ">");
			
			_initialDelay = initialDelay;
			_delayAfterError = delayAfterError;
			_currentDelay = _initialDelay;
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
			wrappedAlgorithm.addEventListener(FileLoadingAlgorithmErrorEvent.FAILED, failedHandler, false, 0, true);
		}
		
		private function createTimer():void
		{
			_timer = new Timer(_initialDelay);
		}
		
		private function failedHandler(event:FileLoadingAlgorithmErrorEvent):void
		{
			validateDisposal();
			stopTimer();
			
			_currentDelay = _delayAfterError;
			
			if (event.errors && !event.errors.isEmpty())
			{
				var lastError:LoadError = event.errors.getKeyAt(event.errors.size() - 1);
				
				if (lastError.equals(LoadError.LATENCY_TIMEOUT_ERROR))
				{
					_currentDelay = _initialDelay;
				}
			}
		}
		
		private function startTimer():void
		{
			_timer.addEventListener(TimerEvent.TIMER, timerHandler, false, 0, true);
			_timer.delay = _currentDelay;
			_timer.start();
		}
		
		private function stopTimer():void
		{
			_timer.stop();
			_timer.reset();
			_timer.removeEventListener(TimerEvent.TIMER, timerHandler, false);
		}
		
		private function timerHandler(event:TimerEvent):void
		{
			stopTimer();
			super.load();
		}
		
		private function removeWrappedAlgorithmListeners():void
		{
			wrappedAlgorithm.removeEventListener(FileLoadingAlgorithmErrorEvent.FAILED, failedHandler, false);
		}
		
	}

}