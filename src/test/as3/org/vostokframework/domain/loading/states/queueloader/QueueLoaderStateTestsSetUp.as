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

package org.vostokframework.domain.loading.states.queueloader
{
	import mockolate.nice;
	import mockolate.runner.MockolateRule;
	import mockolate.stub;

	import org.as3coreaddendum.errors.UnsupportedOperationError;
	import org.as3utils.ReflectionUtil;
	import org.vostokframework.VostokFramework;
	import org.vostokframework.VostokIdentification;
	import org.vostokframework.application.LoadingContext;
	import org.vostokframework.domain.loading.GlobalLoadingSettings;
	import org.vostokframework.domain.loading.ILoader;
	import org.vostokframework.domain.loading.ILoaderState;
	import org.vostokframework.domain.loading.ILoaderStateTransition;
	import org.vostokframework.domain.loading.LoadPriority;
	import org.vostokframework.domain.loading.policies.ElaborateLoadingPolicy;
	import org.vostokframework.domain.loading.policies.ILoadingPolicy;
	import org.vostokframework.domain.loading.policies.LoadingPolicy;

	/**
	 * @author Flávio Silva
	 */
	[TestCase]
	public class QueueLoaderStateTestsSetUp
	{
		[Rule]
		public var mocks:MockolateRule = new MockolateRule();
		
		[Mock(inject="false")]
		public var fakePolicy:ILoadingPolicy;
		
		[Mock(inject="false")]
		public var fakeChildLoader1:ILoader;
		
		[Mock(inject="false")]
		public var fakeChildLoader2:ILoader;
		
		[Mock(inject="false")]
		public var fakeLoadingStatus:QueueLoadingStatus;
		
		[Mock(inject="false")]
		public var fakeQueueLoader:ILoaderStateTransition;
		
		public var state:ILoaderState;
		
		public function QueueLoaderStateTestsSetUp()
		{
			
		}
		
		/////////////////////////
		// TESTS CONFIGURATION //
		/////////////////////////
		
		[Before]
		public function setUp(): void
		{
			fakeChildLoader1 = getFakeLoader("fake-loader-1", 1);
			fakeChildLoader2 = getFakeLoader("fake-loader-2", 2);
			
			fakeLoadingStatus = new QueueLoadingStatus();
			fakePolicy = nice(ILoadingPolicy);
			
			fakeQueueLoader = nice(ILoaderStateTransition);
			stub(fakeQueueLoader).asEventDispatcher();
		}
		
		[After]
		public function tearDown(): void
		{
			fakeChildLoader1 = null;
			fakeChildLoader2 = null;
			fakeLoadingStatus = null;
			fakePolicy = null;
			state = null;
		}
		
		////////////////////
		// HELPER METHODS //
		////////////////////
		
		public function getFakeLoader(id:String, index:int, priority:LoadPriority = null):ILoader
		{
			if (!priority) priority = LoadPriority.MEDIUM;
			
			var fakeLoader:ILoader = nice(ILoader);
			
			stub(fakeLoader).asEventDispatcher();
			stub(fakeLoader).getter("identification").returns(new VostokIdentification(id, VostokFramework.CROSS_LOCALE_ID));
			stub(fakeLoader).getter("index").returns(index);
			stub(fakeLoader).getter("priority").returns(priority.ordinal);//LoadPriority.MEDIUM
			
			stub(fakeLoader).method("equals").callsWithArguments(
				function(other:*):Boolean
				{
					if (!(other is ILoader)) return false;
					var otherLoader:ILoader = other as ILoader;
					return fakeLoader.identification.equals(otherLoader.identification);
				}
			);
			
			stub(fakeLoader).method("toString").noArgs().returns("[MOCKOLATE ILoader <" + id + "> ]");
			
			return fakeLoader;
		}
		
		public function getState():ILoaderState
		{
			throw new UnsupportedOperationError("Method must be overridden in subclass: " + ReflectionUtil.getClassPath(this));
		}
		
		public function getLoadingPolicy(maxGlobalConcurrentConnections:int):ILoadingPolicy
		{
			var globalLoadingSettings:GlobalLoadingSettings = GlobalLoadingSettings.getInstance();
			globalLoadingSettings.maxConcurrentConnections = maxGlobalConcurrentConnections;
			
			var policy:ILoadingPolicy = new LoadingPolicy(LoadingContext.getInstance().loaderRepository, globalLoadingSettings);
			return policy;
		}
		
		public function getElaborateLoadingPolicy(maxGlobalConcurrentConnections:int):ILoadingPolicy
		{
			var globalLoadingSettings:GlobalLoadingSettings = GlobalLoadingSettings.getInstance();
			globalLoadingSettings.maxConcurrentConnections = maxGlobalConcurrentConnections;
			
			var policy:ILoadingPolicy = new ElaborateLoadingPolicy(LoadingContext.getInstance().loaderRepository, globalLoadingSettings);
			return policy;
		}
		
	}

}