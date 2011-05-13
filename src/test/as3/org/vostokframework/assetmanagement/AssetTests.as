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
	import org.flexunit.Assert;
	import org.vostokframework.assetmanagement.settings.LoadingAssetPolicySettings;
	import org.vostokframework.assetmanagement.settings.LoadingAssetSettings;

	/**
	 * @author Flávio Silva
	 */
	public class AssetTests
	{
		
		public function AssetTests()
		{
			
		}
		
		///////////////////////
		// CONSTRUCTOR TESTS //
		///////////////////////
		
		[Test(expects="ArgumentError")]
		public function constructor_invalidInstantiation1_ThrowsError(): void
		{
			var asset:Asset = new Asset(null, null, null, null);
			asset = null;
		}
		
		[Test(expects="ArgumentError")]
		public function constructor_invalidInstantiation2_ThrowsError(): void
		{
			var asset:Asset = new Asset("asset-1", null, null, null);
			asset = null;
		}
		
		[Test(expects="ArgumentError")]
		public function constructor_invalidInstantiation3_ThrowsError(): void
		{
			var asset:Asset = new Asset("asset-1", "asset-path/asset.xml", null, null);
			asset = null;
		}
		
		[Test(expects="ArgumentError")]
		public function constructor_invalidInstantiation4_ThrowsError(): void
		{
			var asset:Asset = new Asset("asset-1", "asset-path/asset.xml", AssetType.XML, null);
			asset = null;
		}
		
		[Test]
		public function constructor_validInstantiation_Asset(): void
		{
			var asset:Asset = new Asset("asset-1", "asset-path/asset.xml", AssetType.XML, AssetLoadingPriority.HIGH);
			asset = null;
		}
		
		////////////////////////////
		// Asset().equals() TESTS //
		////////////////////////////
		
		[Test]
		public function equals_equalObjects_True(): void
		{
			var asset1:Asset = new Asset("asset-1", "asset-path/asset.xml", AssetType.XML, AssetLoadingPriority.HIGH);
			var asset2:Asset = new Asset("asset-1", "asset-path/asset.xml", AssetType.XML, AssetLoadingPriority.HIGH);
			Assert.assertTrue(asset1.equals(asset2));
		}
		
		[Test]
		public function equals_notEqualObjects_False(): void
		{
			var asset1:Asset = new Asset("asset-1", "asset-path/asset.xml", AssetType.XML, AssetLoadingPriority.HIGH);
			var asset2:Asset = new Asset("asset-2", "asset-path/asset.xml", AssetType.XML, AssetLoadingPriority.HIGH);
			Assert.assertFalse(asset1.equals(asset2));
		}
		
		//////////////////////
		// Asset().id TESTS //
		//////////////////////
		
		[Test]
		public function id_validGet_String(): void
		{
			var asset:Asset = new Asset("asset-1", "asset-path/asset.xml", AssetType.XML, AssetLoadingPriority.HIGH);
			Assert.assertEquals("asset-1", asset.id);
		}
		
		////////////////////////////
		// Asset().priority TESTS //
		///////////////////////////
		
		[Test]
		public function priority_validGet_AssetLoadingPriority(): void
		{
			var asset:Asset = new Asset("asset-1", "asset-path/asset.xml", AssetType.XML, AssetLoadingPriority.HIGH);
			Assert.assertEquals(AssetLoadingPriority.HIGH, asset.priority);
		}
		
		////////////////////////////
		// Asset().settings TESTS //
		////////////////////////////
		
		[Test]
		public function settings_validGet_LoadingAssetSettings(): void
		{
			var policy:LoadingAssetPolicySettings = new LoadingAssetPolicySettings(5);
			var settings:LoadingAssetSettings = new LoadingAssetSettings(policy);
			
			var asset:Asset = new Asset("asset-1", "asset-path/asset.xml", AssetType.XML, AssetLoadingPriority.HIGH, settings);
			Assert.assertEquals(settings, asset.settings);
		}
		
		///////////////////////
		// Asset().src TESTS //
		///////////////////////
		
		[Test]
		public function src_validGet_String(): void
		{
			var asset:Asset = new Asset("asset-1", "asset-path/asset.xml", AssetType.XML, AssetLoadingPriority.HIGH);
			Assert.assertEquals("asset-path/asset.xml", asset.src);
		}
		
		////////////////////////
		// Asset().type TESTS //
		////////////////////////
		
		[Test]
		public function type_validGet_AssetType(): void
		{
			var asset:Asset = new Asset("asset-1", "asset-path/asset.xml", AssetType.XML, AssetLoadingPriority.HIGH);
			Assert.assertEquals(AssetType.XML, asset.type);
		}
		
		/////////////////////////////////
		// Asset().setPriority() TESTS //
		/////////////////////////////////
		
		[Test(expects="ArgumentError")]
		public function setPriority_invalidSet_ThrowsError(): void
		{
			var asset:Asset = new Asset("asset-1", "asset-path/asset.xml", AssetType.XML, AssetLoadingPriority.HIGH);
			asset.setPriority(null);
		}
		
		[Test]
		public function setPriority_validSet_Void(): void
		{
			var asset:Asset = new Asset("asset-1", "asset-path/asset.xml", AssetType.XML, AssetLoadingPriority.HIGH);
			asset.setPriority(AssetLoadingPriority.LOW);
			
			Assert.assertEquals(AssetLoadingPriority.LOW, asset.priority);
			//TODO: teste do evento disparado pela Asset
		}
		
	}

}