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
	import org.vostokframework.VostokFramework;
	import org.vostokframework.VostokIdentification;
	import org.vostokframework.domain.assets.settings.AssetLoadingSettings;
	import org.vostokframework.application.LoadingContext;
	import org.vostokframework.domain.loading.ILoader;
	import org.vostokframework.domain.loading.LoadPriority;

	/**
	 * @author Flávio Silva
	 */
	[TestCase]
	public class LoadingServiceTestsChangePriority extends LoadingServiceTestsConfiguration
	{
		private static const QUEUE1_ID:String = "queue-1";
		private static const QUEUE2_ID:String = "queue-2";
		private static const QUEUE3_ID:String = "queue-3";
		
		public function LoadingServiceTestsChangePriority()
		{
			
		}
		
		///////////////////////////////////////
		// LoadingService().changePriority() //
		///////////////////////////////////////
		
		//QUEUE testing
		
		[Test(expects="ArgumentError")]
		public function changePriority_invalidLoaderIdArgument_ThrowsError(): void
		{
			service.changePriority(null, LoadPriority.HIGH);
		}
		
		[Test(expects="ArgumentError")]
		public function changePriority_invalidPriority_ThrowsError(): void
		{
			service.changePriority(QUEUE1_ID, null);
		}
		
		[Test(expects="org.vostokframework.domain.loading.errors.LoaderNotFoundError")]
		public function changePriority_notExistingLoader_ThrowsError(): void
		{
			service.changePriority(QUEUE1_ID, LoadPriority.HIGH);
		}
		
		[Test]
		public function changePriority_queuedQueueLoader_changePriority_checkIfPriorityMatches_ReturnsTrue(): void
		{
			var list1:IList = new ArrayList();
			list1.add(asset1);
			service.load(QUEUE1_ID, list1);
			
			service.changePriority(QUEUE1_ID, LoadPriority.LOWEST);
			
			var identification:VostokIdentification = new VostokIdentification(QUEUE1_ID, VostokFramework.CROSS_LOCALE_ID);
			var loader:ILoader = LoadingContext.getInstance().globalQueueLoader.getChild(identification);
			Assert.assertEquals(0, loader.priority);
		}
		
		[Test]
		public function changePriority_queuedQueueLoader_changePriorityToHighest_callIsLoading_ReturnsTrue(): void
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
			
			service.changePriority(QUEUE3_ID, LoadPriority.HIGHEST);
			
			var isLoading:Boolean = service.isLoading(QUEUE3_ID);
			Assert.assertTrue(isLoading);
		}
		
		//ASSET testing
		
		[Test]
		public function changePriority_queuedAssetLoader_changePriority_checkIfPriorityMatches_ReturnsTrue(): void
		{
			var list1:IList = new ArrayList();
			list1.add(asset1);
			service.load(QUEUE1_ID, list1);
			
			service.changePriority(asset1.identification.id, LoadPriority.LOWEST);
			
			var loader:ILoader = LoadingContext.getInstance().globalQueueLoader.getChild(asset1.identification);
			Assert.assertEquals(0, loader.priority);
		}
		
		[Test]
		public function changePriority_queuedAssetLoaderWithLowestPriority_changePriorityToHighest_callIsLoading_ReturnsTrue(): void
		{
			var list1:IList = new ArrayList();
			list1.add(asset1);
			list1.add(asset2);
			list1.add(asset3);
			
			var settings:AssetLoadingSettings = LoadingContext.getInstance().assetLoadingSettingsRepository.find(asset3);
			settings.policy.priority = LoadPriority.LOWEST;
			
			service.load(QUEUE1_ID, list1);
			
			service.changePriority(asset3.identification.id, LoadPriority.HIGHEST);
			
			var isLoading:Boolean = service.isLoading(asset3.identification.id);
			Assert.assertTrue(isLoading);
		}
		
	}

}