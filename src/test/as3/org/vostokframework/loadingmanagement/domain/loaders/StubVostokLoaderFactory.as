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
	import org.vostokframework.loadingmanagement.domain.ILoaderState;
	import org.vostokframework.loadingmanagement.domain.states.fileloader.QueuedFileLoader;

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
		/*
		override public function create(asset:Asset):ILoader
		{
			return new StubILoader(asset.identification.toString());
		}*/
		
		override protected function createLeafLoaderState(type:AssetType, url:String, settings:AssetLoadingSettings, maxAttempts:int):ILoaderState
		{
			type = null;//just to avoid FDT warnings
			url = null;//just to avoid FDT warnings
			settings = null;//just to avoid FDT warnings
			
			var algorithm:StubFileLoadingAlgorithm = new StubFileLoadingAlgorithm();
			algorithm.openBehaviorSync = _openBehaviorSync;
			algorithm.successBehaviorAsync = _successBehaviorAsync;
			//algorithm.successBehaviorSync = _successBehaviorSync;
			
			return new QueuedFileLoader(algorithm, maxAttempts);
		}
		
	}

}