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
	import org.as3coreaddendum.system.ICloneable;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class LoadingCacheSettings implements ICloneable
	{
		/**
		 * description
		 */
		private var _allowInternalCache:Boolean;
		private var _killExternalCache:Boolean;

		public function get allowInternalCache(): Boolean { return _allowInternalCache; }
		
		public function set allowInternalCache(value:Boolean): void { _allowInternalCache = value; }
		
		/**
		 * description
		 */
		public function get killExternalCache(): Boolean { return _killExternalCache; }
		
		public function set killExternalCache(value:Boolean): void { _killExternalCache = value; }

		/**
		 * description
		 * 
		 * @param killExternalCache
		 * @param allowInternalCache
		 */
		public function LoadingCacheSettings()
		{
			
		}
		
		public function clone():*
		{
			var cache:LoadingCacheSettings = new LoadingCacheSettings();
			cache.allowInternalCache = allowInternalCache;
			cache.killExternalCache = killExternalCache;
			return cache;
		}

	}

}