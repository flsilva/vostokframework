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
	import org.vostokframework.assetmanagement.domain.AssetType;
	import org.vostokframework.assetmanagement.domain.settings.AssetLoadingSettings;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class StubAssetLoaderFactory extends AssetLoaderFactory
	{
		
		private var _openBehaviorSync:Boolean;
		private var _successBehaviorAsync:Boolean;
		private var _successBehaviorSync:Boolean;
		
		public function set openBehaviorSync(value:Boolean):void { _openBehaviorSync = value; }
		
		public function set successBehaviorAsync(value:Boolean):void { _successBehaviorAsync = value; }
		
		public function set successBehaviorSync(value:Boolean):void { _successBehaviorSync = value; }
		
		public function StubAssetLoaderFactory()
		{
			
		}
		/*
		override public function create(asset:Asset):VostokLoader
		{
			return new StubVostokLoader(asset.identification.toString());
		}*/
		
		override protected function createLoaderAlgorithm(type:AssetType, url:String, settings:AssetLoadingSettings):LoadingAlgorithm
		{
			var stub:StubLoadingAlgorithm = new StubLoadingAlgorithm();
			stub.openBehaviorSync = _openBehaviorSync;
			stub.successBehaviorAsync = _successBehaviorAsync;
			stub.successBehaviorSync = _successBehaviorSync;
			
			return stub;
		}
		
	}

}