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
	import org.flexunit.async.Async;
	import org.vostokframework.assetmanagement.AssetLoadingPriority;
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
	[TestCase(order=999)]
	public class AssetLoaderTests
	{
		[Rule]
		public var mocks:MockolateRule = new MockolateRule();
		
		[Mock(type="strict",inject="false")]
		public var _fileLoaderMockolate:IFileLoader;
		
		private var _fileLoader:VostokLoaderStub;
		private var _loader:AssetLoader;
		private var _loader2:AssetLoader;
		private var _timer:Timer;
		
		public function AssetLoaderTests()
		{
			
		}
		
		/////////////////////////
		// TESTS CONFIGURATION //
		/////////////////////////
		
		[Before]
		public function setUp(): void
		{
			_timer = new Timer(500, 1);
			
			var settings:LoadingAssetSettings = new LoadingAssetSettings(new LoadingAssetPolicySettings(3));
			_fileLoader = new VostokLoaderStub();
			_loader = new AssetLoader("asset-loader", AssetLoadingPriority.MEDIUM, _fileLoader, settings);
			
			_fileLoaderMockolate = strict(IFileLoader);
			stub(_fileLoaderMockolate).decorate(IFileLoader, EventDispatcherDecorator);
			//stub(_fileLoaderMockolate).method("addEventListener").answers(new MethodInvokingAnswer(target, methodName));
			//stub(_fileLoaderMockolate).method("addEventListener");
			//stub(_fileLoaderMockolate).method("removeEventListener");
			
			_loader2 = new AssetLoader("asset-loader", AssetLoadingPriority.MEDIUM, _fileLoaderMockolate, settings);
		}
		
		[After]
		public function tearDown(): void
		{
			_timer.stop();
			_timer = null;
			_fileLoader = null;
			_loader = null;
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
		// AbstractAssetLoader().load() //
		//////////////////////////////////
		
		[Test]
		public function load_simpleCallOnFreshObject_ReturnsTrue(): void
		{
			var allowedLoading:Boolean = _loader.load();
			Assert.assertTrue(allowedLoading);
		}
		
		[Test]
		public function load_checkIfMockWasCalled_Void(): void
		{
			mock(_fileLoaderMockolate).method("load");
			_loader2.load();
			verify(_fileLoaderMockolate);
		}
		[Ignore]
		[Test]
		public function load_mockDispatchesOpen_checkIfStatusIs_LOADING_ReturnsTrue(): void
		{
			stub(_fileLoaderMockolate).method("load").dispatches(new Event(Event.OPEN));
			_loader2.load();
			
			Assert.assertEquals(AssetLoaderStatus.LOADING, _loader2.status);
		}
		
		[Ignore]
		[Test(order=999)]
		public function testEventDispacther(): void
		{
			//_fileLoaderMockolate.addEventListener(Event.OPEN, testHandler);
			//trace("_fileLoaderMockolate.hasEventListener(Event.OPEN): " + _fileLoaderMockolate.hasEventListener(Event.OPEN));
			//_fileLoaderMockolate.dispatchEvent(new Event(Event.OPEN));
			
			mock(_fileLoaderMockolate).method("load").dispatches(new Event(Event.OPEN));
			_loader2.load();
			
			trace("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX");
			trace("_fileLoaderMockolate.hasEventListener(Event.OPEN): " + _fileLoaderMockolate.hasEventListener(Event.OPEN));
			trace("_loader2.historicalStatus: " + _loader2.historicalStatus);
			
			Assert.assertEquals(AssetLoaderStatus.LOADING, _loader2.status);
		}
		
		private function testHandler(event:Event):void
		{
			trace("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX");
			trace("testHandler()");
		}
		
		[Test(expects="flash.errors.IllegalOperationError")]
		public function load_doubleCall_ThrowsError(): void
		{
			_loader.load();
			_loader.load();
		}
		
		[Test]
		public function loadStressTest_validCallSequence_checkIfStatusIs_TRYING_TO_CONNECT_ReturnsTrue(): void
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
		/*
		[Test]
		public function loadStressTest_validCallSequence2_checkIfStatusIs_TRYING_TO_CONNECT_ReturnsTrue(): void
		{
			var seq:Sequence = sequence();
			
			mock(_fileLoaderMockolate).method("load").dispatches(new Event(Event.OPEN))
				.dispatches(new IOErrorEvent(IOErrorEvent.IO_ERROR, false, false, "mockolate IO ERROR")).ordered(seq);
			
			_loader2.load();
			//_loader2.load();
			Assert.assertEquals(AssetLoaderStatus.TRYING_TO_CONNECT, _loader2.status);
		}
		*/
		/*
		[Test]
		public function loadStressTest_validCallSequence2_checkIfStatusIs_TRYING_TO_CONNECT_ReturnsTrue(): void
		{
			var seq:Sequence = sequence();
			
			mock(_fileLoaderMockolate).method("load").dispatches(new Event(Event.OPEN))
				.dispatches(new IOErrorEvent(IOErrorEvent.IO_ERROR)).ordered(seq);
			
			mock(_fileLoaderMockolate).method("load").dispatches(new Event(Event.OPEN))
				.dispatches(new IOErrorEvent(IOErrorEvent.IO_ERROR)).ordered(seq);
			
			mock(_fileLoaderMockolate).method("load").dispatches(new Event(Event.OPEN)).ordered(seq);
			mock(_fileLoaderMockolate).method("stop").dispatches(new FileLoaderEvent(FileLoaderEvent.STOPPED)).ordered(seq);
			mock(_fileLoaderMockolate).method("load").dispatches(new Event(Event.OPEN)).ordered(seq);
			
			_loader2.load();
			//_fileLoader.dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR));
			_loader2.load();
			//_fileLoader.dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR));
			_loader2.load();
			_loader2.stop();
			_loader2.load();
			
			Assert.assertEquals(AssetLoaderStatus.TRYING_TO_CONNECT, _loader2.status);
		}
		*/
		[Test(expects="flash.errors.IllegalOperationError")]
		public function loadStressTest_invalidCallSequence_ThrowsError(): void
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
		
		[Test(async)]
		public function load_expectsForEvent_checkIfStatusOfEventObjectIs_TRYING_TO_CONNECT_ReturnsTrue(): void
		{
			_loader.addEventListener(AssetLoaderEvent.STATUS_CHANGED,
									Async.asyncHandler(this, assetLoaderEventHandler, 500,
														{propertyName:"status", propertyValue:AssetLoaderStatus.TRYING_TO_CONNECT},
														timeoutHandler),
									false, 0, true);
			
			_loader.load();
		}
		
		[Test(async)]
		public function load_stubDispatchOpen_LOADING(): void
		{
			_fileLoader.addEventListener(Event.OPEN,
									Async.asyncHandler(this, eventHandler, 500,
														{propertyName:"status", propertyValue:AssetLoaderStatus.LOADING},
														timeoutHandler),
									false, -999, true);
			
			_fileLoader.asyncDispatchEvent(new Event(Event.OPEN), 50);
			_loader.load();
		}
		
		[Test(async)]
		public function load_stubDispatchComplete_COMPLETE(): void
		{
			_fileLoader.addEventListener(FileLoaderEvent.COMPLETE,
									Async.asyncHandler(this, eventHandler, 500,
														{propertyName:"status", propertyValue:AssetLoaderStatus.COMPLETE},
														timeoutHandler),
									false, -999, true);
			
			_fileLoader.asyncDispatchEvent(new Event(Event.OPEN), 50);
			_fileLoader.asyncDispatchEvent(new FileLoaderEvent(FileLoaderEvent.COMPLETE, null), 100);
			_loader.load();
		}
		
		[Test(async)]
		public function load_stubDispatchIOError_FAILED(): void
		{
			_fileLoader.addEventListener(IOErrorEvent.IO_ERROR,
									Async.asyncHandler(this, eventHandler, 500,
														{propertyName:"status", propertyValue:AssetLoaderStatus.FAILED_IO_ERROR},
														timeoutHandler),
									false, -999, true);
			
			_fileLoader.asyncDispatchEvent(new Event(Event.OPEN), 50);
			_fileLoader.asyncDispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR), 100);
			_loader.load();
		}
		
		[Test(async)]
		public function load_stubDispatchSecurityError_FAILED(): void
		{
			_fileLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR,
									Async.asyncHandler(this, eventHandler, 500,
														{propertyName:"status", propertyValue:AssetLoaderStatus.FAILED_SECURITY_ERROR},
														timeoutHandler),
									false, -999, true);
			
			_fileLoader.asyncDispatchEvent(new Event(Event.OPEN), 50);
			_fileLoader.asyncDispatchEvent(new SecurityErrorEvent(SecurityErrorEvent.SECURITY_ERROR), 100);
			_loader.load();
		}
		
		[Test(async)]
		public function loadStressTest_validSequence_LOADING(): void
		{
			_loader.load();
			_fileLoader.asyncDispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR), 50);
			setTimeout(_loader.load, 100);
			_fileLoader.asyncDispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR), 150);
			setTimeout(_loader.load, 200);
			
			_timer.addEventListener(TimerEvent.TIMER_COMPLETE,
									Async.asyncHandler(this, eventHandler, 500,
														{propertyName:"status", propertyValue:AssetLoaderStatus.TRYING_TO_CONNECT},
														timeoutHandler),
									false, 0, true);
			
			_timer.start();
		}
		
		[Test(async)]
		public function loadStressTest_validSequence_FAILED_EXHAUSTED_ATTEMPTS(): void
		{
			_loader.load();
			_fileLoader.asyncDispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR), 50);
			setTimeout(_loader.load, 100);
			_fileLoader.asyncDispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR), 150);
			setTimeout(_loader.load, 200);
			_fileLoader.asyncDispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR), 250);
			setTimeout(_loader.load, 300);
			
			_timer.addEventListener(TimerEvent.TIMER_COMPLETE,
									Async.asyncHandler(this, eventHandler, 500,
														{propertyName:"status", propertyValue:AssetLoaderStatus.FAILED_EXHAUSTED_ATTEMPTS},
														timeoutHandler),
									false, 0, true);
			
			_timer.start();
		}
		
		public function eventHandler(event:Event, passThroughData:Object):void
		{
			Assert.assertEquals(passThroughData["propertyValue"], _loader[passThroughData["propertyName"]]);
		}
		
		public function assetLoaderEventHandler(event:AssetLoaderEvent, passThroughData:Object):void
		{
			Assert.assertEquals(passThroughData["propertyValue"], event[passThroughData["propertyName"]]);
		}
		
		public function timeoutHandler(passThroughData:Object):void
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