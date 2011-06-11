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
package org.vostokframework.loadingmanagement.domain.loaders
{
	import org.vostokframework.assetmanagement.domain.Asset;
	import org.vostokframework.assetmanagement.domain.AssetType;
	import org.vostokframework.loadingmanagement.domain.PlainLoader;

	import flash.display.Loader;
	import flash.net.URLRequest;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class AssetLoaderFactory
	{
		

		/**
		 * description
		 * 
		 * @param asset
		 * @param fileLoader
		 */
		public function AssetLoaderFactory()
		{
			
		}
		
		public function create(asset:Asset):AssetLoader
		{
			var fileLoader:PlainLoader = getFileLoader(asset.type, asset.src);
			var assetLoader:AssetLoader = new AssetLoader(asset.identification.toString(), asset.priority, fileLoader, asset.settings.policy.maxAttempts);
			return assetLoader;
		}
		
		protected function getFileLoader(type:AssetType, url:String):PlainLoader
		{
			if (type.equals(AssetType.IMAGE))
			{
				var loader:Loader = new Loader();
				var request:URLRequest = new URLRequest(url);
				
				return new VostokLoader(loader, request);
			}
			
			return null;
		}
		
	}

}