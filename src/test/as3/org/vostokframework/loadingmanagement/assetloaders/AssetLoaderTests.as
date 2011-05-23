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

package org.vostokframework.loadingmanagement.assetloaders
{
	import mockolate.decorations.EventDispatcherDecorator;
	import mockolate.mock;
	import mockolate.runner.MockolateRule;
	import mockolate.strict;
	import mockolate.stub;
	import mockolate.verify;

	import org.flexunit.Assert;
	import org.vostokframework.assetmanagement.AssetLoadingPriority;
	import org.vostokframework.assetmanagement.settings.LoadingAssetPolicySettings;
	import org.vostokframework.assetmanagement.settings.LoadingAssetSettings;

	/**
	 * @author Flávio Silva
	 */
	[TestCase(order=999)]
	public class AssetLoaderTests
	{
		[Rule]
		public var mocks:MockolateRule = new MockolateRule();
		
		[Mock(type="strict",inject="false")]
		public var _fileLoaderMockolate:IFileLoader;
		
		private var _loader:AssetLoader;
		private var _loader2:AssetLoader;
		
		public function AssetLoaderTests()
		{
			
		}
		
		/////////////////////////
		// TESTS CONFIGURATION //
		/////////////////////////
		
		[Before]
		public function setUp(): void
		{
			
			var settings:LoadingAssetSettings = new LoadingAssetSettings(new LoadingAssetPolicySettings(3));
			_loader = new AssetLoader("asset-loader", AssetLoadingPriority.MEDIUM, new VostokLoaderStub(), settings);
			
			_fileLoaderMockolate = strict(IFileLoader);
			stub(_fileLoaderMockolate).decorate(IFileLoader, EventDispatcherDecorator);
			
			_loader2 = new AssetLoader("asset-loader", AssetLoadingPriority.MEDIUM, _fileLoaderMockolate, settings);
		}
		
		[After]
		public function tearDown(): void
		{
			_loader = null;
			_loader2 = null;
			_fileLoaderMockolate = null;
		}
		
		///////////////////////
		// CONSTRUCTOR TESTS //
		///////////////////////
		
		[Test(expects="ArgumentError")]
		public function constructor_invalidId_ThrowsError(): void
		{
			var loader:AssetLoader = new AssetLoader(null, null, null, null);
			loader = null;
		}
		
		[Test(expects="ArgumentError")]
		public function constructor_invalidPriority_ThrowsError(): void
		{
			var loader:AssetLoader = new AssetLoader("id", null, null, null);
			loader = null;
		}
		
		[Test(expects="ArgumentError")]
		public function constructor_invalidFileLoader_ThrowsError(): void
		{
			var loader:AssetLoader = new AssetLoader("id", AssetLoadingPriority.MEDIUM, null, null);
			loader = null;
		}
		
		[Test(expects="ArgumentError")]
		public function constructor_invalidSettings_ThrowsError(): void
		{
			var loader:AssetLoader = new AssetLoader("id", AssetLoadingPriority.MEDIUM, new VostokLoaderStub(), null);
			loader = null;
		}
		
		[Test]
		public function constructor_validInstanciation_ReturnsValidObject(): void
		{
			var loader:AssetLoader = new AssetLoader("id", AssetLoadingPriority.MEDIUM, new VostokLoaderStub(), new LoadingAssetSettings(new LoadingAssetPolicySettings()));
			loader = null;
		}
		
		//////////////////////////////////
		// AbstractAssetLoader().status //
		//////////////////////////////////
		
		[Test]
		public function status_freshObject_checkIfStatusIs_QUEUED_ReturnsTrue(): void
		{
			Assert.assertEquals(AssetLoaderStatus.QUEUED, _loader.status);
		}
		
		[Test]
		public function status_afterCallLoad_checkIfStatusIs_TRYING_TO_CONNECT_ReturnsTrue(): void
		{
			_loader.load();
			Assert.assertEquals(AssetLoaderStatus.TRYING_TO_CONNECT, _loader.status);
		}
		
		////////////////////////////////////////////
		// AbstractAssetLoader().historicalStatus //
		////////////////////////////////////////////
		
		[Test]
		public function historicalStatus_freshObject_checkIfFirstElementIs_QUEUED_ReturnsTrue(): void
		{
			Assert.assertEquals(AssetLoaderStatus.QUEUED, _loader.historicalStatus.getAt(0));
		}
		
		[Test]
		public function historicalStatus_afterCallLoad_checkIfSecondElementIs_TRYING_TO_CONNECT_ReturnsTrue(): void
		{
			_loader.load();
			Assert.assertEquals(AssetLoaderStatus.TRYING_TO_CONNECT, _loader.historicalStatus.getAt(1));
		}
		
		//////////////////////////////////
		// AbstractAssetLoader().cancel() //
		//////////////////////////////////
		
		[Test]
		public function cancel_checkIfStatusIs_CANCELED_ReturnsTrue(): void
		{
			_loader.cancel();
			Assert.assertEquals(AssetLoaderStatus.CANCELED, _loader.status);
		}
		
		[Test]
		public function cancel_doubleCall_checkIfStatusIs_CANCELED_ReturnsTrue(): void
		{
			_loader.cancel();
			_loader.cancel();
			Assert.assertEquals(AssetLoaderStatus.CANCELED, _loader.status);
		}
		
		[Test]
		public function cancel_checkIfMockWasCalled_Void(): void
		{
			mock(_fileLoaderMockolate).method("cancel");
			_loader2.cancel();
			verify(_fileLoaderMockolate);
		}
		
		//////////////////////////////////
		// AbstractAssetLoader().stop() //
		//////////////////////////////////
		
		[Test]
		public function stop_checkStatus_STOPPED(): void
		{
			_loader.stop();
			Assert.assertEquals(AssetLoaderStatus.STOPPED, _loader.status);
		}
		
		[Test]
		public function stop_doubleCallCheckStatus_STOPPED(): void
		{
			_loader.stop();
			_loader.stop();
			Assert.assertEquals(AssetLoaderStatus.STOPPED, _loader.status);
		}
		
		////////////////////////////////////////////////////////////////
		// AbstractAssetLoader().stop()-load()-cancel() - MIXED TESTS //
		////////////////////////////////////////////////////////////////
		
		[Test]
		public function loadAndStop_CheckStatus_STOPPED(): void
		{
			_loader.load();
			_loader.stop();
			Assert.assertEquals(AssetLoaderStatus.STOPPED, _loader.status);
		}
		
		[Test]
		public function stopAndLoad_CheckStatus_TRYING_TO_CONNECT(): void
		{
			_loader.stop();
			_loader.load();
			Assert.assertEquals(AssetLoaderStatus.TRYING_TO_CONNECT, _loader.status);
		}
		
		[Test]
		public function loadAndCancel_CheckStatus_CANCELED(): void
		{
			_loader.load();
			_loader.cancel();
			Assert.assertEquals(AssetLoaderStatus.CANCELED, _loader.status);
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
			Assert.assertEquals(AssetLoaderStatus.STOPPED, _loader.status);
		}
		
		[Test]
		public function loadAndStopAndLoadAndStop_CheckStatus_STOPPED(): void
		{
			_loader.load();
			_loader.stop();
			_loader.load();
			_loader.stop();
			Assert.assertEquals(AssetLoaderStatus.STOPPED, _loader.status);
		}
		
		[Test]
		public function loadAndStopAndCancel_CheckStatus_CANCELED(): void
		{
			_loader.load();
			_loader.stop();
			_loader.cancel();
			Assert.assertEquals(AssetLoaderStatus.CANCELED, _loader.status);
		}
		
		[Test(expects="flash.errors.IllegalOperationError")]
		public function loadAndStopAndCancelAndLoad_illegalOperation_ThrowsError(): void
		{
			_loader.load();
			_loader.stop();
			_loader.cancel();
			_loader.load();
		}
		
	}

}