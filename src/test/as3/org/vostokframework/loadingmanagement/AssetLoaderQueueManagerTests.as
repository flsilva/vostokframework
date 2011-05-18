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
	import org.vostokframework.loadingmanagement.assetloaders.VostokLoaderStub;

	import flash.utils.Timer;

	/**
	 * @author Flávio Silva
	 */
	[TestCase(order=13)]
	public class AssetLoaderQueueManagerTests
	{
		
		private var _queueManager:AssetLoaderQueueManager;
		private var _timer:Timer;
		
		public function AssetLoaderQueueManagerTests()
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
			var loaders:IList = new ArrayList();
			var loader:AbstractAssetLoader;
			
			loader = new AbstractAssetLoader("asset-loader-1", AssetLoadingPriority.MEDIUM, new VostokLoaderStub(), settings);
			loaders.add(loader);
			
			loader = new AbstractAssetLoader("asset-loader-2", AssetLoadingPriority.LOW, new VostokLoaderStub(), settings);
			loaders.add(loader);
			
			loader = new AbstractAssetLoader("asset-loader-3", AssetLoadingPriority.HIGH, new VostokLoaderStub(), settings);
			loaders.add(loader);
			
			loader = new AbstractAssetLoader("asset-loader-4", AssetLoadingPriority.MEDIUM, new VostokLoaderStub(), settings);
			loaders.add(loader);
			
			_queueManager = new AssetLoaderQueueManager(loaders, 3);
		}
		
		[After]
		public function tearDown(): void
		{
			_timer.stop();
			_timer = null;
			_queueManager = null;
		}
		
		///////////////////////
		// CONSTRUCTOR TESTS //
		///////////////////////
		
		/////////////////////////////////////////
		// AssetLoaderQueueManager().getNext() //
		/////////////////////////////////////////
		
		[Test]
		public function getNext_simpleCall_AbstractAssetLoader(): void
		{
			var loader:AbstractAssetLoader = _queueManager.getNext();
			Assert.assertNotNull(loader);
		}
		
		[Test]
		public function getNext_exceedsConcurrentConnections_ReturnsNull(): void
		{
			var loader:AbstractAssetLoader = _queueManager.getNext();
			loader.load();
			
			loader = _queueManager.getNext();
			loader.load();
			
			loader = _queueManager.getNext();
			loader.load();
			
			loader = _queueManager.getNext();
			Assert.assertNull(loader);
		}
		
		/////////////////////////////////////////////////
		// AssetLoaderQueueManager().activeConnections //
		/////////////////////////////////////////////////
		
		[Test]
		public function activeConnections_cancelAndCheckTotal_Int(): void
		{
			var loader:AbstractAssetLoader = _queueManager.getNext();
			loader.load();
			loader = _queueManager.getNext();
			loader.load();
			
			Assert.assertEquals(2, _queueManager.activeConnections);
		}
		
		////////////////////////////////////////////
		// AssetLoaderQueueManager().totalCanceled //
		////////////////////////////////////////////
		
		[Test]
		public function totalCanceled_checkTotal_Int(): void
		{
			Assert.assertEquals(0, _queueManager.totalCanceled);
		}
		
		[Test]
		public function totalCanceled_cancelAndCheckTotal_Int(): void
		{
			var loader:AbstractAssetLoader = _queueManager.getNext();
			loader.cancel();
			
			Assert.assertEquals(1, _queueManager.totalCanceled);
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
			var loader:AbstractAssetLoader = _queueManager.getNext();
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
			var loader:AbstractAssetLoader = _queueManager.getNext();
			loader.stop();
			
			Assert.assertEquals(1, _queueManager.totalStopped);
		}
		
	}

}