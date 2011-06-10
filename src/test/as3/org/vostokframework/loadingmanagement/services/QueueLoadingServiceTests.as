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
	import mockolate.runner.MockolateRule;

	import org.as3collections.IList;
	import org.as3collections.lists.ArrayList;
	import org.flexunit.Assert;
	import org.vostokframework.assetmanagement.domain.Asset;
	import org.vostokframework.assetmanagement.domain.AssetManagementContext;
	import org.vostokframework.assetmanagement.domain.AssetPackage;
	import org.vostokframework.loadingmanagement.domain.LoaderRepository;
	import org.vostokframework.loadingmanagement.domain.LoadingManagementContext;
	import org.vostokframework.loadingmanagement.domain.RefinedLoader;
	import org.vostokframework.loadingmanagement.domain.monitors.ILoadingMonitor;

	/**
	 * @author Flávio Silva
	 */
	[TestCase(order=999)]
	public class QueueLoadingServiceTests
	{
		private static const QUEUE_ID:String = "queue-1";
		private static const ASSET_PACKAGE_ID:String = "asset-package-1";
		private static const ASSET_ID:String = "asset-1";
		
		[Rule]
		public var mocks:MockolateRule = new MockolateRule();
		
		[Mock(inject="false")]
		public var _fakeAsset:Asset;
		
		public var _service:QueueLoadingService;
		
		public function QueueLoadingServiceTests()
		{
			
		}
		
		/////////////////////////
		// TESTS CONFIGURATION //
		/////////////////////////
		
		[Before]
		public function setUp(): void
		{
			LoadingManagementContext.getInstance().setLoaderRepository(new LoaderRepository());
			
			_service = new QueueLoadingService();
		}
		
		[After]
		public function tearDown(): void
		{
			_service = null;
		}
		
		////////////////////
		// HELPER METHODS //
		////////////////////
		
		public function getLoader():RefinedLoader
		{
			return null;
		}
		
		//////////////////////////////////
		// QueueLoadingService().load() //
		//////////////////////////////////
		
		[Test]
		public function load_validArguments_ReturnsILoadingMonitor(): void
		{
			var assetPackage:AssetPackage = AssetManagementContext.getInstance().assetPackageFactory.create(ASSET_PACKAGE_ID);
			var asset:Asset = AssetManagementContext.getInstance().assetFactory.create("asset/image-01.jpg", assetPackage);
			//_fakeAsset = nice(Asset, null, [ASSET_ID, "asset/image-01.jpg", AssetType.IMAGE, LoadPriority.MEDIUM]);
			
			var list:IList = new ArrayList();
			list.add(asset);
			
			var monitor:ILoadingMonitor = _service.load(QUEUE_ID, list);
			Assert.assertNotNull(monitor);
		}
		
		[Test(expects="org.vostokframework.loadingmanagement.domain.errors.DuplicateLoaderError")]
		public function load_tryTwiceWithSameQueueId_ThrowsError(): void
		{
			var assetPackage:AssetPackage = AssetManagementContext.getInstance().assetPackageFactory.create(ASSET_PACKAGE_ID);
			var asset:Asset = AssetManagementContext.getInstance().assetFactory.create("asset/image-01.jpg", assetPackage);
			//_fakeAsset = nice(Asset, null, [ASSET_ID, "asset/image-01.jpg", AssetType.IMAGE, LoadPriority.MEDIUM]);
			
			var list:IList = new ArrayList();
			list.add(asset);
			
			var monitor:ILoadingMonitor = _service.load(QUEUE_ID, list);
			monitor = _service.load(QUEUE_ID, list);
		}
		
	}

}