/*
 * Licensed under the MIT License
 * 
 * Copyright 2011 (c) Flávio Silva, flsilva.com
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
	import org.as3collections.ICollection;
	import org.as3collections.IIterator;
	import org.vostokframework.application.AssetsContext;
	import org.vostokframework.application.LoadingContext;
	import org.vostokframework.configuration.AssetConfiguration;
	import org.vostokframework.configuration.AssetPackageConfiguration;
	import org.vostokframework.configuration.VostokFrameworkConfiguration;
	import org.vostokframework.domain.assets.AssetPackage;
	import org.vostokframework.domain.loading.settings.LoadingSettings;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class ConfigurationService
	{
		/**
		 * @private
		 */
		private var _assetsContext: AssetsContext;
		private var _loadingContext: LoadingContext;
		
		/**
		 * description
		 */
		public function ConfigurationService()
		{
			_assetsContext = AssetsContext.getInstance();
			_loadingContext = LoadingContext.getInstance();
		}
		
		public function configure(configuration:VostokFrameworkConfiguration): void
		{
			if (!configuration) throw new ArgumentError("Argument <configuration> must not be null.");
			
			configureDefaultLoadingSettings(configuration.defaultSettings);
			configureAssetPackages(configuration.packages);
		}
		
		protected function configureAssetPackages(packages:ICollection):void
		{
			if (!packages || packages.isEmpty()) return;
			
			var it:IIterator = packages.iterator();
			var packageConfiguration:AssetPackageConfiguration;
			var assetPackage:AssetPackage;
			
			var assetPackageService:AssetPackageService = new AssetPackageService();
			
			while (it.hasNext())
			{
				packageConfiguration = it.next();
				assetPackage = assetPackageService.createAssetPackage(packageConfiguration.id, packageConfiguration.locale);
				
				configureAssets(assetPackage, packageConfiguration.assets);
			}
		}
		
		protected function configureAssets(assetPackage:AssetPackage, assets:ICollection):void
		{
			if (!assets || assets.isEmpty()) return;
			
			var it:IIterator = assets.iterator();
			var assetConfiguration:AssetConfiguration;
			
			var assetService:AssetService = new AssetService();
			
			while (it.hasNext())
			{
				assetConfiguration = it.next();
				assetService.createAsset(assetConfiguration.src, assetPackage, assetConfiguration.settings, assetConfiguration.id, assetConfiguration.type);
			}
		}
		
		protected function configureDefaultLoadingSettings(defaultSettings:LoadingSettings):void
		{
			if (!defaultSettings) return;
			_loadingContext.loadingSettingsFactory.setDefaultLoadingSettings(defaultSettings);
		}

	}

}