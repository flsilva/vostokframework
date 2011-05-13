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

package org.vostokframework.loadingmanagement.assetloaders
{
	import org.flexunit.Assert;
	import org.vostokframework.assetmanagement.settings.LoadingAssetPolicySettings;
	import org.vostokframework.assetmanagement.settings.LoadingAssetSettings;

	import flash.display.Loader;
	import flash.net.URLRequest;

	/**
	 * @author Flávio Silva
	 */
	public class AbstractAssetLoaderTests
	{
		
		//private var _loader:AbstractAssetLoader;
		
		public function AbstractAssetLoaderTests()
		{
			
		}
		
		/////////////////////////
		// TESTS CONFIGURATION //
		/////////////////////////
		/*
		[Before]
		public function startup(): void
		{
			AssetsContext.getInstance().setAssetRepository(new AssetRepository());
			
			var assetPackageFactory:AssetPackageFactory = new AssetPackageFactory();
			var assetPackage:AssetPackage = assetPackageFactory.create("asset-package-1", "en-US");
			
			var assetFactory:AssetFactory = new AssetFactory();
			var asset:Asset = assetFactory.create("a.aac", assetPackage);
			
			AssetsContext.getInstance().assetRepository.add(asset);
			
			var fileLoader:IFileLoader = new VostokLoader(new Loader(), new URLRequest());
			
			_loader = new AbstractAssetLoader(asset, fileLoader);
		}
		*/
		///////////////////////
		// CONSTRUCTOR TESTS //
		///////////////////////
		/*
		[Test(expects="flash.errors.IllegalOperationError")]
		public function constructor_invalidInstantiation1_ThrowsError(): void
		{
			var loader:AbstractAssetLoader = new AbstractAssetLoader(null, null);
			loader = null;
		}
		*/
		
		//////////////////////////////////
		// AbstractAssetLoader().status //
		//////////////////////////////////
		
		[Test]
		public function status_validGet_AssetLoaderStatus(): void
		{
			var fileLoader:IFileLoader = new VostokLoader(new Loader(), new URLRequest());
			var settings:LoadingAssetSettings = new LoadingAssetSettings(new LoadingAssetPolicySettings());
			var loader:AbstractAssetLoader = new AbstractAssetLoader(fileLoader, settings);
			
			Assert.assertEquals(AssetLoaderStatus.QUEUED, loader.status);
		}
		
		////////////////////////////////////////////
		// AbstractAssetLoader().historicalStatus //
		////////////////////////////////////////////
		
		[Test]
		public function historicalStatus_validGet_QUEUED(): void
		{
			var fileLoader:IFileLoader = new VostokLoader(new Loader(), new URLRequest());
			var settings:LoadingAssetSettings = new LoadingAssetSettings(new LoadingAssetPolicySettings());
			var loader:AbstractAssetLoader = new AbstractAssetLoader(fileLoader, settings);
			
			Assert.assertEquals(AssetLoaderStatus.QUEUED, loader.historicalStatus.getAt(0));
		}
		
		[Test]
		public function historicalStatus_validGet_TRYING_TO_CONNECT(): void
		{
			var settings:LoadingAssetSettings = new LoadingAssetSettings(new LoadingAssetPolicySettings());
			var fileLoader:IFileLoader = new VostokLoaderStub();
			var loader:AbstractAssetLoader = new AbstractAssetLoader(fileLoader, settings);
			
			loader.load();
			
			Assert.assertEquals(AssetLoaderStatus.TRYING_TO_CONNECT, loader.historicalStatus.getAt(1));
		}
		
		//////////////////////////////////
		// AbstractAssetLoader().cancel() //
		//////////////////////////////////
		
		[Test]
		public function cancel_checkStatus_CANCELED(): void
		{
			var settings:LoadingAssetSettings = new LoadingAssetSettings(new LoadingAssetPolicySettings());
			
			var fileLoader:IFileLoader = new VostokLoaderStub();
			var loader:AbstractAssetLoader = new AbstractAssetLoader(fileLoader, settings);
			
			loader.cancel();
			
			Assert.assertEquals(AssetLoaderStatus.CANCELED, loader.status);
		}
		
		//////////////////////////////////
		// AbstractAssetLoader().load() //
		//////////////////////////////////
		
		[Test]
		public function load_allowedLoading_True(): void
		{
			var settings:LoadingAssetSettings = new LoadingAssetSettings(new LoadingAssetPolicySettings());
			
			var fileLoader:IFileLoader = new VostokLoaderStub();
			var loader:AbstractAssetLoader = new AbstractAssetLoader(fileLoader, settings);
			
			var load:Boolean = loader.load();
			
			Assert.assertTrue(load);
		}
		
		[Test]
		public function load_allowedLoadingCheckStatus_TRYING_TO_CONNECT(): void
		{
			var settings:LoadingAssetSettings = new LoadingAssetSettings(new LoadingAssetPolicySettings());
			
			var fileLoader:IFileLoader = new VostokLoaderStub();
			var loader:AbstractAssetLoader = new AbstractAssetLoader(fileLoader, settings);
			
			loader.load();
			
			Assert.assertEquals(AssetLoaderStatus.TRYING_TO_CONNECT, loader.status);
		}
		
		//////////////////////////////////
		// AbstractAssetLoader().stop() //
		//////////////////////////////////
		
		[Test]
		public function stop_checkStatus_STOPPED(): void
		{
			var settings:LoadingAssetSettings = new LoadingAssetSettings(new LoadingAssetPolicySettings());
			
			var fileLoader:IFileLoader = new VostokLoaderStub();
			var loader:AbstractAssetLoader = new AbstractAssetLoader(fileLoader, settings);
			
			loader.stop();
			
			Assert.assertEquals(AssetLoaderStatus.STOPPED, loader.status);
		}
		
	}

}