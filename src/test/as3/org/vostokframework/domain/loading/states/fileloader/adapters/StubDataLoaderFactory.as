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
package org.vostokframework.domain.loading.states.fileloader.adapters
{
	import org.vostokframework.domain.assets.AssetType;
	import org.vostokframework.domain.loading.settings.LoadingSettings;
	import org.vostokframework.domain.loading.states.fileloader.IDataLoader;
	import org.vostokframework.domain.loading.states.fileloader.adapters.StubDataLoaderAdapter;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class StubDataLoaderFactory extends DataLoaderFactory
	{
		
		private var _successBehaviorAsync:Boolean;
		
		public function set successBehaviorAsync(value:Boolean):void { _successBehaviorAsync = value; }
		
		public function StubDataLoaderFactory ()
		{
			
		}
		
		override public function create(type:AssetType, url:String, settings:LoadingSettings):IDataLoader
		{
			type = null;//just to avoid compiler warnings
			url = null;//just to avoid compiler warnings
			settings = null;//just to avoid compiler warnings
			
			var dataLoader:StubDataLoaderAdapter = new StubDataLoaderAdapter();
			dataLoader.successBehaviorAsync = _successBehaviorAsync;
			
			return dataLoader;
		}
		
	}

}