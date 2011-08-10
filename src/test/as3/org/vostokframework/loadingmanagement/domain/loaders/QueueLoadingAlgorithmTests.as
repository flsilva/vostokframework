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

package org.vostokframework.loadingmanagement.domain.loaders
{
	import mockolate.ingredients.Sequence;
	import mockolate.mock;
	import mockolate.nice;
	import mockolate.runner.MockolateRule;
	import mockolate.sequence;
	import mockolate.stub;
	import mockolate.verify;

	import org.flexunit.Assert;
	import org.flexunit.async.Async;
	import org.vostokframework.VostokFramework;
	import org.vostokframework.VostokIdentification;
	import org.vostokframework.loadingmanagement.LoadingManagementContext;
	import org.vostokframework.loadingmanagement.domain.LoadPriority;
	import org.vostokframework.loadingmanagement.domain.LoaderRepository;
	import org.vostokframework.loadingmanagement.domain.VostokLoader;
	import org.vostokframework.loadingmanagement.domain.events.LoaderEvent;
	import org.vostokframework.loadingmanagement.domain.events.LoadingAlgorithmEvent;
	import org.vostokframework.loadingmanagement.domain.loaders.states.LoaderQueued;
	import org.vostokframework.loadingmanagement.domain.policies.ILoadingPolicy;
	import org.vostokframework.loadingmanagement.domain.policies.LoadingPolicy;

	import flash.utils.Timer;

	/**
	 * @author Flávio Silva
	 */
	[TestCase]
	public class QueueLoadingAlgorithmTests
	{
		private static const LOADER_LOCALE:String = VostokFramework.CROSS_LOCALE_ID;
		
		[Rule]
		public var mocks:MockolateRule = new MockolateRule();
		
		[Mock(inject="false")]
		public var _fakePolicy:ILoadingPolicy;
		
		[Mock(inject="false")]
		public var fakeAlgorithm:LoadingAlgorithm;
		
		[Mock(inject="false")]
		public var _fakeLoader1:VostokLoader;
		
		[Mock(inject="false")]
		public var _fakeLoader2:VostokLoader;
		
		public var algorithm:LoadingAlgorithm;
		
		private var _timer:Timer;
		
		public function QueueLoadingAlgorithmTests()
		{
			
		}
		
		/////////////////////////
		// TESTS CONFIGURATION //
		/////////////////////////
		
		[Before]
		public function setUp(): void
		{
			_timer = new Timer(500, 1);
			
			algorithm = getLoadingAlgorithm();
		}
		
		[After]
		public function tearDown(): void
		{
			_timer.stop();
			
			_fakePolicy = null;
			_fakeLoader1 = null;
			_fakeLoader2 = null;
			algorithm = null;
			_timer = null;
		}
		
		////////////////////
		// HELPER METHODS //
		////////////////////
		
		public function getLoadingAlgorithm():LoadingAlgorithm
		{
			_fakePolicy = nice(ILoadingPolicy, null, [new LoaderRepository()]);
			//stub(_fakePolicy).getter("globalMaxConnections").returns(3);
			//stub(_fakePolicy).getter("localMaxConnections").returns(3);
			
			fakeAlgorithm = nice(LoadingAlgorithm);
			
			_fakeLoader1 = nice(VostokLoader, null, [new VostokIdentification("fake-loader-1", LOADER_LOCALE), fakeAlgorithm, LoadPriority.MEDIUM, 3]);
			_fakeLoader2 = nice(VostokLoader, null, [new VostokIdentification("fake-loader-2", LOADER_LOCALE), fakeAlgorithm, LoadPriority.LOW, 3]);
			
			stub(_fakeLoader1).asEventDispatcher();
			stub(_fakeLoader2).asEventDispatcher();
			
			stub(_fakeLoader1).getter("identification").returns(new VostokIdentification("fake-loader-1", LOADER_LOCALE));
			stub(_fakeLoader2).getter("identification").returns(new VostokIdentification("fake-loader-2", LOADER_LOCALE));
			
			stub(_fakeLoader1).getter("state").returns(LoaderQueued.INSTANCE);
			stub(_fakeLoader2).getter("state").returns(LoaderQueued.INSTANCE);
			
			/*
			stub(_fakeLoader1).method("cancel").calls(
				function():void
				{
					stub(_fakeLoader1).getter("state").returns(LoaderCanceled.INSTANCE);
				}
			);
			
			stub(_fakeLoader1).method("load").calls(
				function():void
				{
					stub(_fakeLoader1).getter("state").returns(LoaderConnecting.INSTANCE);
				}
			);
			
			stub(_fakeLoader1).method("stop").calls(
				function():void
				{
					stub(_fakeLoader1).getter("state").returns(LoaderStopped.INSTANCE);
				}
			);
			
			stub(_fakeLoader2).method("cancel").calls(
				function():void
				{
					stub(_fakeLoader2).getter("state").returns(LoaderCanceled.INSTANCE);
				}
			);
			
			stub(_fakeLoader2).method("load").calls(
				function():void
				{
					stub(_fakeLoader2).getter("state").returns(LoaderConnecting.INSTANCE);
				}
			);
			
			stub(_fakeLoader2).method("stop").calls(
				function():void
				{
					stub(_fakeLoader2).getter("state").returns(LoaderStopped.INSTANCE);
				}
			);
			*/
			return new QueueLoadingAlgorithm(_fakePolicy);
		}
		
		//////////////////////////////////////////////////////
		// QueueLoadingAlgorithm().addEventListener() TESTS //
		//////////////////////////////////////////////////////
		
		[Test(async, timeout=200)]
		public function addEventListener_stubLoaderDispatchesOpenEvent_mustCatchStubEventAndDispatchOwnOpenEvent(): void
		{
			Async.proceedOnEvent(this, algorithm, LoadingAlgorithmEvent.OPEN, 200);
			
			stub(_fakePolicy).method("getNext").returns(_fakeLoader1).once();
			stub(_fakeLoader1).method("load").dispatches(new LoaderEvent(LoaderEvent.OPEN), 50);
			
			algorithm.addLoader(_fakeLoader1);
			algorithm.load();
		}
		
		[Test(async, timeout=200)]
		public function addEventListener_stubLoaderDispatchesCompleteEvent_mustCatchStubEventThenCompletesLoadingAndThenDispatchOwnCompleteEvent(): void
		{
			// INTEGRATION TESTING USING REAL LoadingPolicy DEPENDENCY
			
			LoadingManagementContext.getInstance().setLoaderRepository(new LoaderRepository());
			
			var policy:ILoadingPolicy = new LoadingPolicy(LoadingManagementContext.getInstance().loaderRepository);
			policy.globalMaxConnections = LoadingManagementContext.getInstance().maxConcurrentConnections;
			policy.localMaxConnections = 3;
			
			var $algorithm:LoadingAlgorithm = new QueueLoadingAlgorithm(policy);
			
			Async.proceedOnEvent(this, $algorithm, LoadingAlgorithmEvent.COMPLETE, 200);
			stub(_fakeLoader1).method("load").dispatches(new LoaderEvent(LoaderEvent.COMPLETE), 50);
			
			$algorithm.addLoader(_fakeLoader1);
			$algorithm.load();
		}
		
		///////////////////////////////////////////////
		// QueueLoadingAlgorithm().addLoader() TESTS //
		///////////////////////////////////////////////
		
		[Test(expects="ArgumentError")]
		public function addLoader_invalidNullArgument_ThrowsError(): void
		{
			algorithm.addLoader(null);
		}
		
		[Test]
		public function addLoader_validArgument_Void(): void
		{
			algorithm.addLoader(_fakeLoader1);
		}
		
		[Test]
		public function addLoader_validArgument_checkIfMockPolicyWasCalled(): void
		{
			algorithm.load();
			
			mock(_fakePolicy).method("getNext");
			algorithm.addLoader(_fakeLoader2);//second call
			
			verify(_fakePolicy);
		}
		
		//TODO:addLoaders
		////////////////////////////////////////////
		// QueueLoadingAlgorithm().cancel() TESTS //
		////////////////////////////////////////////
		
		[Test]
		public function cancel_emptyQueue_Void(): void
		{
			algorithm.cancel();
		}
		
		[Test]
		public function cancel_notEmptyQueue_verifyIfMockLoaderWasCalled(): void
		{
			mock(_fakeLoader2).method("cancel");
			
			algorithm.addLoader(_fakeLoader1);
			algorithm.addLoader(_fakeLoader2);
			algorithm.cancel();
			
			verify(_fakeLoader2);
		}
		
		//////////////////////////////////////////////////
		// QueueLoadingAlgorithm().cancelLoader() TESTS //
		//////////////////////////////////////////////////
		
		[Test(expects="ArgumentError")]
		public function cancelLoader_invalidNullArgument_ThrowsError(): void
		{
			algorithm.cancelLoader(null);
		}
		
		[Test(expects="org.vostokframework.loadingmanagement.domain.errors.LoaderNotFoundError")]
		public function cancelLoader_notAddedLoader_ThrowsError(): void
		{
			algorithm.cancelLoader(new VostokIdentification("not-added-id", LOADER_LOCALE));
		}
		
		[Test]
		public function cancelLoader_addedLoader_verifyIfMockLoaderWasCalled(): void
		{
			mock(_fakeLoader1).method("cancel");
			
			algorithm.addLoader(_fakeLoader1);
			algorithm.addLoader(_fakeLoader2);
			algorithm.cancelLoader(new VostokIdentification("fake-loader-1", LOADER_LOCALE));
			
			verify(_fakeLoader1);
		}
		
		////////////////////////////////////////////////////
		// QueueLoadingAlgorithm().containsLoader() TESTS //
		////////////////////////////////////////////////////
		
		[Test(expects="ArgumentError")]
		public function containsLoader_invalidNullArgument_ThrowsError(): void
		{
			var containsLoader:Boolean = algorithm.containsLoader(null);
			Assert.assertFalse(containsLoader);
		}
		
		[Test]
		public function containsLoader_validArgument_notContainsLoader_ReturnsFalse(): void
		{
			var containsLoader:Boolean = algorithm.containsLoader(_fakeLoader1.identification);
			Assert.assertFalse(containsLoader);
		}
		
		[Test]
		public function containsLoader_validArgument_addLoaderAndCheckIfContains_ReturnsTrue(): void
		{
			algorithm.addLoader(_fakeLoader1);
			
			var containsLoader:Boolean = algorithm.containsLoader(_fakeLoader1.identification);
			Assert.assertTrue(containsLoader);
		}
		
		//////////////////////////////////////////
		// QueueLoadingAlgorithm().load)( TESTS //
		//////////////////////////////////////////
		
		[Test]
		public function load_verifyIfMockPolicyWasCalled(): void
		{
			mock(_fakePolicy).method("getNext");
			
			algorithm.addLoader(_fakeLoader1);
			algorithm.load();
			
			verify(_fakePolicy);
		}
		
		[Test]
		public function load_fakePolicyReturnsMockLoader_verifyIfMockLoaderWasCalled(): void
		{
			stub(_fakePolicy).method("getNext").returns(_fakeLoader1).once();
			mock(_fakeLoader1).method("load");
			
			algorithm.addLoader(_fakeLoader1);
			algorithm.load();
			
			verify(_fakeLoader1);
		}
		
		[Test]
		public function load_fakePolicyReturnsTwoMockLoaders_verifyIfSecondMockLoaderWasCalled(): void
		{
			var seq:Sequence = sequence();
			stub(_fakePolicy).method("getNext").returns(_fakeLoader1).once().ordered(seq);
			stub(_fakePolicy).method("getNext").returns(_fakeLoader2).once().ordered(seq);
			
			stub(_fakeLoader1).method("load").dispatches(new LoaderEvent(LoaderEvent.CONNECTING));
			mock(_fakeLoader2).method("load");
			
			algorithm.addLoader(_fakeLoader1);
			algorithm.addLoader(_fakeLoader2);
			algorithm.load();
			
			verify(_fakeLoader2);
		}
		
		//////////////////////////////////////////////////
		// QueueLoadingAlgorithm().resumeLoader() TESTS //
		//////////////////////////////////////////////////
		
		[Test(expects="ArgumentError")]
		public function resumeLoader_invalidNullArgument_ThrowsError(): void
		{
			algorithm.resumeLoader(null);
		}
		
		[Test(expects="org.vostokframework.loadingmanagement.domain.errors.LoaderNotFoundError")]
		public function resumeLoader_notAddedLoader_ThrowsError(): void
		{
			algorithm.resumeLoader(new VostokIdentification("not-added-id", LOADER_LOCALE));
		}
		
		[Test]
		public function resumeLoader_VerifyIfMockLoaderWasCalled(): void
		{
			stub(_fakePolicy).method("getNext").returns(_fakeLoader1).once();
			mock(_fakeLoader1).method("load").once();
			
			algorithm.addLoader(_fakeLoader1);
			algorithm.resumeLoader(new VostokIdentification("fake-loader-1", LOADER_LOCALE));
			
			verify(_fakePolicy);
		}
		
		//////////////////////////////////////////
		// QueueLoadingAlgorithm().stop() TESTS //
		//////////////////////////////////////////
		
		[Test]
		public function stop_emptyQueue_Void(): void
		{
			algorithm.stop();
		}
		
		[Test]
		public function stop_notEmptyQueue_verifyIfMockLoaderWasCalled(): void
		{
			mock(_fakeLoader2).method("stop");
			
			algorithm.addLoader(_fakeLoader1);
			algorithm.addLoader(_fakeLoader2);
			algorithm.stop();
			
			verify(_fakeLoader2);
		}
		
		////////////////////////////////////////////////
		// QueueLoadingAlgorithm().stopLoader() TESTS //
		////////////////////////////////////////////////
		
		[Test(expects="ArgumentError")]
		public function stopLoader_invalidNullArgument_ThrowsError(): void
		{
			algorithm.stopLoader(null);
		}
		
		[Test(expects="org.vostokframework.loadingmanagement.domain.errors.LoaderNotFoundError")]
		public function stopLoader_notAddedLoader_ThrowsError(): void
		{
			algorithm.stopLoader(new VostokIdentification("not-added-id", LOADER_LOCALE));
		}
		
		[Test]
		public function stopLoader_addedLoader_verifyIfMockLoaderWasCalled(): void
		{
			mock(_fakeLoader2).method("stop");
			
			algorithm.addLoader(_fakeLoader1);
			algorithm.addLoader(_fakeLoader2);
			algorithm.stopLoader(new VostokIdentification("fake-loader-2", LOADER_LOCALE));
			
			verify(_fakeLoader2);
		}
		
		//////////////////////////////////////////////////////////////////
		// QueueLoadingAlgorithm().stop()-load()-cancel() - MIXED TESTS //
		//////////////////////////////////////////////////////////////////
		
		[Test]
		public function loadAndStop_verifyIfSecondMockLoaderWasCalled(): void
		{
			mock(_fakeLoader2).method("stop");
			
			algorithm.addLoader(_fakeLoader1);
			algorithm.addLoader(_fakeLoader2);
			
			algorithm.load();
			algorithm.stop();
			
			verify(_fakeLoader2);
		}
		
		[Test]
		public function loadAndCancel_verifyIfFirstMockLoaderWasCalled(): void
		{
			mock(_fakeLoader1).method("cancel");
			
			algorithm.addLoader(_fakeLoader1);
			algorithm.addLoader(_fakeLoader2);
			
			algorithm.load();
			algorithm.cancel();
			
			verify(_fakeLoader1);
		}
		
		[Test]
		public function stopAndLoadAndStop_verifyIfSecondMockLoaderWasCalledTwice(): void
		{
			mock(_fakeLoader2).method("stop").twice();
			
			algorithm.addLoader(_fakeLoader1);
			algorithm.addLoader(_fakeLoader2);
			
			algorithm.stop();
			algorithm.load();
			algorithm.stop();
			
			verify(_fakeLoader2);
		}
		
		[Test]
		public function loadAndStopAndCancel_verifyIfSecondMockLoaderWasCalled(): void
		{
			mock(_fakeLoader2).method("cancel");
			
			algorithm.addLoader(_fakeLoader1);
			algorithm.addLoader(_fakeLoader2);
			
			algorithm.load();
			algorithm.stop();
			algorithm.cancel();
			
			verify(_fakeLoader2);
		}

		
	}

}