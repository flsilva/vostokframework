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
package org.vostokframework.loadingmanagement.services
{
	import org.as3utils.StringUtil;
	import org.vostokframework.VostokFramework;
	import org.vostokframework.assetmanagement.domain.AssetIdentification;
	import org.vostokframework.loadingmanagement.LoadingManagementContext;
	import org.vostokframework.loadingmanagement.domain.LoaderRepository;
	import org.vostokframework.loadingmanagement.domain.LoaderStatus;
	import org.vostokframework.loadingmanagement.domain.StatefulLoader;
	import org.vostokframework.loadingmanagement.domain.errors.LoaderNotFoundError;
	import org.vostokframework.loadingmanagement.domain.errors.LoadingMonitorNotFoundError;
	import org.vostokframework.loadingmanagement.domain.loaders.QueueLoader;
	import org.vostokframework.loadingmanagement.domain.monitors.ILoadingMonitor;
	import org.vostokframework.loadingmanagement.domain.monitors.LoadingMonitorRepository;
	import org.vostokframework.loadingmanagement.report.LoadedAssetRepository;
	import org.vostokframework.loadingmanagement.report.errors.LoadedAssetDataNotFoundError;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class AssetLoadingService
	{
		/**
		 * @private
		 */
		private var _context:LoadingManagementContext;
		
		private function get loadedAssetRepository():LoadedAssetRepository { return _context.loadedAssetRepository; }
		
		private function get loaderRepository():LoaderRepository { return _context.loaderRepository; }
		
		private function get loadingMonitorRepository():LoadingMonitorRepository { return _context.loadingMonitorRepository; }
		
		/**
		 * description
		 */
		public function AssetLoadingService(): void
		{
			_context = LoadingManagementContext.getInstance();
		}
		
		/**
		 * description
		 * 
		 * @param assetId
		 * @param locale
		 * @return
		 */
		public function cancel(assetId:String, locale:String = null): Boolean
		{
			if (StringUtil.isBlank(assetId)) throw new ArgumentError("Argument <assetId> must not be null nor an empty String.");
			if (!locale) locale = VostokFramework.CROSS_LOCALE_ID; 
			
			var identification:AssetIdentification = new AssetIdentification(assetId, locale);
			var loader:StatefulLoader = loaderRepository.find(identification.toString());
			if (!loader)
			{
				var message:String = "There is no AssetLoader object stored with id:\n";
				message += "<" + identification.toString() + ">\n";
				message += "Use the method <AssetLoadingService().isLoading()>, <AssetLoadingService().isLoaded()> and <AssetLoadingService().isQueued()> to check if an AssetLoader object exists.\n";
				
				throw new LoaderNotFoundError(identification.toString(), message);
			}
			
			if (loader.status.equals(LoaderStatus.CANCELED)) return false;
			
			loader.cancel();
			
			return true;
		}

		/**
		 * description
		 * 
		 * @param assetId
		 * @param locale
		 */
		public function getAssetData(assetId:String, locale:String = null): *
		{
			if (StringUtil.isBlank(assetId)) throw new ArgumentError("Argument <assetId> must not be null nor an empty String.");
			if (!locale) locale = VostokFramework.CROSS_LOCALE_ID;
			
			var identification:AssetIdentification = new AssetIdentification(assetId, locale);
			if(!loadedAssetRepository.exists(identification))
			{
				var message:String = "There is no asset data stored for an Asset object with id:\n";
				message += "<" + identification.toString() + ">\n";
				message += "Use the method <AssetLoadingService().isLoaded()> to check if an Asset object was loaded and stored.\n";
				
				throw new LoadedAssetDataNotFoundError(identification, message);
			}
			
			return loadedAssetRepository.findAssetData(identification);
		}

		/**
		 * description
		 * 
		 * @param assetId
		 * @param locale
		 * @return
		 */
		public function getAssetLoadingMonitor(assetId:String, locale:String = null): ILoadingMonitor
		{
			if (StringUtil.isBlank(assetId)) throw new ArgumentError("Argument <assetId> must not be null nor an empty String.");
			if (!locale) locale = VostokFramework.CROSS_LOCALE_ID;
			
			var identification:AssetIdentification = new AssetIdentification(assetId, locale);
			
			var monitor:ILoadingMonitor = loadingMonitorRepository.find(identification.toString());
			if (!monitor)
			{
				var message:String = "There is no ILoadingMonitor object stored with id:\n";
				message += "<" + identification.toString() + ">\n";
				message += "Use the methods <AssetLoadingService().isLoading()>, AssetLoadingService().isLoaded()> and <AssetLoadingService().isQueued()> to check if an ILoadingMonitor object exists for an AssetLoader object with the specified <assetId> and <locale> argument.\n";
				
				throw new LoadingMonitorNotFoundError(identification.toString(), message);
			}
			
			return monitor;
		}

		/**
		 * description
		 * 
		 * @param assetId
		 * @param locale
		 * @return
		 */
		public function isLoaded(assetId:String, locale:String = null): Boolean
		{
			if (StringUtil.isBlank(assetId)) throw new ArgumentError("Argument <assetId> must not be null nor an empty String.");
			if (!locale) locale = VostokFramework.CROSS_LOCALE_ID;
			
			var identification:AssetIdentification = new AssetIdentification(assetId, locale);
			return loadedAssetRepository.exists(identification);
		}

		/**
		 * description
		 * 
		 * @param assetId
		 * @param locale
		 * @return
		 */
		public function isLoading(assetId:String, locale:String = null): Boolean
		{
			if (StringUtil.isBlank(assetId)) throw new ArgumentError("Argument <assetId> must not be null nor an empty String.");
			if (!locale) locale = VostokFramework.CROSS_LOCALE_ID; 
			
			var identification:AssetIdentification = new AssetIdentification(assetId, locale);
			var loader:StatefulLoader = loaderRepository.find(identification.toString());
			if (!loader) return false;
			
			return loader.status.equals(LoaderStatus.CONNECTING) || loader.status.equals(LoaderStatus.LOADING);
		}

		/**
		 * description
		 * 
		 * @param assetId
		 * @param locale
		 * @return
		 */
		public function isQueued(assetId:String, locale:String = null): Boolean
		{
			if (StringUtil.isBlank(assetId)) throw new ArgumentError("Argument <assetId> must not be null nor an empty String.");
			if (!locale) locale = VostokFramework.CROSS_LOCALE_ID; 
			
			var identification:AssetIdentification = new AssetIdentification(assetId, locale);
			var loader:StatefulLoader = loaderRepository.find(identification.toString());
			if (!loader) return false;
			
			return loader.status.equals(LoaderStatus.QUEUED);
		}

		/**
		 * description
		 * 
		 * @param assetId
		 * @param locale
		 * @return
		 */
		public function resume(assetId:String, locale:String = null): Boolean
		{
			if (StringUtil.isBlank(assetId)) throw new ArgumentError("Argument <assetId> must not be null nor an empty String.");
			if (!locale) locale = VostokFramework.CROSS_LOCALE_ID; 
			
			var identification:AssetIdentification = new AssetIdentification(assetId, locale);
			var loader:StatefulLoader = loaderRepository.find(identification.toString());
			if (!loader)
			{
				var message:String = "There is no AssetLoader object stored with id:\n";
				message += "<" + identification.toString() + ">\n";
				message += "Use the method <AssetLoadingService().isLoading()>, <AssetLoadingService().isLoaded()> and <AssetLoadingService().isQueued()> to check if an AssetLoader object exists.\n";
				
				throw new LoaderNotFoundError(identification.toString(), message);
			}
			
			if (isLoading(assetId, locale)) return false;
			
			var queueLoader:QueueLoader = loaderRepository.findQueueLoaderByAssetLoader(identification.toString());
			queueLoader.resumeLoader(identification.toString());
			
			return true;
		}

		/**
		 * description
		 * 
		 * @param assetId
		 * @param locale
		 * @return
		 */
		public function stop(assetId:String, locale:String = null): Boolean
		{
			if (StringUtil.isBlank(assetId)) throw new ArgumentError("Argument <assetId> must not be null nor an empty String.");
			if (!locale) locale = VostokFramework.CROSS_LOCALE_ID; 
			
			var identification:AssetIdentification = new AssetIdentification(assetId, locale);
			var loader:StatefulLoader = loaderRepository.find(identification.toString());
			if (!loader)
			{
				var message:String = "There is no AssetLoader object stored with id:\n";
				message += "<" + identification.toString() + ">\n";
				message += "Use the method <AssetLoadingService().isLoading()>, <AssetLoadingService().isLoaded()> and <AssetLoadingService().isQueued()> to check if an AssetLoader object exists.\n";
				
				throw new LoaderNotFoundError(identification.toString(), message);
			}
			
			if (loader.status.equals(LoaderStatus.STOPPED)) return false;
			
			loader.stop();
			
			return true;
		}

		/**
		 * description
		 * 
		 * @param assetId
		 * @param locale
		 * @return
		 */
		public function unload(assetId:String, locale:String = null): Boolean
		{
			return false;
		}

	}

}