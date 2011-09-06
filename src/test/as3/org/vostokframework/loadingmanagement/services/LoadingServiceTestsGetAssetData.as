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

package org.vostokframework.loadingmanagement.services
{
	import org.as3collections.IList;
	import org.as3collections.lists.ArrayList;
	import org.flexunit.Assert;
	import org.flexunit.async.Async;
	import org.vostokframework.assetmanagement.domain.settings.AssetLoadingSettings;
	import org.vostokframework.loadingmanagement.LoadingManagementContext;
	import org.vostokframework.loadingmanagement.domain.loaders.StubVostokLoaderFactory;

	import flash.events.TimerEvent;
	import flash.utils.Timer;

	/**
	 * @author Flávio Silva
	 */
	[TestCase]
	public class LoadingServiceTestsGetAssetData extends LoadingServiceTestsConfiguration
	{
		private static const QUEUE_ID:String = "queue-1";
		
		public function LoadingServiceTestsGetAssetData()
		{
			
		}
		
		/////////////////////////////////////
		// LoadingService().getAssetData() //
		/////////////////////////////////////
		
		[Test(expects="ArgumentError")]
		public function getAssetData_invalidAssetIdArgument_ThrowsError(): void
		{
			service.getAssetData(null);
		}
		
		[Test(expects="org.vostokframework.loadingmanagement.report.errors.LoadedAssetDataNotFoundError")]
		public function getAssetData_notExistingAsset_ThrowsError(): void
		{
			service.getAssetData(asset1.identification.id);
		}
		
		[Test(expects="org.vostokframework.loadingmanagement.report.errors.LoadedAssetDataNotFoundError")]
		public function getAssetData_notLoadedAsset_ThrowsError(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			list.add(asset2);
			
			service.load(QUEUE_ID, list, null, 1);
			service.getAssetData(asset2.identification.id, asset2.identification.locale);
		}
		
		[Test(expects="org.vostokframework.loadingmanagement.report.errors.LoadedAssetDataNotFoundError")]
		public function getAssetData_loadingAsset_ThrowsError(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE_ID, list);
			service.getAssetData(asset1.identification.id, asset1.identification.locale);
		}
		
		[Test(async, timeout=1000)]
		public function getAssetData_loadedAndCachedAsset_ReturnsValidObject(): void
		{
			var stubVostokLoaderFactory:StubVostokLoaderFactory = new StubVostokLoaderFactory();
			stubVostokLoaderFactory.successBehaviorAsync = true;
			LoadingManagementContext.getInstance().setLoaderFactory(stubVostokLoaderFactory);
			
			var settings:AssetLoadingSettings = LoadingManagementContext.getInstance().assetLoadingSettingsRepository.find(asset1);
			settings.cache.allowInternalCache = true;
			
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE_ID, list);
			
			//var data:* = service.getAssetData(asset1.identification.id, asset1.identification.locale);
			//Assert.assertNotNull(data);
			
			var timer:Timer = new Timer(400, 1);
			
			var listener:Function = Async.asyncHandler(this, 
				function():void
				{
					var data:* = service.getAssetData(asset1.identification.id, asset1.identification.locale);
					Assert.assertNotNull(data);
				}
			, 1000);
			
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, listener, false, 0, true);
			timer.start();
		}
		
	}

}