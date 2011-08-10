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
		private static const QUEUE_ID:String = "queue-1";
		
		public function LoadingServiceTestsCancel()
		{
			
		}
		
		///////////////////////////////
		// LoadingService().cancel() //
		///////////////////////////////
		
		[Test(expects="ArgumentError")]
		public function cancel_invalidLoaderIdArgument_ThrowsError(): void
		{
			service.cancel(null);
		}
		
		[Test(expects="org.vostokframework.loadingmanagement.domain.errors.LoaderNotFoundError")]
		public function cancel_notExistingLoader_ThrowsError(): void
		{
			service.cancel(QUEUE_ID);
		}
		
		[Test]
		public function cancel_loadingLoader_Void(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE_ID, list);
			service.cancel(QUEUE_ID);
		}
		
		[Test]
		public function cancel_loadingLoader_checkIfQueueLoaderExists_ReturnsFalse(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE_ID, list);
			service.cancel(QUEUE_ID);
			
			var exists:Boolean = service.exists(QUEUE_ID);
			Assert.assertFalse(exists);
		}
		
		[Test]
		public function cancel_loadingLoader_checkIfAssetLoaderExists_ReturnsFalse(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE_ID, list);
			service.cancel(QUEUE_ID);
			
			var exists:Boolean = service.exists(asset1.identification.id, asset1.identification.locale);
			Assert.assertFalse(exists);
		}
		
		[Test]
		public function cancel_stoppedLoader_Void(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE_ID, list);
			service.stop(QUEUE_ID);
			service.cancel(QUEUE_ID);
		}
		
		[Test]
		public function cancel_stoppedLoader_checkIfLoaderExists_ReturnsFalse(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE_ID, list);
			service.stop(QUEUE_ID);
			service.cancel(QUEUE_ID);
			
			var exists:Boolean = service.exists(QUEUE_ID);
			Assert.assertFalse(exists);
		}
		
		[Test]
		public function cancel_queuedLoader_checkIfLoaderExists_ReturnsFalse(): void
		{
			var identification:VostokIdentification = new VostokIdentification(QUEUE_ID, VostokFramework.CROSS_LOCALE_ID);
			var queueLoader:VostokLoader = new VostokLoader(identification, new StubLoadingAlgorithm(), LoadPriority.MEDIUM, 1);
			
			var monitor:ILoadingMonitor = new CompositeLoadingMonitor(queueLoader, new QueueLoadingMonitorDispatcher(identification.id, identification.locale));
			
			LoadingManagementContext.getInstance().globalQueueLoader.addLoader(queueLoader);
			LoadingManagementContext.getInstance().globalQueueLoadingMonitor.addMonitor(monitor);
			
			service.cancel(QUEUE_ID);
			
			var exists:Boolean = service.exists(QUEUE_ID);
			Assert.assertFalse(exists);
		}
		
		[Test(expects="org.vostokframework.loadingmanagement.domain.errors.LoaderNotFoundError")]
		public function cancel_callTwice_ThrowsError(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE_ID, list);
			service.cancel(QUEUE_ID);
			service.cancel(QUEUE_ID);
		}
		
	}

}