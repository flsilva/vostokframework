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
	import org.vostokframework.application.monitoring.ILoadingMonitor;

	/**
	 * @author Flávio Silva
	 */
	[TestCase]
	public class LoadingServiceTestsMergeAssets extends LoadingServiceTestsConfiguration
	{
		private static const QUEUE_ID:String = "queue-1";
		
		public function LoadingServiceTestsMergeAssets()
		{
			
		}
		
		////////////////////////////////////
		// LoadingService().mergeAssets() //
		////////////////////////////////////
		
		[Test(expects="ArgumentError")]
		public function mergeAssets_invalidLoaderIdArgument_ThrowsError(): void
		{
			service.mergeAssets(null, null);
		}
		
		[Test(expects="ArgumentError")]
		public function mergeAssets_invalidIListArgument_ThrowsError(): void
		{
			service.mergeAssets(QUEUE_ID, null);
		}
		
		[Test(expects="org.vostokframework.domain.loading.errors.LoaderNotFoundError")]
		public function mergeAssets_notExistingLoader_ThrowsError(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.mergeAssets(QUEUE_ID, list);
		}
		
		[Test(expects="org.vostokframework.domain.loading.errors.DuplicateLoaderError")]
		public function mergeAssets_dupplicateAsset_ThrowsError(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE_ID, list);
			service.mergeAssets(QUEUE_ID, list);
		}
		
		[Test]
		public function mergeAssets_loadingLoader_Void(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE_ID, list);
			
			var list2:IList = new ArrayList();
			list2.add(asset2);
			
			service.mergeAssets(QUEUE_ID, list2);
		}
		
		[Test]
		public function mergeAssets_loadingLoader_checkIfAssetLoaderForAddedAssetExists_ReturnsTrue(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE_ID, list);
			
			var list2:IList = new ArrayList();
			list2.add(asset2);
			
			service.mergeAssets(QUEUE_ID, list2);
			
			var exists:Boolean = service.exists(asset2.identification.id, asset2.identification.locale);
			Assert.assertTrue(exists);
		}
		
		[Test]
		public function mergeAssets_loadingLoader_checkIfMonitorForAddedAssetExists_ReturnsTrue(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE_ID, list);
			
			var list2:IList = new ArrayList();
			list2.add(asset2);
			
			service.mergeAssets(QUEUE_ID, list2);
			
			var monitor:ILoadingMonitor = service.getMonitor(asset2.identification.id, asset2.identification.locale);
			Assert.assertNotNull(monitor);
		}
		
		[Test]
		public function mergeAssets_loadingLoader_checkIfAssetLoaderForAddedAssetIsLoading_ReturnsTrue(): void
		{
			var list:IList = new ArrayList();
			list.add(asset1);
			
			service.load(QUEUE_ID, list, null, 2);
			
			var list2:IList = new ArrayList();
			list2.add(asset2);
			
			service.mergeAssets(QUEUE_ID, list2);
			
			var isLoading:Boolean = service.isLoading(asset2.identification.id, asset2.identification.locale);
			Assert.assertTrue(isLoading);
		}
		
	}

}