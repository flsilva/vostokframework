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
	import org.as3collections.IList;
	import org.vostokframework.loadingmanagement.LoadingRequestPriority;
	import org.vostokframework.loadingmanagement.RequestLoader;
	import org.vostokframework.loadingmanagement.assetloaders.AssetLoaderRepository;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class StubRequestLoadingPolicy extends RequestLoadingPolicy
	{
		public var containsOnlyLowest:Boolean;
		public var globalMaxConnections:int;
		public var localMaxConnections:int;
		public var totalGlobalConnections:int;
		
		public function StubRequestLoadingPolicy()
		{
			localMaxConnections = 1;
			globalMaxConnections = 1;
			super(localMaxConnections, globalMaxConnections, new AssetLoaderRepository());
		}
		
		override public function allow(localActiveConnections:int, activeLoadings:IList, allowLoader:RequestLoader):Boolean
		{
			if (LoadingRequestPriority.getByOrdinal(allowLoader.priority).equals(LoadingRequestPriority.LOWEST) &&
				!containsOnlyLowest) return false;
			
			return localActiveConnections < localMaxConnections && totalGlobalConnections < globalMaxConnections;
		}

	}

}