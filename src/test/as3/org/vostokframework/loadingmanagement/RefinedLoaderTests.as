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
	import org.flexunit.Assert;
	import org.flexunit.async.Async;
	import org.vostokframework.loadingmanagement.events.LoaderEvent;

	import flash.events.Event;

	/**
	 * @author Flávio Silva
	 */
	[TestCase(order=999)]
	public class RefinedLoaderTests
	{
		public var _loader:RefinedLoader;
		
		public function RefinedLoaderTests()
		{
			
		}
		
		/////////////////////////
		// TESTS CONFIGURATION //
		/////////////////////////
		
		[Before]
		public function setUp(): void
		{
			_loader = getLoader();
		}
		
		[After]
		public function tearDown(): void
		{
			_loader = null;
		}
		
		////////////////////
		// HELPER METHODS //
		////////////////////
		
		public function getLoader():RefinedLoader
		{
			return new StubRefinedLoader("id", 3);
		}
		
		///////////////////////////////
		// ASYNC TESTS CONFIGURATION //
		///////////////////////////////
		
		public function validateLoaderPropertyEventHandler(event:Event, passThroughData:Object):void
		{
			Assert.assertEquals(passThroughData["propertyValue"], _loader[passThroughData["propertyName"]]);
		}
		
		public function asyncTimeoutHandler(passThroughData:Object):void
		{
			trace("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX");
			trace("asyncTimeoutHandler() - _loader.statusHistory: " + _loader.statusHistory);
			trace("asyncTimeoutHandler() - _loader.errorHistory: " + _loader.errorHistory);
			
			Assert.fail("Asynchronous Test Failed: Timeout");
			passThroughData = null;
		}
		
		///////////////////////
		// CONSTRUCTOR TESTS //
		///////////////////////
		
		
		
		////////////////////////////
		// RefinedLoader().status //
		////////////////////////////
		
		[Test]
		public function status_freshObject_checkIfStatusIsQueued_ReturnsTrue(): void
		{
			Assert.assertEquals(LoaderStatus.QUEUED, _loader.status);
		}
		
		[Test]
		public function status_afterCallLoad_checkIfStatusIsTryingToConnect_ReturnsTrue(): void
		{
			_loader.load();
			Assert.assertEquals(LoaderStatus.CONNECTING, _loader.status);
		}
		
		///////////////////////////////////
		// RefinedLoader().statusHistory //
		///////////////////////////////////
		
		[Test]
		public function statusHistory_freshObject_checkIfFirstElementIsQueued_ReturnsTrue(): void
		{
			Assert.assertEquals(LoaderStatus.QUEUED, _loader.statusHistory.getAt(0));
		}
		
		[Test]
		public function statusHistory_afterCallLoad_checkIfSecondElementIsTryingToConnect_ReturnsTrue(): void
		{
			_loader.load();
			Assert.assertEquals(LoaderStatus.CONNECTING, _loader.statusHistory.getAt(1));
		}
		
		//////////////////////////////
		// RefinedLoader().cancel() //
		//////////////////////////////
		
		[Test]
		public function cancel_simpleCall_checkIfStatusIsCanceled_ReturnsTrue(): void
		{
			_loader.cancel();
			Assert.assertEquals(LoaderStatus.CANCELED, _loader.status);
		}
		
		[Test]
		public function cancel_doubleCall_checkIfStatusIsCanceled_ReturnsTrue(): void
		{
			_loader.cancel();
			_loader.cancel();
			Assert.assertEquals(LoaderStatus.CANCELED, _loader.status);
		}
		
		[Test(async)]
		public function cancel_simpleCall_waitCanceledLoaderEvent(): void
		{
			Async.proceedOnEvent(this, _loader, LoaderEvent.CANCELED, 50, asyncTimeoutHandler);
			_loader.cancel();
		}
		
		////////////////////////////
		// RefinedLoader().load() //
		////////////////////////////
		
		[Test]
		public function load_simpleCall_checkIfStatusIsTryingToConnect_ReturnsTrue(): void
		{
			_loader.load();
			Assert.assertEquals(LoaderStatus.CONNECTING, _loader.status);
		}
		
		[Test(expects="flash.errors.IllegalOperationError")]
		public function load_doubleCall_ThrowsError(): void
		{
			_loader.load();
			_loader.load();
		}
		
		[Test(async)]
		public function load_simpleCall_waitTryingToConnectLoaderEvent(): void
		{
			Async.proceedOnEvent(this, _loader, LoaderEvent.CONNECTING, 50, asyncTimeoutHandler);
			_loader.load();
		}
		
		////////////////////////////
		// RefinedLoader().stop() //
		////////////////////////////
		
		[Test]
		public function stop_simpleCall_checkIfStatusIsStopped_ReturnsTrue(): void
		{
			_loader.stop();
			Assert.assertEquals(LoaderStatus.STOPPED, _loader.status);
		}
		
		[Test]
		public function stop_doubleCall_checkIfStatusIsStopped_ReturnsTrue(): void
		{
			_loader.stop();
			_loader.stop();
			Assert.assertEquals(LoaderStatus.STOPPED, _loader.status);
		}
		
		[Test(async)]
		public function stop_simpleCall_waitStoppedLoaderEvent(): void
		{
			Async.proceedOnEvent(this, _loader, LoaderEvent.STOPPED, 50, asyncTimeoutHandler);
			_loader.stop();
		}
		
		//////////////////////////////////////////////////////////
		// RefinedLoader().stop()-load()-cancel() - MIXED TESTS //
		//////////////////////////////////////////////////////////
		
		[Test]
		public function loadAndStop_checkIfStatusIsStopped_ReturnsTrue(): void
		{
			_loader.load();
			_loader.stop();
			Assert.assertEquals(LoaderStatus.STOPPED, _loader.status);
		}
		
		[Test]
		public function stopAndLoad_checkIfStatusIsTryingToConnect_ReturnsTrue(): void
		{
			_loader.stop();
			_loader.load();
			Assert.assertEquals(LoaderStatus.CONNECTING, _loader.status);
		}
		
		[Test]
		public function loadAndCancel_checkIfStatusIsCanceled_ReturnsTrue(): void
		{
			_loader.load();
			_loader.cancel();
			Assert.assertEquals(LoaderStatus.CANCELED, _loader.status);
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
		public function loadAndStopAndLoad_checkIfStatusIsTryingToConnect_ReturnsTrue(): void
		{
			_loader.load();
			_loader.stop();
			_loader.load();
			Assert.assertEquals(LoaderStatus.CONNECTING, _loader.status);
		}
		
		[Test]
		public function stopAndLoadAndStop_checkIfStatusIsStopped_ReturnsTrue(): void
		{
			_loader.stop();
			_loader.load();
			_loader.stop();
			Assert.assertEquals(LoaderStatus.STOPPED, _loader.status);
		}
		
		[Test]
		public function loadAndStopAndLoadAndStop_checkIfStatusIsStopped_ReturnsTrue(): void
		{
			_loader.load();
			_loader.stop();
			_loader.load();
			_loader.stop();
			Assert.assertEquals(LoaderStatus.STOPPED, _loader.status);
		}
		
		[Test]
		public function loadAndStopAndCancel_checkIfStatusIsCanceled_ReturnsTrue(): void
		{
			_loader.load();
			_loader.stop();
			_loader.cancel();
			Assert.assertEquals(LoaderStatus.CANCELED, _loader.status);
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