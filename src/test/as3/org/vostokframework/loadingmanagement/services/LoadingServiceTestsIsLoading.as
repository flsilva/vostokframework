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

	/**
	 * @author Flávio Silva
	 */
	[TestCase]
	public class LoadingServiceTestsIsLoading extends LoadingServiceTestsConfiguration
	{
		private static const QUEUE_ID:String = "queue-1";
		
		public function LoadingServiceTestsIsLoading()
		{
			
		}
		
		//////////////////////////////////
		// LoadingService().isLoading() //
		//////////////////////////////////
		
		//QUEUE testing
		
		[Test(expects="ArgumentError")]
		public function isLoading_invalidLoaderIdArgument_ThrowsError(): void
		{
			service.isLoading(null);
		}
		
		[Test(expects="org.vostokframework.loadingmanagement.domain.errors.LoaderNotFoundError")]
		public function isLoading_notExistingLoader_ThrowsError(): void
		{
			service.isLoading(QUEUE_ID);
		}
		
		[Test]
		public function isLoading_loadingQueueLoader_ReturnsTrue(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE_ID, list);
			
			var isLoading:Boolean = service.isLoading(QUEUE_ID);
			Assert.assertTrue(isLoading);
		}
		
		[Test]
		public function isLoading_stoppedQueueLoader_ReturnsFalse(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE_ID, list);
			service.stop(QUEUE_ID);
			
			var isLoading:Boolean = service.isLoading(QUEUE_ID);
			Assert.assertFalse(isLoading);
		}
		
		[Test]
		public function isLoading_queuedQueueLoader_ReturnsFalse(): void
		{
			var identification:VostokIdentification = new VostokIdentification(QUEUE_ID, VostokFramework.CROSS_LOCALE_ID);
			var queueLoader:VostokLoader = new VostokLoader(identification, new StubLoadingAlgorithm(), LoadPriority.MEDIUM, 1);
			
			LoadingManagementContext.getInstance().globalQueueLoader.addLoader(queueLoader);
			
			var isLoading:Boolean = service.isLoading(QUEUE_ID);
			Assert.assertFalse(isLoading);
		}
		
		//ASSET testing
		
		[Test]
		public function isLoading_loadingAssetLoader_ReturnsTrue(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE_ID, list);
			
			var isLoading:Boolean = service.isLoading(asset1.identification.id, asset1.identification.locale);
			Assert.assertTrue(isLoading);
		}
		
		[Test]
		public function isLoading_stoppedAssetLoader_ReturnsFalse(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE_ID, list);
			service.stop(asset1.identification.id, asset1.identification.locale);
			
			var isLoading:Boolean = service.isLoading(asset1.identification.id, asset1.identification.locale);
			Assert.assertFalse(isLoading);
		}
		
		[Test]
		public function isLoading_queuedAssetLoader_ReturnsFalse(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			list.add(asset2);
			
			service.load(QUEUE_ID, list, null, 1);
			
			var isLoading:Boolean = service.isLoading(asset2.identification.id, asset2.identification.locale);
			Assert.assertFalse(isLoading);
		}
		
	}

}