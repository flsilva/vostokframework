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

package org.vostokframework.loadingmanagement.domain
{
	import org.flexunit.Assert;
	import org.flexunit.async.Async;
	import org.vostokframework.loadingmanagement.domain.events.LoaderEvent;
	import org.vostokframework.loadingmanagement.domain.loaders.states.LoaderCanceled;
	import org.vostokframework.loadingmanagement.domain.loaders.states.LoaderConnecting;
	import org.vostokframework.loadingmanagement.domain.loaders.states.LoaderQueued;
	import org.vostokframework.loadingmanagement.domain.loaders.states.LoaderStopped;

	/**
	 * @author Flávio Silva
	 */
	[TestCase(order=9999999)]
	public class AbstractLoaderTests
	{
		public var _loader:AbstractLoader;
		
		public function AbstractLoaderTests()
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
		
		public function getLoader():AbstractLoader
		{
			return new StubAbstractLoader("id", 3);
		}
		
		///////////////////////////////
		// ASYNC TESTS CONFIGURATION //
		///////////////////////////////
		
		public function asyncTimeoutHandler(passThroughData:Object):void
		{
			Assert.fail("Asynchronous Test Failed: Timeout");
			passThroughData = null;
		}
		
		///////////////////////
		// CONSTRUCTOR TESTS //
		///////////////////////
		
		///////////////////////////////
		// StatefulLoader().priority //
		///////////////////////////////
		
		[Test]
		public function priority_setValidPriority_checkIfPriorityMatches_ReturnsTrue(): void
		{
			_loader.priority = 1;
			Assert.assertEquals(1, _loader.priority);
		}
		
		[Test(expects="ArgumentError")]
		public function priority_setInvalidLessPriority_ThrowsError(): void
		{
			_loader.priority = -1;
		}
		
		[Test(expects="ArgumentError")]
		public function priority_setInvalidGreaterPriority_ThrowsError(): void
		{
			_loader.priority = 5;
		}
		
		////////////////////////////
		// StatefulLoader().state //
		////////////////////////////
		
		[Test]
		public function state_freshObject_checkIfStatusIsQueued_ReturnsTrue(): void
		{
			Assert.assertEquals(LoaderQueued.INSTANCE, _loader.state);
		}
		
		////////////////////////////////////
		// StatefulLoader().stateHistory //
		////////////////////////////////////
		
		[Test]
		public function stateHistory_freshObject_checkIfFirstElementIsQueued_ReturnsTrue(): void
		{
			Assert.assertEquals(LoaderQueued.INSTANCE, _loader.stateHistory.getAt(0));
		}
		
		[Test(order=9999999)]
		public function stateHistory_afterCallLoad_checkIfSecondElementIsTryingToConnect_ReturnsTrue(): void
		{
			_loader.load();
			Assert.assertEquals(LoaderConnecting.INSTANCE, _loader.stateHistory.getAt(1));
		}
		
		///////////////////////////////
		// StatefulLoader().cancel() //
		///////////////////////////////
		
		[Test]
		public function cancel_simpleCall_checkIfStatusIsCanceled_ReturnsTrue(): void
		{
			_loader.cancel();
			Assert.assertEquals(LoaderCanceled.INSTANCE, _loader.state);
		}
		
		[Test]
		public function cancel_doubleCall_checkIfStatusIsCanceled_ReturnsTrue(): void
		{
			_loader.cancel();
			_loader.cancel();
			Assert.assertEquals(LoaderCanceled.INSTANCE, _loader.state);
		}
		
		[Test(async)]
		public function cancel_simpleCall_waitCanceledLoaderEvent(): void
		{
			Async.proceedOnEvent(this, _loader, LoaderEvent.CANCELED, 50, asyncTimeoutHandler);
			_loader.cancel();
		}
		
		/////////////////////////////
		// StatefulLoader().load() //
		/////////////////////////////
		
		[Test]
		public function load_simpleCall_checkIfStatusIsTryingToConnect_ReturnsTrue(): void
		{
			_loader.load();
			Assert.assertEquals(LoaderConnecting.INSTANCE, _loader.state);
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
		
		/////////////////////////////
		// StatefulLoader().stop() //
		/////////////////////////////
		
		[Test]
		public function stop_simpleCall_checkIfStatusIsStopped_ReturnsTrue(): void
		{
			_loader.stop();
			Assert.assertEquals(LoaderStopped.INSTANCE, _loader.state);
		}
		
		[Test]
		public function stop_doubleCall_checkIfStatusIsStopped_ReturnsTrue(): void
		{
			_loader.stop();
			_loader.stop();
			Assert.assertEquals(LoaderStopped.INSTANCE, _loader.state);
		}
		
		[Test(async)]
		public function stop_simpleCall_waitStoppedLoaderEvent(): void
		{
			Async.proceedOnEvent(this, _loader, LoaderEvent.STOPPED, 50, asyncTimeoutHandler);
			_loader.stop();
		}
		
		///////////////////////////////////////////////////////////
		// StatefulLoader().stop()-load()-cancel() - MIXED TESTS //
		///////////////////////////////////////////////////////////
		
		[Test]
		public function loadAndStop_checkIfStatusIsStopped_ReturnsTrue(): void
		{
			_loader.load();
			_loader.stop();
			Assert.assertEquals(LoaderStopped.INSTANCE, _loader.state);
		}
		
		[Test]
		public function stopAndLoad_checkIfStatusIsTryingToConnect_ReturnsTrue(): void
		{
			_loader.stop();
			_loader.load();
			Assert.assertEquals(LoaderConnecting.INSTANCE, _loader.state);
		}
		
		[Test]
		public function loadAndCancel_checkIfStatusIsCanceled_ReturnsTrue(): void
		{
			_loader.load();
			_loader.cancel();
			Assert.assertEquals(LoaderCanceled.INSTANCE, _loader.state);
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
			Assert.assertEquals(LoaderConnecting.INSTANCE, _loader.state);
		}
		
		[Test]
		public function stopAndLoadAndStop_checkIfStatusIsStopped_ReturnsTrue(): void
		{
			_loader.stop();
			_loader.load();
			_loader.stop();
			Assert.assertEquals(LoaderStopped.INSTANCE, _loader.state);
		}
		
		[Test]
		public function loadAndStopAndLoadAndStop_checkIfStatusIsStopped_ReturnsTrue(): void
		{
			_loader.load();
			_loader.stop();
			_loader.load();
			_loader.stop();
			Assert.assertEquals(LoaderStopped.INSTANCE, _loader.state);
		}
		
		[Test]
		public function loadAndStopAndCancel_checkIfStatusIsCanceled_ReturnsTrue(): void
		{
			_loader.load();
			_loader.stop();
			_loader.cancel();
			Assert.assertEquals(LoaderCanceled.INSTANCE, _loader.state);
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