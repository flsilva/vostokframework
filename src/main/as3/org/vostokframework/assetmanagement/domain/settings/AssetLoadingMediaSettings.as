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
package org.vostokframework.assetmanagement.domain.settings
{
	import org.as3collections.IList;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class AssetLoadingMediaSettings
	{
		/**
		 * description
		 */
		private var _audioLinkage:IList;
		private var _autoCreateVideo:Boolean;
		private var _autoResizeVideo:Boolean;
		private var _autoStopStream:Boolean;
		private var _bufferPercent:int;
		private var _bufferTime:Number;

		public function get audioLinkage(): IList { return _audioLinkage; }

		/**
		 * description
		 */
		public function get autoCreateVideo(): Boolean { return _autoCreateVideo; }

		/**
		 * description
		 */
		public function get autoResizeVideo(): Boolean { return _autoResizeVideo; }

		/**
		 * description
		 */
		public function get autoStopStream(): Boolean { return _autoStopStream; }

		/**
		 * description
		 */
		public function get bufferPercent(): int { return _bufferPercent; }

		/**
		 * description
		 */
		public function get bufferTime(): Number { return _bufferTime; }

		/**
		 * description
		 */
		public function AssetLoadingMediaSettings()
		{
			
		}

	}

}