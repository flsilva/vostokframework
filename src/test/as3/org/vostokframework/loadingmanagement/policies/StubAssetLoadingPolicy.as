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
package org.vostokframework.loadingmanagement.policies
{
	import org.vostokframework.loadingmanagement.assetloaders.AssetLoaderRepository;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class StubAssetLoadingPolicy extends AssetLoadingPolicy
	{
		private var _globalMaxConnections:int;
		private var _localMaxConnections:int;
		public var totalGlobalConnections:int;
		
		override public function set globalMaxConnections(value:int):void { _globalMaxConnections = value; }
		
		override public function set localMaxConnections(value:int):void { _localMaxConnections = value; }
		
		public function StubAssetLoadingPolicy()
		{
			super(new AssetLoaderRepository());
		}
		
		override public function allow(localActiveConnections:int):Boolean
		{
			return localActiveConnections < _localMaxConnections && totalGlobalConnections < _globalMaxConnections;
		}

	}

}