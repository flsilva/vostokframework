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

	/**
	 * @author Flávio Silva
	 */
	[TestCase(order=999)]
	public class RefinedLoaderTests
	{
		public var _fakeLoader:RefinedLoader;
		
		public function RefinedLoaderTests()
		{
			
		}
		
		/////////////////////////
		// TESTS CONFIGURATION //
		/////////////////////////
		
		[Before]
		public function setUp(): void
		{
			_fakeLoader = getLoader();
		}
		
		[After]
		public function tearDown(): void
		{
			_fakeLoader = null;
		}
		
		////////////////////
		// HELPER METHODS //
		////////////////////
		
		public function getLoader():RefinedLoader
		{
			return new StubRefinedLoader("id");
		}
		
		///////////////////////////////
		// ASYNC TESTS CONFIGURATION //
		///////////////////////////////
		
		public function eventHandler(event:LoaderEvent, passThroughData:Object):void
		{
			Assert.assertEquals(passThroughData["propertyValue"], event[passThroughData["propertyName"]]);
		}
		
		public function timeoutHandler(passThroughData:Object):void
		{
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
		public function status_freshObject_checkIfStatusIs_QUEUED_ReturnsTrue(): void
		{
			Assert.assertEquals(LoaderStatus.QUEUED, _fakeLoader.status);
		}
		
		[Test]
		public function status_afterCallLoad_checkIfStatusIs_TRYING_TO_CONNECT_ReturnsTrue(): void
		{
			_fakeLoader.load();
			Assert.assertEquals(LoaderStatus.TRYING_TO_CONNECT, _fakeLoader.status);
		}
		
		///////////////////////////////////
		// RefinedLoader().statusHistory //
		///////////////////////////////////
		
		[Test]
		public function statusHistory_freshObject_checkIfFirstElementIs_QUEUED_ReturnsTrue(): void
		{
			Assert.assertEquals(LoaderStatus.QUEUED, _fakeLoader.statusHistory.getAt(0));
		}
		
		[Test]
		public function statusHistory_afterCallLoad_checkIfSecondElementIs_TRYING_TO_CONNECT_ReturnsTrue(): void
		{
			_fakeLoader.load();
			Assert.assertEquals(LoaderStatus.TRYING_TO_CONNECT, _fakeLoader.statusHistory.getAt(1));
		}
		
		//////////////////////////////
		// RefinedLoader().cancel() //
		//////////////////////////////
		
		[Test]
		public function cancel_checkIfStatusIs_CANCELED_ReturnsTrue(): void
		{
			_fakeLoader.cancel();
			Assert.assertEquals(LoaderStatus.CANCELED, _fakeLoader.status);
		}
		
		[Test]
		public function cancel_doubleCall_checkIfStatusIs_CANCELED_ReturnsTrue(): void
		{
			_fakeLoader.cancel();
			_fakeLoader.cancel();
			Assert.assertEquals(LoaderStatus.CANCELED, _fakeLoader.status);
		}
		
		[Test(async)]
		public function cancel_expectsForLoaderStatusEvent_checkIfStatusOfEventIs_CANCELED_ReturnsTrue(): void
		{
			_fakeLoader.addEventListener(LoaderEvent.STATUS_CHANGED,
									Async.asyncHandler(this, eventHandler, 500,
														{propertyName:"status", propertyValue:LoaderStatus.CANCELED},
														timeoutHandler),
									false, 0, true);
			
			_fakeLoader.cancel();
		}
		
		////////////////////////////
		// RefinedLoader().load() //
		////////////////////////////
		
		[Test]
		public function load_checkIfStatusIs_TRYING_TO_CONNECT_ReturnsTrue(): void
		{
			_fakeLoader.load();
			Assert.assertEquals(LoaderStatus.TRYING_TO_CONNECT, _fakeLoader.status);
		}
		
		[Test(expects="flash.errors.IllegalOperationError")]
		public function load_doubleCall_ThrowsError(): void
		{
			_fakeLoader.load();
			_fakeLoader.load();
		}
		
		[Test(async)]
		public function load_expectsForLoaderStatusEvent_checkIfStatusOfEventIs_TRYING_TO_CONNECT_ReturnsTrue(): void
		{
			_fakeLoader.addEventListener(LoaderEvent.STATUS_CHANGED,
									Async.asyncHandler(this, eventHandler, 500,
														{propertyName:"status", propertyValue:LoaderStatus.TRYING_TO_CONNECT},
														timeoutHandler),
									false, 0, true);
			
			_fakeLoader.load();
		}
		
		////////////////////////////
		// RefinedLoader().stop() //
		////////////////////////////
		
		[Test]
		public function stop_checkStatus_STOPPED(): void
		{
			_fakeLoader.stop();
			Assert.assertEquals(LoaderStatus.STOPPED, _fakeLoader.status);
		}
		
		[Test]
		public function stop_doubleCallCheckStatus_STOPPED(): void
		{
			_fakeLoader.stop();
			_fakeLoader.stop();
			Assert.assertEquals(LoaderStatus.STOPPED, _fakeLoader.status);
		}
		
		[Test(async)]
		public function stop_expectsForLoaderStatusEvent_checkIfStatusOfEventIs_STOPPED_ReturnsTrue(): void
		{
			_fakeLoader.addEventListener(LoaderEvent.STATUS_CHANGED,
									Async.asyncHandler(this, eventHandler, 500,
														{propertyName:"status", propertyValue:LoaderStatus.STOPPED},
														timeoutHandler),
									false, 0, true);
			
			_fakeLoader.stop();
		}
		
		//////////////////////////////////////////////////////////
		// RefinedLoader().stop()-load()-cancel() - MIXED TESTS //
		//////////////////////////////////////////////////////////
		
		[Test]
		public function loadAndStop_CheckStatus_STOPPED(): void
		{
			_fakeLoader.load();
			_fakeLoader.stop();
			Assert.assertEquals(LoaderStatus.STOPPED, _fakeLoader.status);
		}
		
		[Test]
		public function stopAndLoad_CheckStatus_TRYING_TO_CONNECT(): void
		{
			_fakeLoader.stop();
			_fakeLoader.load();
			Assert.assertEquals(LoaderStatus.TRYING_TO_CONNECT, _fakeLoader.status);
		}
		
		[Test]
		public function loadAndCancel_CheckStatus_CANCELED(): void
		{
			_fakeLoader.load();
			_fakeLoader.cancel();
			Assert.assertEquals(LoaderStatus.CANCELED, _fakeLoader.status);
		}
		
		[Test(expects="flash.errors.IllegalOperationError")]
		public function loadAndCancelAndLoad_illegalOperation_ThrowsError(): void
		{
			_fakeLoader.load();
			_fakeLoader.cancel();
			_fakeLoader.load();
		}
		
		[Test(expects="flash.errors.IllegalOperationError")]
		public function cancelAndLoad_illegalOperation_ThrowsError(): void
		{
			_fakeLoader.cancel();
			_fakeLoader.load();
		}
		
		[Test]
		public function loadAndStopAndLoad_CheckStatus_TRYING_TO_CONNECT(): void
		{
			_fakeLoader.load();
			_fakeLoader.stop();
			_fakeLoader.load();
			Assert.assertEquals(LoaderStatus.TRYING_TO_CONNECT, _fakeLoader.status);
		}
		
		[Test]
		public function stopAndLoadAndStop_CheckStatus_STOPPED(): void
		{
			_fakeLoader.stop();
			_fakeLoader.load();
			_fakeLoader.stop();
			Assert.assertEquals(LoaderStatus.STOPPED, _fakeLoader.status);
		}
		
		[Test]
		public function loadAndStopAndLoadAndStop_CheckStatus_STOPPED(): void
		{
			_fakeLoader.load();
			_fakeLoader.stop();
			_fakeLoader.load();
			_fakeLoader.stop();
			Assert.assertEquals(LoaderStatus.STOPPED, _fakeLoader.status);
		}
		
		[Test]
		public function loadAndStopAndCancel_CheckStatus_CANCELED(): void
		{
			_fakeLoader.load();
			_fakeLoader.stop();
			_fakeLoader.cancel();
			Assert.assertEquals(LoaderStatus.CANCELED, _fakeLoader.status);
		}
		
		[Test(expects="flash.errors.IllegalOperationError")]
		public function loadAndStopAndCancelAndLoad_illegalOperation_ThrowsError(): void
		{
			_fakeLoader.load();
			_fakeLoader.stop();
			_fakeLoader.cancel();
			_fakeLoader.load();
		}
		
	}

}