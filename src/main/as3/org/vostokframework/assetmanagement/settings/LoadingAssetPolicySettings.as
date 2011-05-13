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
package org.vostokframework.assetmanagement.settings
{
	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class LoadingAssetPolicySettings
	{
		/**
		 * description
		 */
		private var _latencyTimeout:Number;
		private var _maxAttempts:int;

		/**
		 * description
		 */
		public function get latencyTimeout(): Number { return _latencyTimeout; }
		
		/**
		 * description
		 */
		public function get maxAttempts(): int { return _maxAttempts; }

		/**
		 * description
		 * 
		 * @param baseURL
		 * @param ignoreErrors
		 * @param maxAttempts
		 * @param latencyTimeout
		 */
		public function LoadingAssetPolicySettings(maxAttempts:int = 3, latencyTimeout:int = 10)
		{
			if (maxAttempts < 1) throw new ArgumentError("Argument <maxAttempts> must not be less than 1. Received: " + maxAttempts);
			
			_maxAttempts = maxAttempts;
			_latencyTimeout = latencyTimeout;
		}

	}

}