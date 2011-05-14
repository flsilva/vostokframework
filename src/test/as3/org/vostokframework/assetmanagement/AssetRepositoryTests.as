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

package org.vostokframework.assetmanagement
{
	import org.as3collections.IList;
	import org.flexunit.Assert;
	import org.vostokframework.assetmanagement.utils.LocaleUtil;

	/**
	 * @author Flávio Silva
	 */
	[TestCase(order=5)]
	public class AssetRepositoryTests
	{
		
		public function AssetRepositoryTests()
		{
			
		}
		
		///////////////////////
		// CONSTRUCTOR TESTS //
		///////////////////////
		
		[Test]
		public function constructor_validInstanciation_Void(): void
		{
			var repository:AssetRepository = new AssetRepository();
			repository = null;
		}
		
		/////////////////////////////////////
		// AssetRepository().add() TESTS ////
		/////////////////////////////////////
		
		[Test]
		public function add_validArgument_Void(): void
		{
			var assetPackage:AssetPackage = new AssetPackage("asset-package-1", "en-US");
			
			var assetFactory:AssetFactory = new AssetFactory();
			var asset:Asset = assetFactory.create("a.aac", assetPackage);
			
			var repository:AssetRepository = new AssetRepository();
			repository.add(asset);
		}
		
		[Test(expects="org.vostokframework.assetmanagement.errors.DuplicateAssetError")]
		public function add_dupplicatedAsset_ThrowsError(): void
		{
			var assetPackage:AssetPackage = new AssetPackage("asset-package-1", "en-US");
			
			var assetFactory:AssetFactory = new AssetFactory();
			var asset:Asset = assetFactory.create("a.aac", assetPackage);
			
			var repository:AssetRepository = new AssetRepository();
			repository.add(asset);
			
			asset = assetFactory.create("a.aac", assetPackage);
			repository.add(asset);
		}
		
		[Test(expects="ArgumentError")]
		public function add_nullAsset_ThrowsError(): void
		{
			var repository:AssetRepository = new AssetRepository();
			repository.add(null);
		}
		
		/////////////////////////////////////
		// AssetRepository().clear() TESTS //
		/////////////////////////////////////
		
		[Test]
		public function clear_emptyAssetRepository_Void(): void
		{
			var repository:AssetRepository = new AssetRepository();
			repository.clear();
		}
		
		[Test]
		public function clear_notEmptyAssetRepository1_Void(): void
		{
			var assetPackage:AssetPackage = new AssetPackage("asset-package-1", "en-US");
			var assetFactory:AssetFactory = new AssetFactory();
			var asset:Asset = assetFactory.create("a.aac", assetPackage);
			
			var repository:AssetRepository = new AssetRepository();
			repository.add(asset);
			repository.clear();
			
			var size:int = repository.size();
			
			Assert.assertEquals(0, size);
		}
		
		[Test]
		public function clear_notEmptyAssetRepository2_Void(): void
		{
			var assetPackage:AssetPackage = new AssetPackage("asset-package-1", "en-US");
			var assetFactory:AssetFactory = new AssetFactory();
			var asset:Asset = assetFactory.create("a.aac", assetPackage);
			
			var repository:AssetRepository = new AssetRepository();
			repository.add(asset);
			repository.clear();
			
			var empty:Boolean = repository.isEmpty();
			
			Assert.assertTrue(empty);
		}
		
		//////////////////////////////////////
		// AssetRepository().exists() TESTS //
		//////////////////////////////////////
		
		[Test]
		public function exists_assetExists_True(): void
		{
			var assetPackage:AssetPackage = new AssetPackage("asset-package-1", "en-US");
			var assetFactory:AssetFactory = new AssetFactory();
			var asset:Asset = assetFactory.create("a.aac", assetPackage);
			
			var repository:AssetRepository = new AssetRepository();
			repository.add(asset);
			
			var exists:Boolean = repository.exists(asset.id);
			
			Assert.assertTrue(exists);
		}
		
		[Test]
		public function exists_assetNotExists_False(): void
		{
			var assetPackage:AssetPackage = new AssetPackage("asset-package-1", "en-US");
			var assetFactory:AssetFactory = new AssetFactory();
			var asset:Asset = assetFactory.create("a.aac", assetPackage);
			
			var repository:AssetRepository = new AssetRepository();
			var exists:Boolean = repository.exists(asset.id);
			
			Assert.assertFalse(exists);
		}
		
		////////////////////////////////////
		// AssetRepository().find() TESTS //
		////////////////////////////////////
		
		[Test]
		public function find_assetExists_Asset(): void
		{
			var assetPackage:AssetPackage = new AssetPackage("asset-package-1", "en-US");
			var assetFactory:AssetFactory = new AssetFactory();
			var asset:Asset = assetFactory.create("a.aac", assetPackage);
			
			var repository:AssetRepository = new AssetRepository();
			repository.add(asset);
			
			var id:String = LocaleUtil.composeId("a.aac", "en-US");
			asset = repository.find(id);
			
			Assert.assertNotNull(asset);
		}
		
		[Test]
		public function find_assetNotExists_Null(): void
		{
			var repository:AssetRepository = new AssetRepository();
			
			var id:String = LocaleUtil.composeId("any-id-not-added", "any-locale");
			var asset:Asset = repository.find(id);
			
			Assert.assertNull(asset);
		}
		
		///////////////////////////////////////
		// AssetRepository().findAll() TESTS //
		///////////////////////////////////////
		
		[Test]
		public function findAll_emptyAssetRepository_Null(): void
		{
			var repository:AssetRepository = new AssetRepository();
			var list:IList = repository.findAll();
			
			Assert.assertNull(list);
		}
		
		[Test]
		public function findAll_notEmptyAssetRepository_ReadOnlyArrayList(): void
		{
			var assetPackage:AssetPackage = new AssetPackage("asset-package-1", "en-US");
			var assetFactory:AssetFactory = new AssetFactory();
			var asset:Asset = assetFactory.create("a.aac", assetPackage);
			
			var repository:AssetRepository = new AssetRepository();
			repository.add(asset);
			
			var list:IList = repository.findAll();
			
			Assert.assertNotNull(list);
		}
		
		[Test]
		public function findAll_notEmptyAssetRepositoryCheckSize_ReadOnlyArrayList(): void
		{
			var assetPackage:AssetPackage = new AssetPackage("asset-package-1", "en-US");
			var assetFactory:AssetFactory = new AssetFactory();
			var asset:Asset = assetFactory.create("a.aac", assetPackage);
			
			var repository:AssetRepository = new AssetRepository();
			repository.add(asset);
			
			var list:IList = repository.findAll();
			var size:int = list.size();
			
			Assert.assertEquals(1, size);
		}
		
		///////////////////////////////////////
		// AssetRepository().isEmpty() TESTS //
		///////////////////////////////////////
		
		[Test]
		public function isEmpty_emptyAssetRepository_False(): void
		{
			var repository:AssetRepository = new AssetRepository();
			var empty:Boolean = repository.isEmpty();
			
			Assert.assertTrue(empty);
		}
		
		[Test]
		public function isEmpty_notEmptyAssetRepository_True(): void
		{
			var assetPackage:AssetPackage = new AssetPackage("asset-package-1", "en-US");
			var assetFactory:AssetFactory = new AssetFactory();
			var asset:Asset = assetFactory.create("a.aac", assetPackage);
			
			var repository:AssetRepository = new AssetRepository();
			repository.add(asset);
			
			var empty:Boolean = repository.isEmpty();
			
			Assert.assertFalse(empty);
		}
		
		//////////////////////////////////////
		// AssetRepository().remove() TESTS //
		//////////////////////////////////////
		
		[Test]
		public function remove_emptyAssetRepository_False(): void
		{
			var repository:AssetRepository = new AssetRepository();
			var removed:Boolean = repository.remove("any-id-not-added");
			
			Assert.assertFalse(removed);
		}
		
		[Test]
		public function remove_notEmptyAssetRepositoryNotAddedAsset_False(): void
		{
			var assetPackage:AssetPackage = new AssetPackage("asset-package-1", "en-US");
			var assetFactory:AssetFactory = new AssetFactory();
			var asset:Asset = assetFactory.create("a.aac", assetPackage);
			
			var repository:AssetRepository = new AssetRepository();
			repository.add(asset);
			
			var removed:Boolean = repository.remove("any-id-not-added");
			
			Assert.assertFalse(removed);
		}
		
		[Test]
		public function remove_notEmptyAssetRepositoryAddedAsset_True(): void
		{
			var assetPackage:AssetPackage = new AssetPackage("asset-package-1", "en-US");
			var assetFactory:AssetFactory = new AssetFactory();
			var asset:Asset = assetFactory.create("a.aac", assetPackage);
			
			var repository:AssetRepository = new AssetRepository();
			repository.add(asset);
			
			var removed:Boolean = repository.remove(asset.id);
			
			Assert.assertTrue(removed);
		}
		
		////////////////////////////////////
		// AssetRepository().size() TESTS //
		////////////////////////////////////
		
		[Test]
		public function size_emptyAssetRepository_Int(): void
		{
			var repository:AssetRepository = new AssetRepository();
			var size:int = repository.size();
			
			Assert.assertEquals(0, size);
		}
		
		[Test]
		public function size_notEmptyAssetRepository_Int(): void
		{
			var assetPackage:AssetPackage = new AssetPackage("asset-package-1", "en-US");
			var assetFactory:AssetFactory = new AssetFactory();
			var asset:Asset = assetFactory.create("a.aac", assetPackage);
			
			var repository:AssetRepository = new AssetRepository();
			repository.add(asset);
			
			var size:int = repository.size();
			
			Assert.assertEquals(1, size);
		}
		
	}

}