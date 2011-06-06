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
	import mockolate.ingredients.Sequence;
	import mockolate.mock;
	import mockolate.nice;
	import mockolate.runner.MockolateRule;
	import mockolate.sequence;
	import mockolate.stub;

	import org.flexunit.async.Async;
	import org.vostokframework.loadingmanagement.events.LoaderEvent;

	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	/**
	 * @author Flávio Silva
	 */
	[TestCase(order=999)]
	public class AssetLoaderTests extends RefinedLoaderTests
	{
		[Rule]
		public var mocks:MockolateRule = new MockolateRule();
		
		[Mock(inject="false")]
		public var _fakeFileLoader:PlainLoader;
		
		private var _timer:Timer;
		
		public function AssetLoaderTests()
		{
			
		}
		
		/////////////////////////
		// TESTS CONFIGURATION //
		/////////////////////////
		
		[Before]
		override public function setUp(): void
		{
			_timer = new Timer(500, 1);
			
			super.setUp();
		}
		
		[After]
		override public function tearDown(): void
		{
			_timer.stop();
			
			_fakeFileLoader = null;
			_timer = null;
			
			super.tearDown();
		}
		
		////////////////////
		// HELPER METHODS //
		////////////////////
		
		override public function getLoader():RefinedLoader
		{
			_fakeFileLoader = nice(PlainLoader);
			return new AssetLoader("asset-loader", LoadPriority.MEDIUM, _fakeFileLoader, 3);
		}
		
		//////////////////////////////////
		// AbstractAssetLoader().load() //
		//////////////////////////////////
		
		[Test(async, timeout=2000)]
		public function load_stubDispatchesOpenEvent_waitForEvent(): void
		{
			stub(_fakeFileLoader).method("load").dispatches(new LoaderEvent(LoaderEvent.OPEN), 50);
			Async.proceedOnEvent(this, _loader, LoaderEvent.OPEN, 1000, asyncTimeoutHandler);
			_loader.load();
		}
		
		[Test(async, timeout=2000)]
		public function load_stubDispatchesIoErrorEvent_mustBeAbleToCatchStubEventThroughLoaderListener(): void
		{
			stub(_fakeFileLoader).method("load").dispatches(new IOErrorEvent(IOErrorEvent.IO_ERROR));
			
			//THIS LINE HAVE TO CAME AFTER THE PRECEDING
			//BECAUSE THE addEventListener BEHAVIOR OF THE STUB
			//WILL ONLY BE ADDED AFTER THE CALL TO ".dispatches"
			Async.proceedOnEvent(this, _loader, IOErrorEvent.IO_ERROR, 1000, asyncTimeoutHandler);
			_loader.load();
		}
		
		[Test(async, timeout=2000)]
		public function load_stubDispatchesCompleteLoaderEvent_waitForEvent(): void
		{
			stub(_fakeFileLoader).method("load").dispatches(new LoaderEvent(LoaderEvent.OPEN), 50)
				.dispatches(new LoaderEvent(LoaderEvent.COMPLETE), 100);
			
			Async.proceedOnEvent(this, _loader, LoaderEvent.COMPLETE, 1000, asyncTimeoutHandler);
			_loader.load();
		}
		
		[Test(async, timeout=2000)]
		public function load_stubDispatchesIoErrorTwiceAndOpenOnce_checkIfStatusIsLoading_ReturnsTrue(): void
		{
			var seq:Sequence = sequence();
			
			mock(_fakeFileLoader).method("load").dispatches(new IOErrorEvent(IOErrorEvent.IO_ERROR), 50).once().ordered(seq);
			mock(_fakeFileLoader).method("load").dispatches(new IOErrorEvent(IOErrorEvent.IO_ERROR), 50).once().ordered(seq);
			mock(_fakeFileLoader).method("load").dispatches(new LoaderEvent(LoaderEvent.OPEN), 50).once().ordered(seq);
			
			_loader.delayLoadAfterError = 50;
			_loader.load();
			
			_timer.delay = 1000;
			_timer.addEventListener(TimerEvent.TIMER_COMPLETE,
									Async.asyncHandler(this, validateLoaderPropertyEventHandler, 2000,
														{propertyName:"status", propertyValue:LoaderStatus.LOADING},
														asyncTimeoutHandler),
									false, 0, true);
			
			_timer.start();
		}
		
		[Test(async, timeout=2000)]
		public function load_stubDispatchesIoErrorTwiceOpenOnceAndCompleteOnce_checkIfStatusIsComplete_ReturnsTrue(): void
		{
			var seq:Sequence = sequence();
			
			mock(_fakeFileLoader).method("load").dispatches(new IOErrorEvent(IOErrorEvent.IO_ERROR), 50).once().ordered(seq);
			mock(_fakeFileLoader).method("load").dispatches(new IOErrorEvent(IOErrorEvent.IO_ERROR), 50).once().ordered(seq);
			mock(_fakeFileLoader).method("load").dispatches(new LoaderEvent(LoaderEvent.OPEN), 50)
				.dispatches(new LoaderEvent(LoaderEvent.COMPLETE), 100).once().ordered(seq);
			
			_loader.delayLoadAfterError = 50;
			_loader.load();
			
			_timer.delay = 1000;
			_timer.addEventListener(TimerEvent.TIMER_COMPLETE,
									Async.asyncHandler(this, validateLoaderPropertyEventHandler, 2000,
														{propertyName:"status", propertyValue:LoaderStatus.COMPLETE},
														asyncTimeoutHandler),
									false, 0, true);
			
			_timer.start();
		}
		
		[Test(async, timeout=2000)]
		public function load_stubDispatchesIoErrorThrice_waitForFailedLoaderEvent(): void
		{
			mock(_fakeFileLoader).method("load").dispatches(new IOErrorEvent(IOErrorEvent.IO_ERROR), 50).thrice();
			Async.proceedOnEvent(this, _loader, LoaderEvent.FAILED, 1000, asyncTimeoutHandler);
			
			_loader.delayLoadAfterError = 50;
			_loader.load();
		}
		
		[Test(async, timeout=2000)]
		public function load_stubDispatchesSecurityErrorOnce_waitForFailedLoaderEvent(): void
		{
			mock(_fakeFileLoader).method("load").dispatches(new SecurityErrorEvent(SecurityErrorEvent.SECURITY_ERROR), 50).once();
			Async.proceedOnEvent(this, _loader, LoaderEvent.FAILED, 1000, asyncTimeoutHandler);
			
			_loader.delayLoadAfterError = 50;
			_loader.load();
		}
		
	}

}