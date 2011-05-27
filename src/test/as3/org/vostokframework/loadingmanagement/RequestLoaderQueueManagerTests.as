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
	import org.vostokframework.loadingmanagement.assetloaders.VostokLoaderStub;
	import org.vostokframework.loadingmanagement.events.RequestLoaderEvent;

	/**
	 * @author Flávio Silva
	 */
	[TestCase(order=13)]
	public class RequestLoaderQueueManagerTests
	{
		
		private var _queueManager:RequestLoaderQueueManager;
		
		public function RequestLoaderQueueManagerTests()
		{
			
		}
		
		/////////////////////////
		// TESTS CONFIGURATION //
		/////////////////////////
		
		[Before]
		public function setUp(): void
		{
			var assetLoaders1:IList = new ArrayList();
			var assetLoaders2:IList = new ArrayList();
			
			assetLoaders1.add(getAssetLoader("asset-loader-1"));
			assetLoaders1.add(getAssetLoader("asset-loader-2"));
			assetLoaders1.add(getAssetLoader("asset-loader-3"));
			assetLoaders1.add(getAssetLoader("asset-loader-4"));
			
			var queueManager1:AssetLoaderQueueManager = new AssetLoaderQueueManager(assetLoaders1, 3);
			var requestLoader1:RequestLoader = new RequestLoader("request-loader-1", queueManager1, LoadingRequestPriority.HIGH);
			
			assetLoaders2.add(getAssetLoader("asset-loader-1"));
			assetLoaders2.add(getAssetLoader("asset-loader-2"));
			assetLoaders2.add(getAssetLoader("asset-loader-3"));
			
			var queueManager2:AssetLoaderQueueManager = new AssetLoaderQueueManager(assetLoaders2, 3);
			var requestLoader2:RequestLoader = new RequestLoader("request-loader-2", queueManager2, LoadingRequestPriority.MEDIUM);
			
			_queueManager = new RequestLoaderQueueManager();
			
			//added without order purposely
			// to test if the queue will correctly sort it (by priority)
			_queueManager.addLoader(requestLoader2);
			_queueManager.addLoader(requestLoader1);
		}
		
		[After]
		public function tearDown(): void
		{
			_queueManager = null;
		}
		
		////////////////////
		// HELPER METHODS //
		////////////////////
		
		private function getAssetLoader(id:String):AssetLoader
		{
			var settings:LoadingAssetSettings = new LoadingAssetSettings(new LoadingAssetPolicySettings(3));
			return new AssetLoader(id, AssetLoadingPriority.MEDIUM, new VostokLoaderStub(), settings);
		}
		
		///////////////////////
		// CONSTRUCTOR TESTS //
		///////////////////////
		
		/////////////////////////////////////////////
		// RequestLoaderQueueManager().addLoader() //
		/////////////////////////////////////////////
		
		//TODO:test dupplication element
		
		///////////////////////////////////////////
		// RequestLoaderQueueManager().getNext() //
		///////////////////////////////////////////
		
		[Test]
		public function getNext_simpleCall_ReturnsValidObject(): void
		{
			var loader:RequestLoader = _queueManager.getNext();
			Assert.assertNotNull(loader);
		}
		
		[Test]
		public function getNext_checkPriorityOrder_ReturnsValidObject(): void
		{
			var loader:RequestLoader = _queueManager.getNext();
			Assert.assertEquals("request-loader-1", loader.id);
		}
		
		[Test]
		public function getNext_checkPriorityOrder2_ReturnsValidObject(): void
		{
			_queueManager.getNext();
			
			var loader:RequestLoader = _queueManager.getNext();
			Assert.assertEquals("request-loader-2", loader.id);
		}
		
		[Test]
		public function getNext_exceedsConcurrentConnections_ReturnsNull(): void
		{
			var loader:RequestLoader = _queueManager.getNext();
			loader.load();
			
			loader = _queueManager.getNext();
			loader.load();
			
			loader = _queueManager.getNext();
			Assert.assertNull(loader);
		}
		
		[Test]
		public function getNext_cancelAndCheckNext_AssetLoader(): void
		{
			var loader:RequestLoader = _queueManager.getRequestLoaders().getAt(0);
			loader.cancel();
			
			loader = _queueManager.getNext();
			Assert.assertEquals("request-loader-2", loader.id);
		}
		
		[Test]
		public function getNext_stopAndCheckNext_AssetLoader(): void
		{
			var loader:RequestLoader = _queueManager.getRequestLoaders().getAt(0);
			loader.stop();
			
			loader = _queueManager.getNext();
			Assert.assertEquals("request-loader-2", loader.id);
		}
		
		///////////////////////////////////////////////////
		// RequestLoaderQueueManager().activeConnections //
		///////////////////////////////////////////////////
		
		[Test]
		public function activeConnections_noLoadingCheckTotal_ReturnsZero(): void
		{
			Assert.assertEquals(0, _queueManager.activeConnections);
		}
		
		[Test]
		public function activeConnections_twoLoadCall_checkTotal_ReturnsTwo(): void
		{
			var loader:RequestLoader = _queueManager.getNext();
			loader.load();
			loader = _queueManager.getNext();
			loader.load();
			
			Assert.assertEquals(2, _queueManager.activeConnections);
		}
		
		///////////////////////////////////////////////
		// RequestLoaderQueueManager().totalCanceled //
		///////////////////////////////////////////////
		
		[Test]
		public function totalCanceled_noCanceledCheckTotal_ReturnsZero(): void
		{
			Assert.assertEquals(0, _queueManager.totalCanceled);
		}
		
		[Test]
		public function totalCanceled_cancelAndCheckTotal_ReturnsOne(): void
		{
			var loader:RequestLoader = _queueManager.getNext();
			loader.cancel();
			
			Assert.assertEquals(1, _queueManager.totalCanceled);
		}
		
		///////////////////////////////////////////////
		// RequestLoaderQueueManager().totalComplete //
		///////////////////////////////////////////////
		
		[Test]
		public function totalComplete_noCompleteCheckTotal_ReturnsZero(): void
		{
			Assert.assertEquals(0, _queueManager.totalComplete);
		}
		
		[Test]
		public function totalComplete_loadDispatchesCompleteAndCheckTotal_ReturnsOne(): void
		{
			var loader:RequestLoader = _queueManager.getNext();
			loader.load();
			loader.dispatchEvent(new RequestLoaderEvent(RequestLoaderEvent.STATUS_CHANGED, RequestLoaderStatus.COMPLETE));
			
			Assert.assertEquals(1, _queueManager.totalComplete);
		}
		
		//////////////////////////////////////////////
		// RequestLoaderQueueManager().totalLoading //
		//////////////////////////////////////////////
		
		[Test]
		public function totalLoading_noLoadingCheckTotal_ReturnsZero(): void
		{
			Assert.assertEquals(0, _queueManager.totalLoading);
		}
		
		[Test]
		public function totalLoading_twoLoadCall_checkTotal_ReturnsTwo(): void
		{
			var loader:RequestLoader = _queueManager.getNext();
			loader.load();
			
			loader = _queueManager.getNext();
			loader.load();
			
			Assert.assertEquals(2, _queueManager.totalLoading);
		}
		
		/////////////////////////////////////////////
		// RequestLoaderQueueManager().totalQueued //
		/////////////////////////////////////////////
		
		[Test]
		public function totalQueued_checkTotal_ReturnsTwo(): void
		{
			Assert.assertEquals(2, _queueManager.totalQueued);
		}
		
		[Test]
		public function totalQueued_getNextAndCheckTotal_ReturnsOne(): void
		{
			_queueManager.getNext();
			Assert.assertEquals(1, _queueManager.totalQueued);
		}
		
		//////////////////////////////////////////////
		// RequestLoaderQueueManager().totalStopped //
		//////////////////////////////////////////////
		
		[Test]
		public function totalStopped_noStoppedCheckTotal_ReturnsZero(): void
		{
			Assert.assertEquals(0, _queueManager.totalStopped);
		}
		
		[Test]
		public function totalStopped_stopAndCheckTotal_ReturnsOne(): void
		{
			var loader:RequestLoader = _queueManager.getNext();
			loader.stop();
			
			Assert.assertEquals(1, _queueManager.totalStopped);
		}
		
	}

}