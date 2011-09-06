/*
 * Licensed under the MIT License
 * 
 * Copyright 2010 (c) Flávio Silva, http://flsilva.com
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

package org.vostokframework.application.services
{
	import org.vostokframework.domain.assets.settings.AssetLoadingSettings;
	import org.as3collections.IList;
	import org.as3collections.lists.ArrayList;
	import org.flexunit.Assert;
	import org.flexunit.async.Async;
	import org.vostokframework.application.LoadingContext;
	import org.vostokframework.domain.loading.loaders.StubVostokLoaderFactory;

	import flash.events.TimerEvent;
	import flash.utils.Timer;

	/**
	 * @author Flávio Silva
	 */
	[TestCase]
	public class LoadingServiceTestsContainsAssetData extends LoadingServiceTestsConfiguration
	{
		private static const QUEUE_ID:String = "queue-1";
		
		public function LoadingServiceTestsContainsAssetData()
		{
			
		}
		
		//////////////////////////////////////////
		// LoadingService().containsAssetData() //
		//////////////////////////////////////////
		
		[Test(expects="ArgumentError")]
		public function isLoaded_invalidLoaderIdArgument_ThrowsError(): void
		{
			service.containsAssetData(null);
		}
		
		[Test]
		public function containsAssetData_notExistingLoader_ReturnsFalse(): void
		{
			var contains:Boolean = service.containsAssetData(asset1.identification.id, asset1.identification.locale);
			Assert.assertFalse(contains);
		}
		
		[Test]
		public function containsAssetData_queuedLoader_ReturnsFalse(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			list.add(asset2);
			
			service.load(QUEUE_ID, list, null, 1);
			
			var contains:Boolean = service.containsAssetData(asset2.identification.id, asset2.identification.locale);
			Assert.assertFalse(contains);
		}
		
		[Test]
		public function containsAssetData_loadingLoader_ReturnsFalse(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE_ID, list);
			
			var contains:Boolean = service.containsAssetData(asset1.identification.id, asset1.identification.locale);
			Assert.assertFalse(contains);
		}
		
		[Test(async, timeout=1000)]
		public function containsAssetData_loadedAndCachedAsset_ReturnsTrue(): void
		{
			var stubVostokLoaderFactory:StubVostokLoaderFactory = new StubVostokLoaderFactory();
			stubVostokLoaderFactory.successBehaviorAsync = true;
			LoadingContext.getInstance().setLoaderFactory(stubVostokLoaderFactory);
			
			var settings:AssetLoadingSettings = LoadingContext.getInstance().assetLoadingSettingsRepository.find(asset1);
			settings.cache.allowInternalCache = true;
			
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE_ID, list);
			
			var timer:Timer = new Timer(400, 1);
			
			var listener:Function = Async.asyncHandler(this, 
				function():void
				{
					var contains:Boolean = service.containsAssetData(asset1.identification.id, asset1.identification.locale);
					Assert.assertTrue(contains);
				}
			, 1000);
			
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, listener, false, 0, true);
			timer.start();
		}
		
	}

}