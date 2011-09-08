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
package org.vostokframework.domain.loading.loaders
{
	import org.vostokframework.domain.assets.AssetType;
	import org.vostokframework.domain.loading.settings.LoadingSettings;
	import org.vostokframework.domain.loading.states.fileloader.IDataLoader;
	import org.vostokframework.domain.loading.states.fileloader.StubNativeDataLoader;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class StubVostokLoaderFactory extends VostokLoaderFactory
	{
		
		private var _openBehaviorSync:Boolean;
		private var _successBehaviorAsync:Boolean;
		//private var _successBehaviorSync:Boolean;
		
		public function set openBehaviorSync(value:Boolean):void { _openBehaviorSync = value; }
		
		public function set successBehaviorAsync(value:Boolean):void { _successBehaviorAsync = value; }
		
		//public function set successBehaviorSync(value:Boolean):void { _successBehaviorSync = value; }
		
		public function StubVostokLoaderFactory ()
		{
			
		}
		
		override protected function createNativeDataLoader(type:AssetType, url:String, settings:LoadingSettings):IDataLoader
		{
			type = null;//just to avoid compiler warnings
			url = null;//just to avoid compiler warnings
			settings = null;//just to avoid compiler warnings
			
			var dataLoader:StubNativeDataLoader = new StubNativeDataLoader();
			//dataLoader.openBehaviorSync = _openBehaviorSync;
			dataLoader.successBehaviorAsync = _successBehaviorAsync;
			//dataLoader.successBehaviorSync = _successBehaviorSync;
			return dataLoader;
		}
		
	}

}