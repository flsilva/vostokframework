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

package org.vostokframework.assetmanagement.domain
{
	import org.as3collections.IList;
	import org.flexunit.Assert;
	import org.vostokframework.loadingmanagement.domain.LoadPriority;

	/**
	 * @author Flávio Silva
	 */
	[TestCase(order=6)]
	public class AssetPackageRepositoryTests
	{
		private var _repository:AssetPackageRepository;
		
		public function AssetPackageRepositoryTests()
		{
			
		}
		
		/////////////////////////
		// TESTS CONFIGURATION //
		/////////////////////////
		
		[Before]
		public function setUp(): void
		{
			_repository = new AssetPackageRepository();
		}
		
		[After]
		public function tearDown(): void
		{
			_repository = null;
		}
		
		////////////////////
		// HELPER METHODS //
		////////////////////
		
		private function getAssetPackage():AssetPackage
		{
			return new AssetPackage("package-id", "en-US");
		}
		
		private function getAsset():Asset
		{
			return new Asset("asset-id", "asset-path/asset.xml", AssetType.XML, LoadPriority.HIGH);
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
			var assetPackage:AssetPackage = getAssetPackage();
			_repository.add(assetPackage);
			
			Assert.assertTrue(_repository.exists(assetPackage.id));
		}
		
		[Test(expects="org.vostokframework.assetmanagement.domain.errors.DuplicateAssetPackageError")]
		public function add_dupplicatedAssetPackage_ThrowsError(): void
		{
			_repository.add(getAssetPackage());
			_repository.add(getAssetPackage());
		}
		
		[Test(expects="ArgumentError")]
		public function add_nullAssetPackage_ThrowsError(): void
		{
			_repository.add(null);
		}
		
		////////////////////////////////////////////
		// AssetPackageRepository().clear() TESTS //
		////////////////////////////////////////////
		
		[Test]
		public function clear_emptyAssetPackageRepository_checkIfAssetPackageRepositoryIsEmpty_ReturnsTrue(): void
		{
			_repository.clear();
			Assert.assertTrue(_repository.isEmpty());
		}
		
		[Test]
		public function clear_notEmptyAssetPackageRepository_checkIfAssetPackageRepositorySizeIsZero_ReturnsTrue(): void
		{
			_repository.add(getAssetPackage());
			_repository.clear();
			
			Assert.assertEquals(0, _repository.size());
		}
		
		[Test]
		public function clear_notEmptyAssetPackageRepository_checkIfAssetPackageRepositoryIsEmpty_ReturnsTrue(): void
		{
			_repository.add(getAssetPackage());
			_repository.clear();
			
			Assert.assertTrue(_repository.isEmpty());
		}
		
		/////////////////////////////////////////////
		// AssetPackageRepository().exists() TESTS //
		/////////////////////////////////////////////
		
		[Test]
		public function exists_addedAssetPackage_ReturnsTrue(): void
		{
			var assetPackage:AssetPackage = getAssetPackage();
			_repository.add(assetPackage);
			
			var exists:Boolean = _repository.exists(assetPackage.id);
			Assert.assertTrue(exists);
		}
		
		[Test]
		public function exists_notAddedAssetPackage_ReturnsFalse(): void
		{
			var exists:Boolean = _repository.exists("any-not-added-id");
			Assert.assertFalse(exists);
		}
		
		///////////////////////////////////////////
		// AssetPackageRepository().find() TESTS //
		///////////////////////////////////////////
		
		[Test]
		public function find_addedAssetPackage_ReturnsValidObject(): void
		{
			var assetPackage:AssetPackage = getAssetPackage();
			_repository.add(assetPackage);
			
			assetPackage = _repository.find(assetPackage.id);
			Assert.assertNotNull(assetPackage);
		}
		
		[Test]
		public function find_notAddedAssetPackage_ReturnsNull(): void
		{
			var assetPackage:AssetPackage = _repository.find("any-not-added-id");
			Assert.assertNull(assetPackage);
		}
		
		//////////////////////////////////////////////
		// AssetPackageRepository().findAll() TESTS //
		//////////////////////////////////////////////
		
		[Test]
		public function findAll_emptyAssetPackageRepository_ReturnsNull(): void
		{
			var list:IList = _repository.findAll();
			Assert.assertNull(list);
		}
		
		[Test]
		public function findAll_notEmptyAssetPackageRepository_ReturnsIList(): void
		{
			_repository.add(getAssetPackage());
			
			var list:IList = _repository.findAll();
			Assert.assertNotNull(list);
		}
		
		[Test]
		public function findAll_notEmptyAssetPackageRepository_checkIfReturnedListSizeMatches_ReturnsTrue(): void
		{
			_repository.add(getAssetPackage());
			
			var list:IList = _repository.findAll();
			var size:int = list.size();
			Assert.assertEquals(1, size);
		}
		
		////////////////////////////////////////////////////////////////
		// AssetPackageRepository().findAssetPackageByAssetId() TESTS //
		////////////////////////////////////////////////////////////////
		
		[Test]
		public function findAssetPackageByAssetId_addedAsset_ReturnsValidObject(): void
		{
			var assetPackage:AssetPackage = getAssetPackage();
			_repository.add(assetPackage);
			
			var asset:Asset = getAsset();
			assetPackage.addAsset(asset);
			
			assetPackage = _repository.findAssetPackageByAssetId(asset.id);
			Assert.assertNotNull(assetPackage);
		}
		
		[Test]
		public function findAssetPackageByAssetId_notAddedAsset_ReturnsNull(): void
		{
			var assetPackage:AssetPackage = _repository.findAssetPackageByAssetId("any-not-added-id");
			Assert.assertNull(assetPackage);
		}
		
		//////////////////////////////////////////////
		// AssetPackageRepository().isEmpty() TESTS //
		//////////////////////////////////////////////
		
		[Test]
		public function isEmpty_emptyAssetPackageRepository_ReturnsTrue(): void
		{
			Assert.assertTrue(_repository.isEmpty());
		}
		
		[Test]
		public function isEmpty_notEmptyAssetPackageRepository_ReturnsFalse(): void
		{
			_repository.add(getAssetPackage());
			Assert.assertFalse(_repository.isEmpty());
		}
		
		/////////////////////////////////////////////
		// AssetPackageRepository().remove() TESTS //
		/////////////////////////////////////////////
		
		[Test]
		public function remove_emptyAssetPackageRepository_ReturnsFalse(): void
		{
			var removed:Boolean = _repository.remove("any-id-not-added");
			Assert.assertFalse(removed);
		}
		
		[Test]
		public function remove_notEmptyAssetPackageRepository_notAddedAssetPackage_ReturnsFalse(): void
		{
			_repository.add(getAssetPackage());
			
			var removed:Boolean = _repository.remove("any-id-not-added");
			Assert.assertFalse(removed);
		}
		
		[Test]
		public function remove_notEmptyAssetPackageRepository_addedAssetPackage_ReturnsTrue(): void
		{
			var assetPackage:AssetPackage = getAssetPackage();
			_repository.add(assetPackage);
			
			var removed:Boolean = _repository.remove(assetPackage.id);
			Assert.assertTrue(removed);
		}
		
		///////////////////////////////////////////
		// AssetPackageRepository().size() TESTS //
		///////////////////////////////////////////
		
		[Test]
		public function size_emptyAssetPackageRepository_checkIfSizeIsZero_ReturnsTrue(): void
		{
			var size:int = _repository.size();
			Assert.assertEquals(0, size);
		}
		
		[Test]
		public function size_notEmptyAssetPackageRepository_checkIfSizeMatches_ReturnsTrue(): void
		{
			_repository.add(getAssetPackage());
			
			var size:int = _repository.size();
			Assert.assertEquals(1, size);
		}
		
	}

}