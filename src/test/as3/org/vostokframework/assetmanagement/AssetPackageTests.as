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
	import org.as3collections.lists.ArrayList;
	import org.flexunit.Assert;

	/**
	 * @author Flávio Silva
	 */
	[TestCase(order=2)]
	public class AssetPackageTests
	{
		
		public function AssetPackageTests()
		{
			
		}
		
		///////////////////////
		// CONSTRUCTOR TESTS //
		///////////////////////
		
		[Test(expects="ArgumentError")]
		public function constructor_invalidArguments1_ThrowsError(): void
		{
			var assetPackage:AssetPackage = new AssetPackage(null, null);
			assetPackage = null;
		}
		
		[Test(expects="ArgumentError")]
		public function constructor_invalidArguments2_ThrowsError(): void
		{
			var assetPackage:AssetPackage = new AssetPackage("asset-package-1", null);
			assetPackage = null;
		}
		
		/////////////////////////////
		// AssetPackage().id TESTS //
		/////////////////////////////
		
		[Test]
		public function id_validGet_String(): void
		{
			var assetPackage:AssetPackage = new AssetPackage("asset-package-1", "en-US");
			Assert.assertEquals("asset-package-1", assetPackage.id);
		}
		
		/////////////////////////////////
		// AssetPackage().locale TESTS //
		/////////////////////////////////
		
		[Test]
		public function locale_validGet_String(): void
		{
			var assetPackage:AssetPackage = new AssetPackage("asset-package-1", "en-US");
			Assert.assertEquals("en-US", assetPackage.locale);
		}
		
		/////////////////////////////////////
		// AssetPackage().addAsset() TESTS //
		/////////////////////////////////////
		
		[Test]
		public function addAsset_validArgument_True(): void
		{
			var assetPackage:AssetPackage = new AssetPackage("asset-package-1", "en-US");
			
			var assetFactory:AssetFactory = new AssetFactory();
			var asset:Asset = assetFactory.create("a.aac", assetPackage);
			
			var added:Boolean = assetPackage.addAsset(asset);
			
			Assert.assertTrue(added);
		}
		
		[Test]
		public function addAsset_dupplicatedAsset_False(): void
		{
			var assetPackage:AssetPackage = new AssetPackage("asset-package-1", "en-US");
			
			var assetFactory:AssetFactory = new AssetFactory();
			var asset:Asset = assetFactory.create("a.aac", assetPackage);
			assetPackage.addAsset(asset);
			
			asset = assetFactory.create("a.aac", assetPackage);
			var added:Boolean = assetPackage.addAsset(asset);
			
			Assert.assertFalse(added);
		}
		
		[Test(expects="ArgumentError")]
		public function addAsset_nullAsset_ThrowsError(): void
		{
			var assetPackage:AssetPackage = new AssetPackage("asset-package-1", "en-US");
			assetPackage.addAsset(null);
		}
		
		//////////////////////////////////////
		// AssetPackage().addAssets() TESTS //
		//////////////////////////////////////
		
		[Test]
		public function addAssets_validArgument_True(): void
		{
			var assetPackage:AssetPackage = new AssetPackage("asset-package-1", "en-US");
			
			var assetFactory:AssetFactory = new AssetFactory();
			var asset1:Asset = assetFactory.create("a.aac", assetPackage);
			var asset2:Asset = assetFactory.create("b.aac", assetPackage);
			
			var list:IList = new ArrayList();
			list.add(asset1);
			list.add(asset2);
			
			var added:Boolean = assetPackage.addAssets(list);
			
			Assert.assertTrue(added);
		}
		
		[Test]
		public function addAssets_dupplicatedArgument_False(): void
		{
			var assetPackage:AssetPackage = new AssetPackage("asset-package-1", "en-US");
			
			var assetFactory:AssetFactory = new AssetFactory();
			var asset1:Asset = assetFactory.create("a.aac", assetPackage);
			var asset2:Asset = assetFactory.create("b.aac", assetPackage);
			
			var list:IList = new ArrayList();
			list.add(asset1);
			list.add(asset2);
			
			assetPackage.addAsset(asset1);
			assetPackage.addAsset(asset2);
			
			var added:Boolean = assetPackage.addAssets(list);
			
			Assert.assertFalse(added);
		}
		
		[Test(expects="ArgumentError")]
		public function addAssets_invalidArgument_ThrowsError(): void
		{
			var assetPackage:AssetPackage = new AssetPackage("asset-package-1", "en-US");
			
			var assetFactory:AssetFactory = new AssetFactory();
			var asset1:Asset = assetFactory.create("a.aac", assetPackage);
			var asset2:Asset = assetFactory.create("b.aac", assetPackage);
			
			var list:IList = new ArrayList();
			list.add(asset1);
			list.add(asset2);
			list.add(null);
			
			assetPackage.addAssets(list);
		}
		
		//////////////////////////////////
		// AssetPackage().clear() TESTS //
		//////////////////////////////////
		
		[Test]
		public function clear_emptyAssetPackage_Void(): void
		{
			var assetPackage:AssetPackage = new AssetPackage("asset-package-1", "en-US");
			assetPackage.clear();
		}
		
		[Test]
		public function clear_notEmptyAssetPackage1_Void(): void
		{
			var assetPackage:AssetPackage = new AssetPackage("asset-package-1", "en-US");
			
			var assetFactory:AssetFactory = new AssetFactory();
			var asset:Asset = assetFactory.create("a.aac", assetPackage);
			
			assetPackage.addAsset(asset);
			assetPackage.clear();
			
			var size:int = assetPackage.size();
			
			Assert.assertEquals(0, size);
		}
		
		[Test]
		public function clear_notEmptyAssetPackage2_Void(): void
		{
			var assetPackage:AssetPackage = new AssetPackage("asset-package-1", "en-US");
			
			var assetFactory:AssetFactory = new AssetFactory();
			var asset:Asset = assetFactory.create("a.aac", assetPackage);
			
			assetPackage.addAsset(asset);
			assetPackage.clear();
			
			var empty:Boolean = assetPackage.isEmpty();
			
			Assert.assertTrue(empty);
		}
		
		//////////////////////////////////////////
		// AssetPackage().containsAsset() TESTS //
		//////////////////////////////////////////
		
		[Test]
		public function containsAsset_validArgument_True(): void
		{
			var assetPackage:AssetPackage = new AssetPackage("asset-package-1", "en-US");
			
			var assetFactory:AssetFactory = new AssetFactory();
			var asset:Asset = assetFactory.create("a.aac", assetPackage);
			
			assetPackage.addAsset(asset);
			
			var contains:Boolean = assetPackage.containsAsset(asset.id);
			
			Assert.assertTrue(contains);
		}
		
		[Test]
		public function containsAsset_validArgument_False(): void
		{
			var assetPackage:AssetPackage = new AssetPackage("asset-package-1", "en-US");
			
			var assetFactory:AssetFactory = new AssetFactory();
			var asset:Asset = assetFactory.create("a.aac", assetPackage);
			
			var contains:Boolean = assetPackage.containsAsset(asset.id);
			
			Assert.assertFalse(contains);
		}
		
		/////////////////////////////////////
		// AssetPackage().getAsset() TESTS //
		/////////////////////////////////////
		
		[Test]
		public function getAsset_validArgument_Asset(): void
		{
			var assetPackage:AssetPackage = new AssetPackage("asset-package-1", "en-US");
			
			var assetFactory:AssetFactory = new AssetFactory();
			var asset:Asset = assetFactory.create("a.aac", assetPackage);
			
			assetPackage.addAsset(asset);
			asset = assetPackage.getAsset(asset.id);
			
			Assert.assertNotNull(asset);
		}
		
		[Test]
		public function getAsset_notAddedAsset_Null(): void
		{
			var assetPackage:AssetPackage = new AssetPackage("asset-package-1", "en-US");
			var asset:Asset = assetPackage.getAsset("any-id-not-added");
			
			Assert.assertNull(asset);
		}
		
		//////////////////////////////////////
		// AssetPackage().getAssets() TESTS //
		//////////////////////////////////////
		
		[Test]
		public function getAssets_emptyAssetPackage_Null(): void
		{
			var assetPackage:AssetPackage = new AssetPackage("asset-package-1", "en-US");
			var list:IList = assetPackage.getAssets();
			
			Assert.assertNull(list);
		}
		
		[Test]
		public function getAssets_notEmptyAssetPackage_ReadOnlyArrayList(): void
		{
			var assetPackage:AssetPackage = new AssetPackage("asset-package-1", "en-US");
			
			var assetFactory:AssetFactory = new AssetFactory();
			var asset:Asset = assetFactory.create("a.aac", assetPackage);
			
			assetPackage.addAsset(asset);
			var list:IList = assetPackage.getAssets();
			
			Assert.assertNotNull(list);
		}
		
		////////////////////////////////////
		// AssetPackage().isEmpty() TESTS //
		////////////////////////////////////
		
		[Test]
		public function isEmpty_emptyAssetPackage_False(): void
		{
			var assetPackage:AssetPackage = new AssetPackage("asset-package-1", "en-US");
			var empty:Boolean = assetPackage.isEmpty();
			
			Assert.assertTrue(empty);
		}
		
		[Test]
		public function isEmpty_notEmptyAssetPackage_True(): void
		{
			var assetPackage:AssetPackage = new AssetPackage("asset-package-1", "en-US");
			
			var assetFactory:AssetFactory = new AssetFactory();
			var asset:Asset = assetFactory.create("a.aac", assetPackage);
			
			assetPackage.addAsset(asset);
			
			var empty:Boolean = assetPackage.isEmpty();
			
			Assert.assertFalse(empty);
		}
		
		////////////////////////////////////////
		// AssetPackage().removeAsset() TESTS //
		////////////////////////////////////////
		
		[Test]
		public function removeAsset_emptyAssetPackage_False(): void
		{
			var assetPackage:AssetPackage = new AssetPackage("asset-package-1", "en-US");
			var removed:Boolean = assetPackage.removeAsset("any-id-not-added");
			
			Assert.assertFalse(removed);
		}
		
		[Test]
		public function removeAsset_notEmptyAssetPackageNotAddedAsset_False(): void
		{
			var assetPackage:AssetPackage = new AssetPackage("asset-package-1", "en-US");
			
			var assetFactory:AssetFactory = new AssetFactory();
			var asset:Asset = assetFactory.create("a.aac", assetPackage);
			
			assetPackage.addAsset(asset);
			
			var removed:Boolean = assetPackage.removeAsset("any-id-not-added");
			
			Assert.assertFalse(removed);
		}
		
		[Test]
		public function removeAsset_notEmptyAssetPackageAddedAsset_True(): void
		{
			var assetPackage:AssetPackage = new AssetPackage("asset-package-1", "en-US");
			
			var assetFactory:AssetFactory = new AssetFactory();
			var asset:Asset = assetFactory.create("a.aac", assetPackage);
			
			assetPackage.addAsset(asset);
			
			var removed:Boolean = assetPackage.removeAsset(asset.id);
			
			Assert.assertTrue(removed);
		}
		
		/////////////////////////////////////////
		// AssetPackage().removeAssets() TESTS //
		/////////////////////////////////////////
		
		[Test]
		public function removeAssets_emptyAssetPackage_False(): void
		{
			var assetPackage:AssetPackage = new AssetPackage("asset-package-1", "en-US");
			
			var assetFactory:AssetFactory = new AssetFactory();
			var asset:Asset = assetFactory.create("a.aac", assetPackage);
			var list:IList = new ArrayList();
			list.add(asset);
			
			var removed:Boolean = assetPackage.removeAssets(list);
			
			Assert.assertFalse(removed);
		}
		
		[Test]
		public function removeAssets_notEmptyAssetPackageNotAddedAsset_False(): void
		{
			var assetPackage:AssetPackage = new AssetPackage("asset-package-1", "en-US");
			
			var assetFactory:AssetFactory = new AssetFactory();
			var asset1:Asset = assetFactory.create("a.aac", assetPackage);
			var asset2:Asset = assetFactory.create("b.aac", assetPackage);
			
			assetPackage.addAsset(asset1);
			
			var list:IList = new ArrayList();
			list.add(asset2);
			
			var removed:Boolean = assetPackage.removeAssets(list);
			
			Assert.assertFalse(removed);
		}
		
		[Test]
		public function removeAssets_notEmptyAssetPackageAddedAssets_True(): void
		{
			var assetPackage:AssetPackage = new AssetPackage("asset-package-1", "en-US");
			
			var assetFactory:AssetFactory = new AssetFactory();
			var asset1:Asset = assetFactory.create("a.aac", assetPackage);
			var asset2:Asset = assetFactory.create("b.aac", assetPackage);
			
			assetPackage.addAsset(asset1);
			
			var list:IList = new ArrayList();
			list.add(asset1);
			list.add(asset2);
			
			var removed:Boolean = assetPackage.removeAssets(list);
			
			Assert.assertTrue(removed);
		}
		
		/////////////////////////////////
		// AssetPackage().size() TESTS //
		/////////////////////////////////
		
		[Test]
		public function size_emptyAssetPackage_Int(): void
		{
			var assetPackage:AssetPackage = new AssetPackage("asset-package-1", "en-US");
			var size:int = assetPackage.size();
			
			Assert.assertEquals(0, size);
		}
		
		[Test]
		public function size_notEmptyAssetPackage_Int(): void
		{
			var assetPackage:AssetPackage = new AssetPackage("asset-package-1", "en-US");
			
			var assetFactory:AssetFactory = new AssetFactory();
			var asset:Asset = assetFactory.create("a.aac", assetPackage);
			
			assetPackage.addAsset(asset);
			var size:int = assetPackage.size();
			
			Assert.assertEquals(1, size);
		}
		
	}

}