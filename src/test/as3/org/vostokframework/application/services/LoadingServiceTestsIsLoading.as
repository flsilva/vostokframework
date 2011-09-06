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

package org.vostokframework.application.services
{
	import org.as3collections.IList;
	import org.as3collections.lists.ArrayList;
	import org.flexunit.Assert;

	/**
	 * @author Flávio Silva
	 */
	[TestCase]
	public class LoadingServiceTestsIsLoading extends LoadingServiceTestsConfiguration
	{
		private static const QUEUE1_ID:String = "queue-1";
		private static const QUEUE2_ID:String = "queue-2";
		private static const QUEUE3_ID:String = "queue-3";
		
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
		
		[Test(expects="org.vostokframework.domain.loading.errors.LoaderNotFoundError")]
		public function isLoading_notExistingLoader_ThrowsError(): void
		{
			service.isLoading(QUEUE1_ID);
		}
		
		[Test]
		public function isLoading_loadingQueueLoader_ReturnsTrue(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE1_ID, list);
			
			var isLoading:Boolean = service.isLoading(QUEUE1_ID);
			Assert.assertTrue(isLoading);
		}
		
		[Test]
		public function isLoading_stoppedQueueLoader_ReturnsFalse(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE1_ID, list);
			service.stop(QUEUE1_ID);
			
			var isLoading:Boolean = service.isLoading(QUEUE1_ID);
			Assert.assertFalse(isLoading);
		}
		
		[Test]
		public function isLoading_queuedQueueLoader_ReturnsFalse(): void
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
			
			var isLoading:Boolean = service.isLoading(QUEUE3_ID);
			Assert.assertFalse(isLoading);
		}
		
		//ASSET testing
		
		[Test]
		public function isLoading_loadingAssetLoader_ReturnsTrue(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE1_ID, list);
			
			var isLoading:Boolean = service.isLoading(asset1.identification.id, asset1.identification.locale);
			Assert.assertTrue(isLoading);
		}
		
		[Test]
		public function isLoading_stoppedAssetLoader_ReturnsFalse(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE1_ID, list);
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
			
			service.load(QUEUE1_ID, list, null, 1);
			
			var isLoading:Boolean = service.isLoading(asset2.identification.id, asset2.identification.locale);
			Assert.assertFalse(isLoading);
		}
		
	}

}