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

package org.vostokframework.loadingmanagement.services
{
	import org.as3collections.IList;
	import org.as3collections.lists.ArrayList;
	import org.flexunit.Assert;
	import org.vostokframework.VostokFramework;
	import org.vostokframework.VostokIdentification;
	import org.vostokframework.loadingmanagement.LoadingManagementContext;
	import org.vostokframework.loadingmanagement.domain.ILoader;
	import org.vostokframework.loadingmanagement.domain.LoadPriority;
	import org.vostokframework.loadingmanagement.domain.VostokLoader;
	import org.vostokframework.loadingmanagement.domain.loaders.StubLoadingAlgorithm;
	import org.vostokframework.loadingmanagement.domain.monitors.CompositeLoadingMonitor;
	import org.vostokframework.loadingmanagement.domain.monitors.ILoadingMonitor;
	import org.vostokframework.loadingmanagement.domain.monitors.QueueLoadingMonitorDispatcher;

	/**
	 * @author Flávio Silva
	 */
	[TestCase]
	public class LoadingServiceTestsCancel extends LoadingServiceTestsConfiguration
	{
		private static const QUEUE1_ID:String = "queue-1";
		private static const QUEUE2_ID:String = "queue-2";
		private static const QUEUE3_ID:String = "queue-3";
		
		public function LoadingServiceTestsCancel()
		{
			
		}
		
		///////////////////////////////
		// LoadingService().cancel() //
		///////////////////////////////
		
		//QUEUE testing
		
		[Test(expects="ArgumentError")]
		public function cancel_invalidLoaderIdArgument_ThrowsError(): void
		{
			service.cancel(null);
		}
		
		[Test(expects="org.vostokframework.loadingmanagement.domain.errors.LoaderNotFoundError")]
		public function cancel_notExistingLoader_ThrowsError(): void
		{
			service.cancel(QUEUE1_ID);
		}
		
		[Test]
		public function cancel_loadingQueueLoader_checkIfQueueLoaderExists_ReturnsFalse(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE1_ID, list);
			service.cancel(QUEUE1_ID);
			
			var exists:Boolean = service.exists(QUEUE1_ID);
			Assert.assertFalse(exists);
		}
		
		[Test]
		public function cancel_loadingQueueLoader_checkIfAssetLoaderExists_ReturnsFalse(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE1_ID, list);
			service.cancel(QUEUE1_ID);
			
			var exists:Boolean = service.exists(asset1.identification.id, asset1.identification.locale);
			Assert.assertFalse(exists);
		}
		
		[Test]
		public function cancel_stoppedQueueLoader_checkIfLoaderExists_ReturnsFalse(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE1_ID, list);
			service.stop(QUEUE1_ID);
			service.cancel(QUEUE1_ID);
			
			var exists:Boolean = service.exists(QUEUE1_ID);
			Assert.assertFalse(exists);
		}
		
		[Test]
		public function cancel_queuedQueueLoader_checkIfQueueLoaderExists_ReturnsFalse(): void
		{
			var identification:VostokIdentification = new VostokIdentification(QUEUE1_ID, VostokFramework.CROSS_LOCALE_ID);
			var queueLoader:ILoader = new VostokLoader(identification, new StubLoadingAlgorithm(), LoadPriority.MEDIUM);
			
			var monitor:ILoadingMonitor = new CompositeLoadingMonitor(queueLoader, new QueueLoadingMonitorDispatcher(identification.id, identification.locale));
			
			LoadingManagementContext.getInstance().globalQueueLoader.addLoader(queueLoader);
			LoadingManagementContext.getInstance().globalQueueLoadingMonitor.addMonitor(monitor);
			
			service.cancel(QUEUE1_ID);
			
			var exists:Boolean = service.exists(QUEUE1_ID);
			Assert.assertFalse(exists);
		}
		
		[Test(expects="org.vostokframework.loadingmanagement.domain.errors.LoaderNotFoundError")]
		public function cancel_callTwice_ThrowsError(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE1_ID, list);
			service.cancel(QUEUE1_ID);
			service.cancel(QUEUE1_ID);
		}
		
		[Test]
		public function cancel_twoQueueLoadersLoadingAndOneQueued_cancelQueuedQueueLoaderAndCallLoadAgain_ReturnsILoadingMonitor(): void
		{
			var list1:IList = new ArrayList();
			list1.add(asset1);
			
			service.load(QUEUE1_ID, list1);
			
			var list2:IList = new ArrayList();
			list2.add(asset2);
			
			service.load(QUEUE2_ID, list2);
			
			var list3:IList = new ArrayList();
			list3.add(asset3);
			
			service.load(QUEUE3_ID, list3);
			service.cancel(QUEUE3_ID);
			
			var monitor:ILoadingMonitor = service.load(QUEUE3_ID, list3);
			Assert.assertNotNull(monitor);
		}
		
		//ASSET testing
		
		[Test]
		public function cancel_uniqueAssetLoaderInQueueLoader_loadingAssetLoader_checkIfQueueLoaderExists_ReturnsFalse(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE1_ID, list);
			service.cancel(asset1.identification.id, asset1.identification.locale);
			
			var exists:Boolean = service.exists(QUEUE1_ID);
			Assert.assertFalse(exists);
		}
		
		[Test]
		public function cancel_uniqueAssetLoaderInQueueLoader_loadingAssetLoader_checkIfAssetLoaderExists_ReturnsFalse(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE1_ID, list);
			service.cancel(asset1.identification.id, asset1.identification.locale);
			
			var exists:Boolean = service.exists(asset1.identification.id, asset1.identification.locale);
			Assert.assertFalse(exists);
		}
		
		[Test]
		public function cancel_uniqueAssetLoaderInQueueLoader_stoppedAssetLoader_checkIfAssetLoaderExists_ReturnsFalse(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE1_ID, list);
			service.stop(asset1.identification.id, asset1.identification.locale);
			service.cancel(asset1.identification.id, asset1.identification.locale);
			
			var exists:Boolean = service.exists(asset1.identification.id, asset1.identification.locale); 
			Assert.assertFalse(exists);
		}
		
		[Test(expects="org.vostokframework.loadingmanagement.domain.errors.LoaderNotFoundError")]
		public function cancel_notUniqueAssetLoaderInQueueLoader_callsTwiceForSameAsset_ThrowsError(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			list.add(asset2);
			
			service.load(QUEUE1_ID, list);
			service.cancel(asset1.identification.id, asset1.identification.locale);
			service.cancel(asset1.identification.id, asset1.identification.locale);
		}
		
	}

}