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
	import mockolate.decorations.EventDispatcherDecorator;
	import mockolate.ingredients.Sequence;
	import mockolate.mock;
	import mockolate.runner.MockolateRule;
	import mockolate.sequence;
	import mockolate.strict;
	import mockolate.stub;
	import mockolate.verify;

	import org.flexunit.Assert;
	import org.flexunit.async.Async;
	import org.vostokframework.assetmanagement.settings.LoadingAssetPolicySettings;
	import org.vostokframework.assetmanagement.settings.LoadingAssetSettings;
	import org.vostokframework.loadingmanagement.assetloaders.VostokLoaderStub;
	import org.vostokframework.loadingmanagement.events.FileLoaderEvent;
	import org.vostokframework.loadingmanagement.events.LoaderEvent;

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
		public var _fileLoaderMockolate:PlainLoader;
		
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
			_loader = new AssetLoader("asset-loader", LoadPriority.MEDIUM, _fileLoader, settings);
			
			_fileLoaderMockolate = strict(PlainLoader, null, ["id"]);
			//stub(_fileLoaderMockolate).decorate(PlainLoader, EventDispatcherDecorator);
			//stub(_fileLoaderMockolate).method("addEventListener").answers(new MethodInvokingAnswer(target, methodName));
			//stub(_fileLoaderMockolate).method("addEventListener");
			//stub(_fileLoaderMockolate).method("removeEventListener");
			
			_loader2 = new AssetLoader("asset-loader", LoadPriority.MEDIUM, _fileLoaderMockolate, settings);
		}
		
		[After]
		public function tearDown(): void
		{
			_timer.stop();
			_timer = null;
			_fileLoader = null;
			_fileLoaderMockolate = null;
			_loader = null;
			_loader2 = null;
		}
		
		//////////////////////////////////
		// AbstractAssetLoader().load() //
		//////////////////////////////////
		
		[Test]
		public function load_checkIfStatusIs_TRYING_TO_CONNECT_ReturnsTrue(): void
		{
			_loader.load();
			Assert.assertEquals(LoaderStatus.TRYING_TO_CONNECT, _loader.status);
		}
		
		[Test]
		public function load_checkIfMockWasCalled_Void(): void
		{
			mock(_fileLoaderMockolate).method("load").dispatches(new Event(Event.OPEN));
			_loader2.load();
			verify(_fileLoaderMockolate);
		}
		[Ignore]
		[Test]
		public function load_mockDispatchesOpen_checkIfStatusIs_LOADING_ReturnsTrue(): void
		{
			stub(_fileLoaderMockolate).method("load").dispatches(new Event(Event.OPEN));
			_loader2.load();
			
			Assert.assertEquals(LoaderStatus.LOADING, _loader2.status);
		}
		
		
		[Test]
		public function testEventDispacther(): void
		{
			mock(_fileLoaderMockolate).method("load").dispatches(new Event(Event.OPEN));
			_loader2.load();
			
			Assert.assertEquals(LoaderStatus.LOADING, _loader2.status);
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
			
			Assert.assertEquals(LoaderStatus.TRYING_TO_CONNECT, _loader.status);
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
			Assert.assertEquals(LoaderStatus.TRYING_TO_CONNECT, _loader2.status);
		}
		*/
		[Ignore]
		[Test(order=999)]
		public function loadStressTest_validCallSequence2_checkIfStatusIs_TRYING_TO_CONNECT_ReturnsTrue(): void
		{
			var seq:Sequence = sequence();
			
			mock(_fileLoaderMockolate).method("load").dispatches(new Event(Event.OPEN))
				.dispatches(new IOErrorEvent(IOErrorEvent.IO_ERROR)).ordered(seq);
			
			mock(_fileLoaderMockolate).method("load").dispatches(new Event(Event.OPEN))
				.dispatches(new IOErrorEvent(IOErrorEvent.IO_ERROR)).ordered(seq);
			
			mock(_fileLoaderMockolate).method("load").dispatches(new Event(Event.OPEN)).ordered(seq);
			//mock(_fileLoaderMockolate).method("stop").dispatches(new FileLoaderEvent(FileLoaderEvent.STOPPED)).ordered(seq);
			//mock(_fileLoaderMockolate).method("load").dispatches(new Event(Event.OPEN)).ordered(seq);
			
			//_loader2.load();
			//_fileLoader.dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR));
			//_loader2.load();
			//_fileLoader.dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR));
			//_loader2.load();
			//_loader2.stop();
			//_loader2.load();
			
			_fileLoaderMockolate.addEventListener(Event.OPEN, loadEventHandler);
			_fileLoaderMockolate.addEventListener(IOErrorEvent.IO_ERROR, ioErrorEventHandler);
			
			_fileLoaderMockolate.load();
			_fileLoaderMockolate.load();
			_fileLoaderMockolate.load();
			
			trace("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX");
			trace("_loader2.historicalStatus: " + _loader2.statusHistory);
			
			Assert.assertEquals(LoaderStatus.TRYING_TO_CONNECT, _loader2.status);
		}
		
		private function loadEventHandler(event:Event):void
		{
			trace("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX");
			trace("loadEventHandler()");
		}
		
		private function ioErrorEventHandler(event:Event):void
		{
			trace("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX");
			trace("ioErrorEventHandler()");
		}
		
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
			_loader.addEventListener(LoaderEvent.STATUS_CHANGED,
									Async.asyncHandler(this, assetLoaderEventHandler, 500,
														{propertyName:"status", propertyValue:LoaderStatus.TRYING_TO_CONNECT},
														timeoutHandler),
									false, 0, true);
			
			_loader.load();
		}
		
		[Test(async)]
		public function load_stubDispatchOpen_LOADING(): void
		{
			_fileLoader.addEventListener(Event.OPEN,
									Async.asyncHandler(this, eventHandler, 500,
														{propertyName:"status", propertyValue:LoaderStatus.LOADING},
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
														{propertyName:"status", propertyValue:LoaderStatus.COMPLETE},
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
														{propertyName:"status", propertyValue:LoaderStatus.FAILED_IO_ERROR},
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
														{propertyName:"status", propertyValue:LoaderStatus.FAILED_SECURITY_ERROR},
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
														{propertyName:"status", propertyValue:LoaderStatus.TRYING_TO_CONNECT},
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
														{propertyName:"status", propertyValue:LoaderStatus.FAILED_EXHAUSTED_ATTEMPTS},
														timeoutHandler),
									false, 0, true);
			
			_timer.start();
		}
		
		public function eventHandler(event:Event, passThroughData:Object):void
		{
			Assert.assertEquals(passThroughData["propertyValue"], _loader[passThroughData["propertyName"]]);
		}
		
		public function assetLoaderEventHandler(event:LoaderEvent, passThroughData:Object):void
		{
			Assert.assertEquals(passThroughData["propertyValue"], event[passThroughData["propertyName"]]);
		}
		
		public function timeoutHandler(passThroughData:Object):void
		{
			Assert.fail("Asynchronous Test Failed: Timeout");
			passThroughData = null;
		}
		
	}

}