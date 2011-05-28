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

package org.vostokframework.loadingmanagement
{
	import org.as3collections.IList;
	import org.as3collections.lists.ArrayList;
	import org.flexunit.Assert;
	import org.vostokframework.assetmanagement.AssetLoadingPriority;
	import org.vostokframework.assetmanagement.settings.LoadingAssetPolicySettings;
	import org.vostokframework.assetmanagement.settings.LoadingAssetSettings;
	import org.vostokframework.loadingmanagement.assetloaders.AssetLoader;
	import org.vostokframework.loadingmanagement.assetloaders.AssetLoaderStatus;
	import org.vostokframework.loadingmanagement.assetloaders.VostokLoaderStub;
	import org.vostokframework.loadingmanagement.events.AssetLoaderEvent;
	import org.vostokframework.loadingmanagement.policies.StubAssetLoadingPolicy;

	/**
	 * @author Flávio Silva
	 */
	[TestCase(order=13)]
	public class AssetLoaderQueueManagerTests
	{
		
		private var _queueManager:AssetLoaderQueueManager;
		private var _policy:StubAssetLoadingPolicy;
		
		public function AssetLoaderQueueManagerTests()
		{
			
		}
		
		/////////////////////////
		// TESTS CONFIGURATION //
		/////////////////////////
		
		[Before]
		public function setUp(): void
		{
			var settings:LoadingAssetSettings = new LoadingAssetSettings(new LoadingAssetPolicySettings(3));
			var loaders:IList = new ArrayList();
			
			var loader1:AssetLoader = new AssetLoader("asset-loader-1", AssetLoadingPriority.HIGH, new VostokLoaderStub(), settings);
			var loader2:AssetLoader = new AssetLoader("asset-loader-2", AssetLoadingPriority.MEDIUM, new VostokLoaderStub(), settings);
			var loader3:AssetLoader = new AssetLoader("asset-loader-3", AssetLoadingPriority.MEDIUM, new VostokLoaderStub(), settings);
			var loader4:AssetLoader = new AssetLoader("asset-loader-4", AssetLoadingPriority.LOW, new VostokLoaderStub(), settings);
			
			//added without order purposely
			//to test if the queue will correctly sort it (by priority)
			loaders.add(loader3);
			loaders.add(loader2);
			loaders.add(loader1);
			loaders.add(loader4);
			
			_policy = new StubAssetLoadingPolicy();
			_policy.localMaxConnections = 6;
			_policy.globalMaxConnections = 6;
			_policy.totalGlobalConnections = 0;
			
			_queueManager = new AssetLoaderQueueManager(loaders, _policy);
		}
		
		[After]
		public function tearDown(): void
		{
			_queueManager = null;
			_policy = null;
		}
		
		///////////////////////
		// CONSTRUCTOR TESTS //
		///////////////////////
		
		/////////////////////////////////////////
		// AssetLoaderQueueManager().getNext() //
		/////////////////////////////////////////
		
		[Test]
		public function getNext_simpleCall_ReturnsValidObject(): void
		{
			var loader:AssetLoader = _queueManager.getNext();
			Assert.assertNotNull(loader);
		}
		
		[Test]
		public function getNext_simpleCall_checkPriorityOrder_ReturnsValidObject(): void
		{
			var loader:AssetLoader = _queueManager.getNext();
			Assert.assertEquals("asset-loader-1", loader.id);
		}
		
		[Test]
		public function getNext_doubleCall_checkPriorityOrder_ReturnsValidObject(): void
		{
			_queueManager.getNext();
			var loader:AssetLoader = _queueManager.getNext();
			Assert.assertEquals("asset-loader-2", loader.id);
		}
		
		[Test]
		public function getNext_exceedsLocalMaxConnections_ReturnsNull(): void
		{
			_policy.localMaxConnections = 3;
			_policy.globalMaxConnections = 4;
			_policy.totalGlobalConnections = 0;
			
			var loader:AssetLoader = _queueManager.getNext();
			loader.load();
			
			loader = _queueManager.getNext();
			loader.load();
			
			loader = _queueManager.getNext();
			loader.load();
			
			loader = _queueManager.getNext();
			Assert.assertNull(loader);
		}
		
		[Test]
		public function getNext_exceedsGlobalMaxConnections_ReturnsNull(): void
		{
			_policy.localMaxConnections = 3;
			_policy.globalMaxConnections = 4;
			_policy.totalGlobalConnections = 4;
			
			var loader:AssetLoader = _queueManager.getNext();
			Assert.assertNull(loader);
		}
		
		[Test]
		public function getNext_cancelAndCheckNext_AssetLoader(): void
		{
			var loader:AssetLoader = _queueManager.getAssetLoaders().getAt(0);
			loader.cancel();
			
			loader = _queueManager.getNext();
			Assert.assertEquals("asset-loader-2", loader.id);
		}
		
		[Test]
		public function getNext_stopAndCheckNext_AssetLoader(): void
		{
			var loader:AssetLoader = _queueManager.getAssetLoaders().getAt(0);
			loader.stop();
			
			loader = _queueManager.getNext();
			
			Assert.assertEquals("asset-loader-2", loader.id);
		}
		
		/////////////////////////////////////////////////
		// AssetLoaderQueueManager().activeConnections //
		/////////////////////////////////////////////////
		
		[Test]
		public function activeConnections_loadAndCheckTotal_Int(): void
		{
			var loader:AssetLoader = _queueManager.getNext();
			loader.load();
			loader = _queueManager.getNext();
			loader.load();
			
			Assert.assertEquals(2, _queueManager.activeConnections);
		}
		
		/////////////////////////////////////////////
		// AssetLoaderQueueManager().totalCanceled //
		/////////////////////////////////////////////
		
		[Test]
		public function totalCanceled_checkTotal_Int(): void
		{
			Assert.assertEquals(0, _queueManager.totalCanceled);
		}
		
		[Test]
		public function totalCanceled_cancelAndCheckTotal_Int(): void
		{
			var loader:AssetLoader = _queueManager.getNext();
			loader.cancel();
			
			Assert.assertEquals(1, _queueManager.totalCanceled);
		}
		
		/////////////////////////////////////////////
		// AssetLoaderQueueManager().totalComplete //
		/////////////////////////////////////////////
		
		[Test]
		public function totalComplete_checkTotal_Int(): void
		{
			Assert.assertEquals(0, _queueManager.totalComplete);
		}
		
		[Test]
		public function totalComplete_loadAndCheckTotal_Int(): void
		{
			var loader:AssetLoader = _queueManager.getNext();
			loader.load();
			loader.dispatchEvent(new AssetLoaderEvent(AssetLoaderEvent.STATUS_CHANGED, AssetLoaderStatus.COMPLETE));
			
			Assert.assertEquals(1, _queueManager.totalComplete);
		}
		
		////////////////////////////////////////////
		// AssetLoaderQueueManager().totalLoading //
		////////////////////////////////////////////
		
		[Test]
		public function totalLoading_checkTotal_Int(): void
		{
			Assert.assertEquals(0, _queueManager.totalLoading);
		}
		
		[Test]
		public function totalLoading_loadAndCheckTotal_Int(): void
		{
			var loader:AssetLoader = _queueManager.getNext();
			loader.load();
			
			loader = _queueManager.getNext();
			loader.load();
			
			Assert.assertEquals(2, _queueManager.totalLoading);
		}
		
		///////////////////////////////////////////
		// AssetLoaderQueueManager().totalQueued //
		///////////////////////////////////////////
		
		[Test]
		public function totalQueued_checkTotal_Int(): void
		{
			Assert.assertEquals(4, _queueManager.totalQueued);
		}
		
		[Test]
		public function totalQueued_getNextAndCheckTotal_Int(): void
		{
			_queueManager.getNext();
			Assert.assertEquals(3, _queueManager.totalQueued);
		}
		
		////////////////////////////////////////////
		// AssetLoaderQueueManager().totalStopped //
		////////////////////////////////////////////
		
		[Test]
		public function totalStopped_checkTotal_Int(): void
		{
			Assert.assertEquals(0, _queueManager.totalStopped);
		}
		
		[Test]
		public function totalStopped_stopAndCheckTotal_Int(): void
		{
			var loader:AssetLoader = _queueManager.getNext();
			loader.stop();
			
			Assert.assertEquals(1, _queueManager.totalStopped);
		}
		
	}

}