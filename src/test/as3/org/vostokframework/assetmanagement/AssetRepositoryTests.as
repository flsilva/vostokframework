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
		public function constructor_validInstanciation_ReturnsValidObject(): void
		{
			var repository:AssetRepository = new AssetRepository();
			Assert.assertNotNull(repository);
		}
		
		/////////////////////////////////////
		// AssetRepository().add() TESTS ////
		/////////////////////////////////////
		
		[Test]
		public function add_validArgument_checkIfRepositoryContainsObject_ReturnsTrue(): void
		{
			var assetPackage:AssetPackage = new AssetPackage("asset-package-1", "en-US");
			
			var assetFactory:AssetFactory = new AssetFactory();
			var asset:Asset = assetFactory.create("a.aac", assetPackage);
			
			var repository:AssetRepository = new AssetRepository();
			repository.add(asset);
			
			Assert.assertTrue(repository.exists(asset.id));
		}
		
		[Test(expects="org.vostokframework.assetmanagement.errors.DuplicateAssetError")]
		public function add_dupplicateAsset_ThrowsError(): void
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
		public function add_invalidArgument_ThrowsError(): void
		{
			var repository:AssetRepository = new AssetRepository();
			repository.add(null);
		}
		
		/////////////////////////////////////
		// AssetRepository().clear() TESTS //
		/////////////////////////////////////
		
		[Test]
		public function clear_emptyAssetRepository_checkIfIsEmpty_ReturnsTrue(): void
		{
			var repository:AssetRepository = new AssetRepository();
			repository.clear();
			Assert.assertTrue(repository.isEmpty());
		}
		
		[Test]
		public function clear_notEmptyAssetRepository_checkIfSizeIsZero_ReturnsTrue(): void
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
		public function clear_notEmptyAssetRepository_checkIfRepositoryIsEmpty_ReturnsTrue(): void
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
		public function exists_addedAsset_ReturnsTrue(): void
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
		public function exists_notAddedAsset_ReturnsFalse(): void
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
		public function find_addedAsset_checkIfReturnedIdMatches_ReturnsTrue(): void
		{
			var assetPackage:AssetPackage = new AssetPackage("asset-package-1", "en-US");
			var assetFactory:AssetFactory = new AssetFactory();
			var asset:Asset = assetFactory.create("a.aac", assetPackage);
			
			var repository:AssetRepository = new AssetRepository();
			repository.add(asset);
			
			var composedId:String = LocaleUtil.composeId("a.aac", "en-US");
			asset = repository.find(composedId);
			
			Assert.assertEquals(composedId, asset.id);
		}
		
		[Test]
		public function find_notAddedAsset_ReturnsNull(): void
		{
			var repository:AssetRepository = new AssetRepository();
			
			var composedId:String = LocaleUtil.composeId("any-id-not-added", "any-locale");
			var asset:Asset = repository.find(composedId);
			
			Assert.assertNull(asset);
		}
		
		///////////////////////////////////////
		// AssetRepository().findAll() TESTS //
		///////////////////////////////////////
		
		[Test]
		public function findAll_emptyAssetRepository_ReturnsNull(): void
		{
			var repository:AssetRepository = new AssetRepository();
			var list:IList = repository.findAll();
			
			Assert.assertNull(list);
		}
		
		[Test]
		public function findAll_notEmptyAssetRepository_ReturnsIList(): void
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
		public function findAll_notEmptyAssetRepository_checkIfReturnedListSizeMatches_ReturnsTrue(): void
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
		public function isEmpty_emptyAssetRepository_ReturnsTrue(): void
		{
			var repository:AssetRepository = new AssetRepository();
			var empty:Boolean = repository.isEmpty();
			
			Assert.assertTrue(empty);
		}
		
		[Test]
		public function isEmpty_notEmptyAssetRepository_ReturnsFalse(): void
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
		public function remove_emptyAssetRepository_ReturnsFalse(): void
		{
			var repository:AssetRepository = new AssetRepository();
			var removed:Boolean = repository.remove("any-id-not-added");
			
			Assert.assertFalse(removed);
		}
		
		[Test]
		public function remove_notEmptyAssetRepository_notAddedAsset_ReturnsFalse(): void
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
		public function remove_notEmptyAssetRepository_addedAsset_ReturnsTrue(): void
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
		public function size_emptyAssetRepository_checkIfSizeIsZero_ReturnsTrue(): void
		{
			var repository:AssetRepository = new AssetRepository();
			var size:int = repository.size();
			
			Assert.assertEquals(0, size);
		}
		
		[Test]
		public function size_notEmptyAssetRepository_checkIfSizeMatches_ReturnsTrue(): void
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