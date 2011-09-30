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
	import org.vostokframework.domain.loading.states.fileloader.IDataLoader;
	import org.vostokframework.domain.loading.states.fileloader.algorithms.events.FileLoadingAlgorithmMediaEvent;

	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.net.NetStream;
	import flash.utils.Timer;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class ProgressNetStream extends DataLoaderBehavior
	{
		/**
		 * @private
 		 */
		private var _bufferCompleteEventDispatched:Boolean;
		private var _completeEventDispatched:Boolean;
		private var _netStream:NetStream;
		private var _openEventDispatched:Boolean;
		private var _percentToBuffer:int;
		private var _timerProgress:Timer;
		
		/**
		 * description
		 * 
		 * @param loader
		 * @param request
		 * @param context
		 */
		public function ProgressNetStream(wrappedDataLoader:IDataLoader, netStream:NetStream, percentToBuffer:int = 0)
		{
			super(wrappedDataLoader);
			
			if (!netStream) throw new ArgumentError("Argument <netStream> must not be null.");
			
			_netStream = netStream;
			_percentToBuffer = percentToBuffer;
			
			_timerProgress = new Timer(50);
		}
		
		override public function cancel(): void
		{
			stopTimer();
			super.cancel();
		}
		
		/**
		 * description
		 */
		override public function load(): void
		{
			super.load();
			startTimer();
		}
		
		/**
		 * description
		 */
		override public function stop():void
		{
			stopTimer();
			_completeEventDispatched = false;
			_bufferCompleteEventDispatched = false;
			_openEventDispatched = false;
			
			super.stop();
		}
		
		override protected function doDispose():void
		{
			stopTimer();
			
			_netStream = null;
			_timerProgress = null;
		}
		
		private function dispatchProgressEvent():void
		{
			_netStream.dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false, false, _netStream.bytesLoaded, _netStream.bytesTotal));
		}
		
		private function loadingBufferComplete():void
		{
			_bufferCompleteEventDispatched = true;
			dispatchProgressEvent();
			_netStream.dispatchEvent(new FileLoadingAlgorithmMediaEvent(FileLoadingAlgorithmMediaEvent.BUFFER_COMPLETE));
		}
		
		private function loadingComplete():void
		{
			stopTimer();
			_completeEventDispatched = true;
			
			//enforces ProgressEvent.PROGRESS with bytesLoaded == bytesTotal
			_netStream.dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false, false, _netStream.bytesTotal, _netStream.bytesTotal));
			_netStream.dispatchEvent(new Event(Event.COMPLETE));
		}
		
		private function loadingOpen():void
		{
			_openEventDispatched = true;
			_netStream.dispatchEvent(new Event(Event.OPEN));
		}
		
		private function progressHandler(event:TimerEvent):void
		{
			var bufferBytesTotal:int = (_netStream.bytesTotal * _percentToBuffer) / 100;
			var currentBufferPercent:int = (_netStream.bytesTotal > 0) ? Math.floor((_netStream.bytesLoaded * 100) / bufferBytesTotal) : 0;
			
			if (_netStream.bytesLoaded > 0 && !_openEventDispatched)
			{
				loadingOpen();
			}
			else if (_percentToBuffer > 0 && currentBufferPercent >= _percentToBuffer && !_bufferCompleteEventDispatched)
			{
				loadingBufferComplete();
			}
			else if (_netStream.bytesLoaded == _netStream.bytesTotal && _netStream.bytesLoaded > 0 && !_completeEventDispatched)
			{
				loadingComplete();
			}
			else
			{
				dispatchProgressEvent();
			}
		}
		
		private function startTimer():void
		{
			_timerProgress.addEventListener(TimerEvent.TIMER, progressHandler, false, 0, true);
			_timerProgress.start();
		}
		
		private function stopTimer():void
		{
			_timerProgress.stop();
			_timerProgress.reset();
			_timerProgress.removeEventListener(TimerEvent.TIMER, progressHandler, false);
		}
		
	}

}