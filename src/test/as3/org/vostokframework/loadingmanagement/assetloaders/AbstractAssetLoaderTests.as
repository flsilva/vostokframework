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
	import org.vostokframework.loadingmanagement.events.FileLoaderEvent;

	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

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
			_timer = new Timer(100, 1);
			
			var settings:LoadingAssetSettings = new LoadingAssetSettings(new LoadingAssetPolicySettings());
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
		
		//////////////////////////////////
		// AbstractAssetLoader().load() //
		//////////////////////////////////
		
		[Test]
		public function load_checkReturn_True(): void
		{
			var allowedLoading:Boolean = _loader.load();
			Assert.assertTrue(allowedLoading);
		}
		
		[Test]
		public function load_checkStatus_TRYING_TO_CONNECT(): void
		{
			_loader.load();
			Assert.assertEquals(AssetLoaderStatus.TRYING_TO_CONNECT, _loader.status);
		}
		
		[Test(async)]
		public function load_stubDispatchOpen_LOADING(): void
		{
			_timer.addEventListener(TimerEvent.TIMER_COMPLETE,
									Async.asyncHandler(this, timerCompleteHandler, 100,
														{loader:_loader, expectedStatus:AssetLoaderStatus.LOADING},
														timerTimeoutHandler),
									false, 0, true);
			
			_loader.load();
			_fileLoader.asyncDispatchEvent(new Event(Event.OPEN));
			_timer.start();
		}
		
		[Test(async)]
		public function load_stubDispatchComplete_COMPLETE(): void
		{
			_timer.addEventListener(TimerEvent.TIMER_COMPLETE,
									Async.asyncHandler(this, timerCompleteHandler, 100,
														{loader:_loader, expectedStatus:AssetLoaderStatus.COMPLETE},
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
									Async.asyncHandler(this, timerCompleteHandler, 100,
														{loader:_loader, expectedStatus:AssetLoaderStatus.FAILED},
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
									Async.asyncHandler(this, timerCompleteHandler, 100,
														{loader:_loader, expectedStatus:AssetLoaderStatus.FAILED},
														timerTimeoutHandler),
									false, 0, true);
			
			_loader.load();
			_fileLoader.asyncDispatchEvent(new SecurityErrorEvent(SecurityErrorEvent.SECURITY_ERROR));
			_timer.start();
		}
		
		public function timerCompleteHandler(event:TimerEvent, passThroughData:Object):void
		{
			Assert.assertEquals(passThroughData["expectedStatus"], passThroughData["loader"]["status"]);
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
		
	}

}