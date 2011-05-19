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
	[TestCase(order=6)]
	public class AssetPackageRepositoryTests
	{
		
		public function AssetPackageRepositoryTests()
		{
			
		}
		
		///////////////////////
		// CONSTRUCTOR TESTS //
		///////////////////////
		
		[Test]
		public function constructor_validInstantiation_ReturnsValidObject(): void
		{
			var repository:AssetPackageRepository = new AssetPackageRepository();
			Assert.assertNotNull(repository);
		}
		
		////////////////////////////////////////////
		// AssetPackageRepository().add() TESTS ////
		////////////////////////////////////////////
		
		[Test]
		public function add_validArgument_checkIfAssetRepositoryContainsTheObject_ReturnsTrue(): void
		{
			var assetPackage:AssetPackage = new AssetPackage("asset-package-1", "en-US");
			var repository:AssetPackageRepository = new AssetPackageRepository();
			repository.add(assetPackage);
			
			Assert.assertTrue(repository.exists(assetPackage.id));
		}
		
		[Test(expects="org.vostokframework.assetmanagement.errors.DuplicateAssetPackageError")]
		public function add_dupplicatedAssetPackage_ThrowsError(): void
		{
			var assetPackage:AssetPackage = new AssetPackage("asset-package-1", "en-US");
			var repository:AssetPackageRepository = new AssetPackageRepository();
			repository.add(assetPackage);
			
			assetPackage = new AssetPackage("asset-package-1", "en-US");
			repository.add(assetPackage);
		}
		
		[Test(expects="ArgumentError")]
		public function add_nullAssetPackage_ThrowsError(): void
		{
			var repository:AssetPackageRepository = new AssetPackageRepository();
			repository.add(null);
		}
		
		////////////////////////////////////////////
		// AssetPackageRepository().clear() TESTS //
		////////////////////////////////////////////
		
		[Test]
		public function clear_emptyAssetPackageRepository_checkIfAssetPackageRepositoryIsEmpty_ReturnsTrue(): void
		{
			var repository:AssetPackageRepository = new AssetPackageRepository();
			repository.clear();
			
			Assert.assertTrue(repository.isEmpty());
		}
		
		[Test]
		public function clear_notEmptyAssetPackageRepository_checkIfAssetPackageRepositorySizeIsZero_ReturnsTrue(): void
		{
			var assetPackage:AssetPackage = new AssetPackage("asset-package-1", "en-US");
			
			var repository:AssetPackageRepository = new AssetPackageRepository();
			repository.add(assetPackage);
			repository.clear();
			
			Assert.assertEquals(0, repository.size());
		}
		
		[Test]
		public function clear_notEmptyAssetPackageRepository_checkIfAssetPackageRepositoryIsEmpty_ReturnsTrue(): void
		{
			var assetPackage:AssetPackage = new AssetPackage("asset-package-1", "en-US");
			
			var repository:AssetPackageRepository = new AssetPackageRepository();
			repository.add(assetPackage);
			repository.clear();
			
			Assert.assertTrue(repository.isEmpty());
		}
		
		/////////////////////////////////////////////
		// AssetPackageRepository().exists() TESTS //
		/////////////////////////////////////////////
		
		[Test]
		public function exists_addedAssetPackage_ReturnsTrue(): void
		{
			var assetPackage:AssetPackage = new AssetPackage("asset-package-1", "en-US");
			
			var repository:AssetPackageRepository = new AssetPackageRepository();
			repository.add(assetPackage);
			
			var exists:Boolean = repository.exists(assetPackage.id);
			
			Assert.assertTrue(exists);
		}
		
		[Test]
		public function exists_notAddedAssetPackage_ReturnsFalse(): void
		{
			var assetPackage:AssetPackage = new AssetPackage("asset-package-1", "en-US");
			
			var repository:AssetPackageRepository = new AssetPackageRepository();
			var exists:Boolean = repository.exists(assetPackage.id);
			
			Assert.assertFalse(exists);
		}
		
		///////////////////////////////////////////
		// AssetPackageRepository().find() TESTS //
		///////////////////////////////////////////
		
		[Test]
		public function find_addedAssetPackage_ReturnsValidObject(): void
		{
			var assetPackage:AssetPackage = new AssetPackage("asset-package-1", "en-US");
			var repository:AssetPackageRepository = new AssetPackageRepository();
			repository.add(assetPackage);
			
			assetPackage = repository.find("asset-package-1");
			
			Assert.assertNotNull(assetPackage);
		}
		
		[Test]
		public function find_notAddedAssetPackage_ReturnsNull(): void
		{
			var repository:AssetPackageRepository = new AssetPackageRepository();
			
			var id:String = LocaleUtil.composeId("any-id-not-added", "any-locale");
			var assetPackage:AssetPackage = repository.find(id);
			
			Assert.assertNull(assetPackage);
		}
		
		//////////////////////////////////////////////
		// AssetPackageRepository().findAll() TESTS //
		//////////////////////////////////////////////
		
		[Test]
		public function findAll_emptyAssetPackageRepository_ReturnsNull(): void
		{
			var repository:AssetPackageRepository = new AssetPackageRepository();
			var list:IList = repository.findAll();
			
			Assert.assertNull(list);
		}
		
		[Test]
		public function findAll_notEmptyAssetPackageRepository_ReturnsIList(): void
		{
			var assetPackage:AssetPackage = new AssetPackage("asset-package-1", "en-US");
			var repository:AssetPackageRepository = new AssetPackageRepository();
			repository.add(assetPackage);
			
			var list:IList = repository.findAll();
			
			Assert.assertNotNull(list);
		}
		
		[Test]
		public function findAll_notEmptyAssetPackageRepository_checkIfReturnedListSizeMatches_ReturnsTrue(): void
		{
			var assetPackage:AssetPackage = new AssetPackage("asset-package-1", "en-US");
			var repository:AssetPackageRepository = new AssetPackageRepository();
			repository.add(assetPackage);
			
			var list:IList = repository.findAll();
			var size:int = list.size();
			
			Assert.assertEquals(1, size);
		}
		
		////////////////////////////////////////////////////////////////
		// AssetPackageRepository().findAssetPackageByAssetId() TESTS //
		////////////////////////////////////////////////////////////////
		
		[Test]
		public function findAssetPackageByAssetId_addedAsset_ReturnsValidObject(): void
		{
			var assetPackage:AssetPackage = new AssetPackage("asset-package-1", "en-US");
			var repository:AssetPackageRepository = new AssetPackageRepository();
			repository.add(assetPackage);
			
			var assetFactory:AssetFactory = new AssetFactory();
			var asset:Asset = assetFactory.create("a.aac", assetPackage);
			assetPackage.addAsset(asset);
			
			assetPackage = repository.findAssetPackageByAssetId(asset.id);
			
			Assert.assertNotNull(assetPackage);
		}
		
		[Test]
		public function findAssetPackageByAssetId_notAddedAsset_ReturnsNull(): void
		{
			var repository:AssetPackageRepository = new AssetPackageRepository();
			
			var id:String = LocaleUtil.composeId("any-id-not-added", "any-locale");
			var assetPackage:AssetPackage = repository.findAssetPackageByAssetId(id);
			
			Assert.assertNull(assetPackage);
		}
		
		//////////////////////////////////////////////
		// AssetPackageRepository().isEmpty() TESTS //
		//////////////////////////////////////////////
		
		[Test]
		public function isEmpty_emptyAssetPackageRepository_ReturnsTrue(): void
		{
			var repository:AssetPackageRepository = new AssetPackageRepository();
			
			Assert.assertTrue(repository.isEmpty());
		}
		
		[Test]
		public function isEmpty_notEmptyAssetPackageRepository_ReturnsFalse(): void
		{
			var assetPackage:AssetPackage = new AssetPackage("asset-package-1", "en-US");
			var repository:AssetPackageRepository = new AssetPackageRepository();
			repository.add(assetPackage);
			
			Assert.assertFalse(repository.isEmpty());
		}
		
		/////////////////////////////////////////////
		// AssetPackageRepository().remove() TESTS //
		/////////////////////////////////////////////
		
		[Test]
		public function remove_emptyAssetPackageRepository_ReturnsFalse(): void
		{
			var repository:AssetPackageRepository = new AssetPackageRepository();
			var removed:Boolean = repository.remove("any-id-not-added");
			
			Assert.assertFalse(removed);
		}
		
		[Test]
		public function remove_notEmptyAssetPackageRepository_notAddedAssetPackage_ReturnsFalse(): void
		{
			var assetPackage:AssetPackage = new AssetPackage("asset-package-1", "en-US");
			var repository:AssetPackageRepository = new AssetPackageRepository();
			repository.add(assetPackage);
			
			var removed:Boolean = repository.remove("any-id-not-added");
			
			Assert.assertFalse(removed);
		}
		
		[Test]
		public function remove_notEmptyAssetPackageRepository_addedAssetPackage_ReturnsTrue(): void
		{
			var assetPackage:AssetPackage = new AssetPackage("asset-package-1", "en-US");
			var repository:AssetPackageRepository = new AssetPackageRepository();
			repository.add(assetPackage);
			
			var removed:Boolean = repository.remove(assetPackage.id);
			
			Assert.assertTrue(removed);
		}
		
		///////////////////////////////////////////
		// AssetPackageRepository().size() TESTS //
		///////////////////////////////////////////
		
		[Test]
		public function size_emptyAssetPackageRepository_checkIfSizeIsZero_ReturnsTrue(): void
		{
			var repository:AssetPackageRepository = new AssetPackageRepository();
			var size:int = repository.size();
			
			Assert.assertEquals(0, size);
		}
		
		[Test]
		public function size_notEmptyAssetPackageRepository_checkIfSizeMatches_ReturnsTrue(): void
		{
			var assetPackage:AssetPackage = new AssetPackage("asset-package-1", "en-US");
			var repository:AssetPackageRepository = new AssetPackageRepository();
			repository.add(assetPackage);
			
			var size:int = repository.size();
			
			Assert.assertEquals(1, size);
		}
		
	}

}