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
	import org.flexunit.Assert;
	import org.flexunit.async.Async;
	import org.vostokframework.assetmanagement.settings.LoadingAssetPolicySettings;
	import org.vostokframework.assetmanagement.settings.LoadingAssetSettings;
	import org.vostokframework.loadingmanagement.events.AssetLoaderEvent;
	import org.vostokframework.loadingmanagement.events.FileLoaderEvent;

	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.setTimeout;

	/**
	 * @author Flávio Silva
	 */
	[TestCase(order=12)]
	public class AbstractAssetLoaderTests
	{
		
		private var _fileLoader:VostokLoaderStub;
		private var _loader:AbstractAssetLoader;
		private var _timer:Timer;
		
		public function AbstractAssetLoaderTests()
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
			_fileLoader = new VostokLoaderStub();
			_loader = new AbstractAssetLoader("asset-loader", _fileLoader, settings);
		}
		
		[After]
		public function tearDown(): void
		{
			_timer.stop();
			_timer = null;
			_fileLoader = null;
			_loader = null;
			//_event = null;
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
		
		//////////////////////////////////
		// AbstractAssetLoader().status //
		//////////////////////////////////
		
		[Test]
		public function status_validGet_QUEUED(): void
		{
			Assert.assertEquals(AssetLoaderStatus.QUEUED, _loader.status);
		}
		
		[Test]
		public function status_validGet_TRYING_TO_CONNECT(): void
		{
			_loader.load();
			Assert.assertEquals(AssetLoaderStatus.TRYING_TO_CONNECT, _loader.status);
		}
		
		////////////////////////////////////////////
		// AbstractAssetLoader().historicalStatus //
		////////////////////////////////////////////
		
		[Test]
		public function historicalStatus_validGet_QUEUED(): void
		{
			Assert.assertEquals(AssetLoaderStatus.QUEUED, _loader.historicalStatus.getAt(0));
		}
		
		[Test]
		public function historicalStatus_validGet_TRYING_TO_CONNECT(): void
		{
			_loader.load();
			Assert.assertEquals(AssetLoaderStatus.TRYING_TO_CONNECT, _loader.historicalStatus.getAt(1));
		}
		
		//////////////////////////////////
		// AbstractAssetLoader().cancel() //
		//////////////////////////////////
		
		[Test]
		public function cancel_checkStatus_CANCELED(): void
		{
			_loader.cancel();
			Assert.assertEquals(AssetLoaderStatus.CANCELED, _loader.status);
		}
		
		[Test]
		public function cancel_doubleCallCheckStatus_CANCELED(): void
		{
			_loader.cancel();
			_loader.cancel();
			Assert.assertEquals(AssetLoaderStatus.CANCELED, _loader.status);
		}
		
		//////////////////////////////////
		// AbstractAssetLoader().load() //
		//////////////////////////////////
		
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
		
		[Test(async)]
		public function load_checkStatus_TRYING_TO_CONNECT(): void
		{
			//_loader.load();
			//Assert.assertEquals(AssetLoaderStatus.TRYING_TO_CONNECT, _loader.status);
			
			_loader.addEventListener(AssetLoaderEvent.STATUS_CHANGED,
									Async.asyncHandler(this, assetLoaderEventHandler, 200,
														{propertyName:"status", propertyValue:AssetLoaderStatus.TRYING_TO_CONNECT},
														timerTimeoutHandler),
									false, 0, true);
			
			_loader.load();
		}
		
		[Test(async)]
		public function load_stubDispatchOpen_LOADING(): void
		{
			_timer.addEventListener(TimerEvent.TIMER_COMPLETE,
									Async.asyncHandler(this, timerCompleteHandler, 200,
														{propertyName:"status", propertyValue:AssetLoaderStatus.LOADING},
														timerTimeoutHandler),
									false, 0, true);
			
			_loader.load();
			_fileLoader.asyncDispatchEvent(new Event(Event.INIT), 15);
			_fileLoader.asyncDispatchEvent(new Event(Event.OPEN), 25);
			_timer.start();
		}
		
		[Test(async)]
		public function load_stubDispatchComplete_COMPLETE(): void
		{
			_timer.addEventListener(TimerEvent.TIMER_COMPLETE,
									Async.asyncHandler(this, timerCompleteHandler, 200,
														{propertyName:"status", propertyValue:AssetLoaderStatus.COMPLETE},
														timerTimeoutHandler),
									false, 0, true);
			
			_loader.load();
			_fileLoader.asyncDispatchEvent(new FileLoaderEvent(FileLoaderEvent.COMPLETE, null));
			_timer.start();
		}
		
		[Test(async)]
		public function load_stubDispatchIOError_FAILED(): void
		{
			_timer.addEventListener(TimerEvent.TIMER_COMPLETE,
									Async.asyncHandler(this, timerCompleteHandler, 200,
														{propertyName:"status", propertyValue:AssetLoaderStatus.FAILED_IO_ERROR},
														timerTimeoutHandler),
									false, 0, true);
			
			_loader.load();
			_fileLoader.asyncDispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR));
			_timer.start();
		}
		
		[Test(async)]
		public function load_stubDispatchSecurityError_FAILED(): void
		{
			_timer.addEventListener(TimerEvent.TIMER_COMPLETE,
									Async.asyncHandler(this, timerCompleteHandler, 200,
														{propertyName:"status", propertyValue:AssetLoaderStatus.FAILED_SECURITY_ERROR},
														timerTimeoutHandler),
									false, 0, true);
			
			_loader.load();
			_fileLoader.asyncDispatchEvent(new SecurityErrorEvent(SecurityErrorEvent.SECURITY_ERROR));
			_timer.start();
		}
		
		[Test(async)]
		public function loadStressTest_validSequence_LOADING(): void
		{
			_loader.load();
			_fileLoader.asyncDispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR), 25);
			setTimeout(_loader.load, 50);
			_fileLoader.asyncDispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR), 75);
			setTimeout(_loader.load, 100);
			
			_timer.addEventListener(TimerEvent.TIMER_COMPLETE,
									Async.asyncHandler(this, timerCompleteHandler, 200,
														{propertyName:"status", propertyValue:AssetLoaderStatus.TRYING_TO_CONNECT},
														timerTimeoutHandler),
									false, 0, true);
			
			_timer.start();
		}
		
		[Test(async)]
		public function loadStressTest_validSequence_FAILED_EXHAUSTED_ATTEMPTS(): void
		{
			_loader.load();
			_fileLoader.asyncDispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR), 25);
			setTimeout(_loader.load, 50);
			_fileLoader.asyncDispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR), 75);
			setTimeout(_loader.load, 100);
			_fileLoader.asyncDispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR), 125);
			setTimeout(_loader.load, 150);
			
			_timer.addEventListener(TimerEvent.TIMER_COMPLETE,
									Async.asyncHandler(this, timerCompleteHandler, 200,
														{propertyName:"status", propertyValue:AssetLoaderStatus.FAILED_EXHAUSTED_ATTEMPTS},
														timerTimeoutHandler),
									false, 0, true);
			
			_timer.start();
		}
		
		[Test(expects="flash.errors.IllegalOperationError")]
		public function loadStressTest_invalidSequence_ThrowsError(): void
		{
			_loader.load();
			_fileLoader.dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR));
			_loader.load();
			_fileLoader.dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR));
			_loader.load();
			_fileLoader.dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR));
			_loader.load();
			_loader.load();
		}
		
		[Test(order=100)]
		public function loadStressTest_validSequenceCheckStatus_TRYING_TO_CONNECT(): void
		{
			_loader.load();
			_fileLoader.dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR));
			_loader.load();
			_fileLoader.dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR));
			_loader.load();
			_loader.stop();
			_loader.load();
			
			Assert.assertEquals(AssetLoaderStatus.TRYING_TO_CONNECT, _loader.status);
		}
		
		public function timerCompleteHandler(event:TimerEvent, passThroughData:Object):void
		{
			Assert.assertEquals(passThroughData["propertyValue"], _loader[passThroughData["propertyName"]]);
		}
		
		public function assetLoaderEventHandler(event:AssetLoaderEvent, passThroughData:Object):void
		{
			Assert.assertEquals(passThroughData["propertyValue"], event[passThroughData["propertyName"]]);
		}
		
		public function timerTimeoutHandler(passThroughData:Object):void
		{
			Assert.fail("Asynchronous Test Failed: Timeout");
			passThroughData = null;
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