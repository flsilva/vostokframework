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
	import org.vostokframework.loadingmanagement.domain.loaders.states.LoaderStopped;

	/**
	 * @author Flávio Silva
	 */
	[TestCase]
	public class LoadingServiceTestsStop extends LoadingServiceTestsConfiguration
	{
		private static const QUEUE_ID:String = "queue-1";
		
		public function LoadingServiceTestsStop()
		{
			
		}
		
		/////////////////////////////
		// LoadingService().stop() //
		/////////////////////////////
		
		[Test(expects="ArgumentError")]
		public function stop_invalidLoaderIdArgument_ThrowsError(): void
		{
			service.stop(null);
		}
		
		[Test(expects="org.vostokframework.loadingmanagement.domain.errors.LoaderNotFoundError")]
		public function stop_notExistingLoader_ThrowsError(): void
		{
			service.stop(QUEUE_ID);
		}
		
		[Test]
		public function stop_loadingLoader_ReturnsTrue(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE_ID, list);
			
			var stopped:Boolean = service.stop(QUEUE_ID);
			Assert.assertTrue(stopped);
		}
		
		[Test]
		public function stop_notLoadingLoader_ReturnsTrue(): void
		{
			var identification:VostokIdentification = new VostokIdentification(QUEUE_ID, VostokFramework.CROSS_LOCALE_ID);
			var queueLoader:VostokLoader = new VostokLoader(identification, new StubLoadingAlgorithm(), LoadPriority.MEDIUM, 1);
			
			LoadingManagementContext.getInstance().globalQueueLoader.addLoader(queueLoader);
			
			var stopped:Boolean = service.stop(QUEUE_ID);
			Assert.assertTrue(stopped);
		}
		
		[Test]
		public function stop_stoppedLoader_ReturnsFalse(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE_ID, list);
			service.stop(QUEUE_ID);
			
			var stopped:Boolean = service.stop(QUEUE_ID);
			Assert.assertFalse(stopped);
		}
		
		[Test]
		public function stop_loadingLoader_CheckIfLoaderStateIsStopped_ReturnsTrue(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE_ID, list);
			service.stop(QUEUE_ID);
			
			var identification:VostokIdentification = new VostokIdentification(QUEUE_ID, VostokFramework.CROSS_LOCALE_ID);
			var queueLoader:VostokLoader = LoadingManagementContext.getInstance().globalQueueLoader.getLoader(identification);
			Assert.assertEquals(LoaderStopped.INSTANCE, queueLoader.state);
		}
		
	}

}