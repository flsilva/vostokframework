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
	import org.vostokframework.loadingmanagement.assetloaders.VostokLoaderStub;
	import org.vostokframework.loadingmanagement.policies.StubAssetLoadingPolicy;

	/**
	 * @author Flávio Silva
	 */
	[TestCase(order=14)]
	public class RequestLoaderTests
	{
		
		private var _assetLoader1:AssetLoader;
		private var _assetLoader2:AssetLoader;
		private var _assetLoader3:AssetLoader;
		private var _assetLoader4:AssetLoader;
		private var _loader:RequestLoader;
		
		public function RequestLoaderTests()
		{
			
		}
		
		/////////////////////////
		// TESTS CONFIGURATION //
		/////////////////////////
		
		[Before]
		public function setUp(): void
		{
			var assetLoaders:IList = new ArrayList();
			
			_assetLoader1 = new AssetLoader("asset-loader-1", LoadPriority.MEDIUM, new VostokLoaderStub(), 3);
			_assetLoader2 = new AssetLoader("asset-loader-2", LoadPriority.LOW, new VostokLoaderStub(), 3);
			_assetLoader3 = new AssetLoader("asset-loader-3", LoadPriority.HIGH, new VostokLoaderStub(), 3);
			_assetLoader4 = new AssetLoader("asset-loader-4", LoadPriority.MEDIUM, new VostokLoaderStub(), 3);
			
			assetLoaders.add(_assetLoader1);
			assetLoaders.add(_assetLoader2);
			assetLoaders.add(_assetLoader3);
			assetLoaders.add(_assetLoader4);
			
			var policy:StubAssetLoadingPolicy = new StubAssetLoadingPolicy();
			policy.globalMaxConnections = 6;
			policy.localMaxConnections = 3;
			policy.totalGlobalConnections = 0;
			
			var queueManager:AssetLoaderQueueManager = new AssetLoaderQueueManager(assetLoaders, policy);
			
			_loader = new RequestLoader("request-loader", queueManager, LoadPriority.MEDIUM);
		}
		
		[After]
		public function tearDown(): void
		{
			_loader = null;
			_assetLoader1 = null;
			_assetLoader2 = null;
			_assetLoader3 = null;
			_assetLoader4 = null;
		}
		
		///////////////////////
		// CONSTRUCTOR TESTS //
		///////////////////////
		
		
		
		////////////////////////////
		// RequestLoader().status //
		////////////////////////////
		
		[Test]
		public function status_validGet_QUEUED(): void
		{
			Assert.assertEquals(RequestLoaderStatus.QUEUED, _loader.status);
		}
		
		[Test]
		public function status_loadAndCheckStatus_TRYING_TO_CONNECT(): void
		{
			_loader.load();
			Assert.assertEquals(RequestLoaderStatus.TRYING_TO_CONNECT, _loader.status);
		}
		
		//////////////////////////////////////
		// RequestLoader().historicalStatus //
		//////////////////////////////////////
		
		[Test]
		public function historicalStatus_validGet_QUEUED(): void
		{
			Assert.assertEquals(RequestLoaderStatus.QUEUED, _loader.historicalStatus.getAt(0));
		}
		
		[Test]
		public function historicalStatus_validGet_TRYING_TO_CONNECT(): void
		{
			_loader.load();
			Assert.assertEquals(RequestLoaderStatus.TRYING_TO_CONNECT, _loader.historicalStatus.getAt(1));
		}
		
		//////////////////////////////
		// RequestLoader().cancel() //
		//////////////////////////////
		
		[Test]
		public function cancel_checkStatus_CANCELED(): void
		{
			_loader.cancel();
			Assert.assertEquals(RequestLoaderStatus.CANCELED, _loader.status);
		}
		
		[Test]
		public function cancel_doubleCallCheckStatus_CANCELED(): void
		{
			_loader.cancel();
			_loader.cancel();
			Assert.assertEquals(RequestLoaderStatus.CANCELED, _loader.status);
		}
		
		////////////////////////////
		// RequestLoader().load() //
		////////////////////////////
		
		[Test]
		public function load_checkReturn_True(): void
		{
			var allowedLoading:Boolean = _loader.load();
			Assert.assertTrue(allowedLoading);
		}
		
		[Test(expects="flash.errors.IllegalOperationError")]
		public function load_doubleCall_ThrowsError(): void
		{
			_loader.load();
			_loader.load();
		}
		
		[Test]
		public function load_checkStatus_TRYING_TO_CONNECT(): void
		{
			_loader.load();
			Assert.assertEquals(RequestLoaderStatus.TRYING_TO_CONNECT, _loader.status);
		}
		
		[Test]
		public function load_checkLoaderStatus_TRYING_TO_CONNECT(): void
		{
			_loader.load();
			
			Assert.assertEquals(LoaderStatus.CONNECTING, _assetLoader3.status);
		}
		
		[Test]
		public function load_checkLoaderStatus2_CONNECTING(): void
		{
			_loader.load();
			
			Assert.assertEquals(LoaderStatus.CONNECTING, _assetLoader4.status);
		}
		/*
		[Test]
		public function load_checkLoaderStatus3_CONNECTING(): void
		{
			_loader.load();
			_assetLoader3.dispatchEvent(new LoaderEvent(LoaderEvent.STATUS_CHANGED, LoaderStatus.COMPLETE));
			Assert.assertEquals(LoaderStatus.CONNECTING, _assetLoader2.status);
		}
		*/
		[Test]
		public function load_checkLoaderStatus_QUEUED(): void
		{
			_loader.load();
			
			Assert.assertEquals(LoaderStatus.QUEUED, _assetLoader2.status);
		}
		/*
		[Test]
		public function load_checkStatus_COMPLETE(): void
		{
			_loader.load();
			_assetLoader3.dispatchEvent(new LoaderEvent(LoaderEvent.STATUS_CHANGED, LoaderStatus.COMPLETE));
			_assetLoader1.dispatchEvent(new LoaderEvent(LoaderEvent.STATUS_CHANGED, LoaderStatus.COMPLETE));
			_assetLoader4.dispatchEvent(new LoaderEvent(LoaderEvent.STATUS_CHANGED, LoaderStatus.COMPLETE));
			_assetLoader2.dispatchEvent(new LoaderEvent(LoaderEvent.STATUS_CHANGED, LoaderStatus.COMPLETE));
			
			Assert.assertEquals(RequestLoaderStatus.COMPLETE, _loader.status);
		}
		*/
		////////////////////////////
		// RequestLoader().stop() //
		////////////////////////////
		
		[Test]
		public function stop_checkStatus_STOPPED(): void
		{
			_loader.stop();
			Assert.assertEquals(RequestLoaderStatus.STOPPED, _loader.status);
		}
		
		[Test]
		public function stop_doubleCallCheckStatus_STOPPED(): void
		{
			_loader.stop();
			_loader.stop();
			Assert.assertEquals(RequestLoaderStatus.STOPPED, _loader.status);
		}
		
		//////////////////////////////////////////////////////////
		// RequestLoader().stop()-load()-cancel() - MIXED TESTS //
		//////////////////////////////////////////////////////////
		
		[Test]
		public function loadAndStop_CheckStatus_STOPPED(): void
		{
			_loader.load();
			_loader.stop();
			Assert.assertEquals(RequestLoaderStatus.STOPPED, _loader.status);
		}
		
		[Test]
		public function stopAndLoad_CheckStatus_CONNECTING(): void
		{
			_loader.stop();
			_loader.load();
			Assert.assertEquals(RequestLoaderStatus.TRYING_TO_CONNECT, _loader.status);
		}
		
		[Test]
		public function loadAndCancel_CheckStatus_CANCELED(): void
		{
			_loader.load();
			_loader.cancel();
			Assert.assertEquals(RequestLoaderStatus.CANCELED, _loader.status);
		}
		
		[Test(expects="flash.errors.IllegalOperationError")]
		public function loadAndCancelAndLoad_illegalOperation_ThrowsError(): void
		{
			_loader.load();
			_loader.cancel();
			_loader.load();
		}
		
		[Test(expects="flash.errors.IllegalOperationError")]
		public function cancelAndLoad_illegalOperation_ThrowsError(): void
		{
			_loader.cancel();
			_loader.load();
		}
		
		[Test]
		public function loadAndStopAndLoad_CheckLoadReturn_True(): void
		{
			_loader.load();
			_loader.stop();
			var allowedLoading:Boolean = _loader.load();
			Assert.assertTrue(allowedLoading);
		}
		
		[Test]
		public function stopAndLoadAndStop_CheckStatus_STOPPED(): void
		{
			_loader.stop();
			_loader.load();
			_loader.stop();
			Assert.assertEquals(RequestLoaderStatus.STOPPED, _loader.status);
		}
		
		[Test]
		public function loadAndStopAndLoadAndStop_CheckStatus_STOPPED(): void
		{
			_loader.load();
			_loader.stop();
			_loader.load();
			_loader.stop();
			Assert.assertEquals(RequestLoaderStatus.STOPPED, _loader.status);
		}
		
		[Test]
		public function loadAndStopAndCancel_CheckStatus_CANCELED(): void
		{
			_loader.load();
			_loader.stop();
			_loader.cancel();
			Assert.assertEquals(RequestLoaderStatus.CANCELED, _loader.status);
		}
		
		[Test(expects="flash.errors.IllegalOperationError")]
		public function loadAndStopAndCancelAndLoad_illegalOperation_ThrowsError(): void
		{
			_loader.load();
			_loader.stop();
			_loader.cancel();
			_loader.load();
		}
		
		///////////////////////////////////////
		// RequestLoader().stopAssetLoader() //
		///////////////////////////////////////
		
		[Test(expects="ArgumentError")]
		public function stopAssetLoader_invalidId_ThrowsError(): void
		{
			_loader.stopAssetLoader(null);
		}
		
		[Test(expects="org.vostokframework.loadingmanagement.errors.AssetLoaderNotFoundError")]
		public function stopAssetLoader_idNotAdded_ThrowsError(): void
		{
			_loader.stopAssetLoader("any-not-added-id");
		}
		
		[Test]
		public function stopAssetLoader_CheckStatus_STOPPED(): void
		{
			_loader.stopAssetLoader("asset-loader-3");
			Assert.assertEquals(LoaderStatus.STOPPED, _assetLoader3.status);
		}
		
	}

}