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
package org.vostokframework.domain.loading.settings
{
	import org.vostokframework.domain.loading.LoadPriority;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class AssetLoadingPolicySettings
	{
		/**
		 * description
		 */
		private var _latencyTimeout:Number;
		private var _maxAttempts:int;
		private var _priority:LoadPriority;

		/**
		 * description
		 */
		public function get latencyTimeout(): Number { return _latencyTimeout; }
		
		public function set latencyTimeout(value:Number): void { _latencyTimeout = value; }
		
		/**
		 * description
		 */
		public function get maxAttempts(): int { return _maxAttempts; }
		
		public function set maxAttempts(value:int): void { _maxAttempts = value; }
		
		/**
		 * description
		 */
		public function get priority(): LoadPriority { return _priority; }
		
		public function set priority(value:LoadPriority): void { _priority = value; }

		/**
		 * description
		 * 
		 * @param baseURL
		 * @param ignoreErrors
		 * @param maxAttempts
		 * @param latencyTimeout
		 */
		public function AssetLoadingPolicySettings()
		{
			
		}

	}

}