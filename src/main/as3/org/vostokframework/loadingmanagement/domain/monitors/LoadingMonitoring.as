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
	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class LoadingMonitoring
	{
		/**
		 * description
		 */
		private var _bufferBytesRemaining:int;
		private var _bufferBytesTotal:int;
		private var _bufferPercent:int;
		private var _bytesLoaded:int;
		private var _bytesRemaining:int;
		private var _bytesTotal:int;
		private var _elapsedTime:int;
		private var _latency:int;
		private var _percent:int;
		
		public function get averageSpeed(): int { return 0; }

		/**
		 * description
		 */
		public function get bufferBytesRemaining(): int { return _bufferBytesRemaining; }

		/**
		 * description
		 */
		public function get bufferPercent(): int { return _bufferPercent; }

		/**
		 * description
		 */
		public function get bytesLoaded(): int { return _bytesLoaded; }

		/**
		 * description
		 */
		public function get bytesRemaining(): int { return _bytesRemaining; }

		/**
		 * description
		 */
		public function get bytesTotal(): int { return _bytesTotal; }
		
		/**
		 * description
		 */
		public function get currentSpeed(): int { return 0; }

		/**
		 * description
		 */
		public function get elapsedTime(): int { return _elapsedTime; }

		/**
		 * description
		 */
		public function get latency(): int { return _latency; }
		
		/**
		 * description
		 */
		public function get percent(): int { return _percent; }

		/**
		 * description
		 */
		public function get remainingTime(): int { return 0; }
		//TODO:implement detailed statistics
		/**
		 * description
		 * 
		 * @param latency
		 * @param bytesTotal
		 * @param bufferPercent
		 */
		public function LoadingMonitoring(latency:int, bufferPercent:int = 100)
		{
			_latency = latency;
			_bufferPercent = bufferPercent;
		}

		/**
		 * description
		 */
		internal function reset(): void
		{
			
		}

		/**
		 * description
		 * 
		 * @param bytesLoaded
		 */
		internal function update(bytesTotal:int, bytesLoaded:int): void
		{
			_bytesTotal = bytesTotal;
			_bytesLoaded = bytesLoaded;
			
			var tempPercent:int = (_bytesTotal > 0) ? Math.floor((_bytesLoaded * 100) / _bytesTotal) : 0;
			if (tempPercent > _percent) _percent = tempPercent;
		}

	}

}