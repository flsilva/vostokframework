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
	import org.vostokframework.loadingmanagement.assetloaders.AbstractAssetLoader;
	import org.vostokframework.loadingmanagement.assetloaders.AssetLoaderStatus;
	import org.vostokframework.loadingmanagement.assetloaders.VostokLoaderStub;
	import org.vostokframework.loadingmanagement.events.AssetLoaderEvent;

	import flash.utils.Timer;

	/**
	 * @author Flávio Silva
	 */
	[TestCase(order=14)]
	public class RequestLoaderTests
	{
		
		private var _assetLoader1:AbstractAssetLoader;
		private var _assetLoader2:AbstractAssetLoader;
		private var _assetLoader3:AbstractAssetLoader;
		private var _assetLoader4:AbstractAssetLoader;
		private var _loader:RequestLoader;
		private var _timer:Timer;
		
		public function RequestLoaderTests()
		{
			
		}
		
		/////////////////////////
		// TESTS CONFIGURATION //
		/////////////////////////
		
		[Before]
		public function setUp(): void
		{
			_timer = new Timer(200, 1);
			
			var settings:LoadingAssetSettings = new LoadingAssetSettings(new LoadingAssetPolicySettings(3));
			var assetLoaders:IList = new ArrayList();
			
			_assetLoader1 = new AbstractAssetLoader("asset-loader-1", AssetLoadingPriority.MEDIUM, new VostokLoaderStub(), settings);
			_assetLoader2 = new AbstractAssetLoader("asset-loader-2", AssetLoadingPriority.LOW, new VostokLoaderStub(), settings);
			_assetLoader3 = new AbstractAssetLoader("asset-loader-3", AssetLoadingPriority.HIGH, new VostokLoaderStub(), settings);
			_assetLoader4 = new AbstractAssetLoader("asset-loader-4", AssetLoadingPriority.MEDIUM, new VostokLoaderStub(), settings);
			
			assetLoaders.add(_assetLoader1);
			assetLoaders.add(_assetLoader2);
			assetLoaders.add(_assetLoader3);
			assetLoaders.add(_assetLoader4);
			
			var queueManager:AssetLoaderQueueManager = new AssetLoaderQueueManager(assetLoaders, 3);
			
			_loader = new RequestLoader("request-loader", queueManager, LoadingRequestPriority.MEDIUM);
		}
		
		[After]
		public function tearDown(): void
		{
			_timer.stop();
			_timer = null;
			_loader = null;
		}
		
		///////////////////////
		// CONSTRUCTOR TESTS //
		///////////////////////
		/*
		[Test(expects="flash.errors.IllegalOperationError")]
		public function constructor_invalidInstantiation1_ThrowsError(): void
		{
			var loader:AbstractAssetLoader = new AbstractAssetLoader(null, null);
			loader = null;
		}
		*/
		
		////////////////////////////
		// RequestLoader().status //
		////////////////////////////
		
		[Test]
		public function status_validGet_QUEUED(): void
		{
			Assert.assertEquals(RequestLoaderStatus.QUEUED, _loader.status);
		}
		
		[Test]
		public function status_loadAndCheckStatus_LOADING(): void
		{
			_loader.load();
			Assert.assertEquals(RequestLoaderStatus.LOADING, _loader.status);
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
		public function historicalStatus_validGet_LOADING(): void
		{
			_loader.load();
			Assert.assertEquals(RequestLoaderStatus.LOADING, _loader.historicalStatus.getAt(1));
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
		public function load_checkStatus_LOADING(): void
		{
			_loader.load();
			Assert.assertEquals(RequestLoaderStatus.LOADING, _loader.status);
		}
		
		[Test]
		public function load_checkAssetLoaderStatus_TRYING_TO_CONNECT(): void
		{
			_loader.load();
			
			Assert.assertEquals(AssetLoaderStatus.TRYING_TO_CONNECT, _assetLoader3.status);
		}
		
		[Test]
		public function load_checkAssetLoaderStatus2_TRYING_TO_CONNECT(): void
		{
			_loader.load();
			
			Assert.assertEquals(AssetLoaderStatus.TRYING_TO_CONNECT, _assetLoader4.status);
		}
		
		[Test]
		public function load_checkAssetLoaderStatus3_TRYING_TO_CONNECT(): void
		{
			_loader.load();
			_assetLoader3.dispatchEvent(new AssetLoaderEvent(AssetLoaderEvent.STATUS_CHANGED, AssetLoaderStatus.COMPLETE));
			Assert.assertEquals(AssetLoaderStatus.TRYING_TO_CONNECT, _assetLoader2.status);
		}
		
		[Test]
		public function load_checkAssetLoaderStatus_QUEUED(): void
		{
			_loader.load();
			
			Assert.assertEquals(AssetLoaderStatus.QUEUED, _assetLoader2.status);
		}
		
		[Test]
		public function load_checkStatus_COMPLETE(): void
		{
			_loader.load();
			_assetLoader3.dispatchEvent(new AssetLoaderEvent(AssetLoaderEvent.STATUS_CHANGED, AssetLoaderStatus.COMPLETE));
			_assetLoader1.dispatchEvent(new AssetLoaderEvent(AssetLoaderEvent.STATUS_CHANGED, AssetLoaderStatus.COMPLETE));
			_assetLoader4.dispatchEvent(new AssetLoaderEvent(AssetLoaderEvent.STATUS_CHANGED, AssetLoaderStatus.COMPLETE));
			_assetLoader2.dispatchEvent(new AssetLoaderEvent(AssetLoaderEvent.STATUS_CHANGED, AssetLoaderStatus.COMPLETE));
			
			Assert.assertEquals(RequestLoaderStatus.COMPLETE, _loader.status);
		}
		
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
		public function stopAndLoad_CheckStatus_LOADING(): void
		{
			_loader.stop();
			_loader.load();
			Assert.assertEquals(RequestLoaderStatus.LOADING, _loader.status);
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
			_loader.stopAssetLoader("asset-loader-89745389543");
		}
		
		[Test]
		public function stopAssetLoader_CheckStatus_STOPPED(): void
		{
			_loader.stopAssetLoader("asset-loader-3");
			Assert.assertEquals(AssetLoaderStatus.STOPPED, _assetLoader3.status);
		}
		
	}

}