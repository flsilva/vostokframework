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
	import org.as3collections.ICollection;
	import org.as3collections.IIterator;
	import org.as3collections.IList;
	import org.as3collections.IListMap;
	import org.as3collections.lists.ArrayList;
	import org.as3collections.lists.TypedList;
	import org.as3collections.maps.ArrayListMap;
	import org.as3collections.utils.CollectionUtil;
	import org.as3utils.StringUtil;
	import org.vostokframework.VostokFramework;
	import org.vostokframework.VostokIdentification;
	import org.vostokframework.assetmanagement.domain.Asset;
	import org.vostokframework.assetmanagement.domain.AssetIdentification;
	import org.vostokframework.loadingmanagement.LoadingManagementContext;
	import org.vostokframework.loadingmanagement.domain.ILoader;
	import org.vostokframework.loadingmanagement.domain.ILoaderFactory;
	import org.vostokframework.loadingmanagement.domain.LoadPriority;
	import org.vostokframework.loadingmanagement.domain.LoaderRepository;
	import org.vostokframework.loadingmanagement.domain.errors.DuplicateLoaderError;
	import org.vostokframework.loadingmanagement.domain.errors.LoaderNotFoundError;
	import org.vostokframework.loadingmanagement.domain.errors.LoadingMonitorNotFoundError;
	import org.vostokframework.loadingmanagement.domain.monitors.AssetLoadingMonitorDispatcher;
	import org.vostokframework.loadingmanagement.domain.monitors.CompositeLoadingMonitor;
	import org.vostokframework.loadingmanagement.domain.monitors.ILoadingMonitor;
	import org.vostokframework.loadingmanagement.domain.monitors.LoadingMonitor;
	import org.vostokframework.loadingmanagement.domain.monitors.LoadingMonitorDispatcher;
	import org.vostokframework.loadingmanagement.domain.monitors.QueueLoadingMonitorDispatcher;
	import org.vostokframework.loadingmanagement.report.LoadedAssetReport;
	import org.vostokframework.loadingmanagement.report.LoadedAssetRepository;
	import org.vostokframework.loadingmanagement.report.errors.DuplicateLoadedAssetError;
	import org.vostokframework.loadingmanagement.report.errors.LoadedAssetDataNotFoundError;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class LoadingService
	{
		/**
		 * @private
		 */
		private var _context:LoadingManagementContext;
		
		private function get globalMonitor():ILoadingMonitor { return _context.globalQueueLoadingMonitor; }
		
		private function get globalQueueLoader():ILoader { return _context.globalQueueLoader; }
		
		private function get loadedAssetRepository():LoadedAssetRepository { return _context.loadedAssetRepository; }
		
		private function get loaderRepository():LoaderRepository { return _context.loaderRepository; }
		
		//private function get loadingMonitorRepository():LoadingMonitorRepository { return _context.loadingMonitorRepository; }
		
		private function get loaderFactory():ILoaderFactory { return _context.loaderFactory; }
		
		/**
		 * description
		 */
		public function LoadingService()
		{
			_context = LoadingManagementContext.getInstance();
		}
		
		/**
		 * description
		 * 
		 * @param queueId
		 */
		public function cancel(loaderId:String, locale:String = null): void
		{
			if (StringUtil.isBlank(loaderId)) throw new ArgumentError("Argument <loaderId> must not be null nor an empty String.");
			
			if (!locale) locale = VostokFramework.CROSS_LOCALE_ID;
			var identification:VostokIdentification = new VostokIdentification(loaderId, locale);
			
			if (!exists(loaderId, locale))
			{
				var message:String = "There is no ILoader object stored with specified arguments:\n";
				message += "<loaderId>: <" + loaderId + ">\n";
				message += "<locale>: <" + locale + ">\n";
				message += "Use method <LoadingService().exists()> to check if a ILoader object exists.\n";
				
				throw new LoaderNotFoundError(identification, message);
			}
			
			globalQueueLoader.cancelChild(identification);
		}
		
		/**
		 * description
		 * 
		 * @param queueId
		 * @return
		 */
		public function exists(loaderId:String, locale:String = null): Boolean
		{
			if (StringUtil.isBlank(loaderId)) throw new ArgumentError("Argument <loaderId> must not be null nor an empty String.");
			
			if (!locale) locale = VostokFramework.CROSS_LOCALE_ID;
			var identification:VostokIdentification = new VostokIdentification(loaderId, locale);
			
			//return loaderRepository.exists(queueId);
			return globalQueueLoader.containsChild(identification);
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
				var message:String = "There is no data cached for an Asset object with identification:\n";
				message += "<" + identification + ">\n";
				message += "Use method <LoadingService().isLoaded()> to check if an Asset object was loaded and cached.\n";
				
				throw new LoadedAssetDataNotFoundError(identification, message);
			}
			
			return loadedAssetRepository.findAssetData(identification);
		}
		
		/**
		 * description
		 * 
		 * @param queueId
		 * @return
		 */
		public function getMonitor(loaderId:String, locale:String = null): ILoadingMonitor
		{
			if (StringUtil.isBlank(loaderId)) throw new ArgumentError("Argument <loaderId> must not be null nor an empty String.");
			
			if (!locale) locale = VostokFramework.CROSS_LOCALE_ID;
			var identification:VostokIdentification = new VostokIdentification(loaderId, locale);
			
			if (!globalMonitor.containsChild(identification))
			{
				var message:String = "There is no ILoadingMonitor object stored with specified arguments:\n";
				message += "<loaderId>: <" + loaderId + ">\n";
				message += "<locale>: <" + locale + ">\n";
				message += "Use method <LoadingService().exists()> to check if an ILoadingMonitor object is mapped for a ILoader object.\n";
				
				throw new LoadingMonitorNotFoundError(message);
			}
			
			return globalMonitor.getChild(identification);;
		}

		/**
		 * description
		 * 
		 * @param assetId
		 * @param locale
		 * @return
		 */
		public function isLoaded(loaderId:String, locale:String = null): Boolean
		{
			//TODO:pensar em renomear para: containsAssetData
			if (StringUtil.isBlank(loaderId)) throw new ArgumentError("Argument <loaderId> must not be null nor an empty String.");
			if (!locale) locale = VostokFramework.CROSS_LOCALE_ID;
			
			var identification:AssetIdentification = new AssetIdentification(loaderId, locale);
			return loadedAssetRepository.exists(identification);
		}
		
		/**
		 * description
		 * 
		 * @param queueId
		 * @return
		 */
		public function isLoading(loaderId:String, locale:String = null): Boolean
		{
			if (StringUtil.isBlank(loaderId)) throw new ArgumentError("Argument <loaderId> must not be null nor an empty String.");
			
			if (!locale) locale = VostokFramework.CROSS_LOCALE_ID;
			var identification:VostokIdentification = new VostokIdentification(loaderId, locale);
			
			if (!exists(loaderId, locale))
			{
				var message:String = "There is no ILoader object stored with specified arguments:\n";
				message += "<loaderId>: <" + loaderId + ">\n";
				message += "<locale>: <" + locale + ">\n";
				message += "Use method <LoadingService().exists()> to check if a ILoader object exists.\n";
				
				throw new LoaderNotFoundError(identification, message);
			}
			
			//var state:ILoaderState = globalQueueLoader.getLoaderState(identification);
			//return state.equals(LoaderConnecting.INSTANCE) || state.equals(LoaderLoading.INSTANCE);
			
			var loader:ILoader = globalQueueLoader.getChild(identification);
			return loader.isLoading;
		}
		
		/**
		 * description
		 * 
		 * @param queueId
		 * @return
		 */
		public function isQueued(loaderId:String, locale:String = null): Boolean
		{
			if (StringUtil.isBlank(loaderId)) throw new ArgumentError("Argument <loaderId> must not be null nor an empty String.");
			
			if (!locale) locale = VostokFramework.CROSS_LOCALE_ID;
			var identification:VostokIdentification = new VostokIdentification(loaderId, locale);
			
			if (!exists(loaderId, locale))
			{
				var message:String = "There is no ILoader object stored with specified arguments:\n";
				message += "<loaderId>: <" + loaderId + ">\n";
				message += "<locale>: <" + locale + ">\n";
				message += "Use method <LoadingService().exists()> to check if a ILoader object exists.\n";
				
				throw new LoaderNotFoundError(identification, message);
			}
			
			//var state:ILoaderState = globalQueueLoader.getLoaderState(identification);
			//return state.equals(LoaderQueued.INSTANCE);
			
			var loader:ILoader = globalQueueLoader.getChild(identification);
			return loader.isQueued;
		}
		
		/**
		 * description
		 * 
		 * @param queueId
		 * @return
		 */
		public function isStopped(loaderId:String, locale:String = null): Boolean
		{
			if (StringUtil.isBlank(loaderId)) throw new ArgumentError("Argument <loaderId> must not be null nor an empty String.");
			
			if (!locale) locale = VostokFramework.CROSS_LOCALE_ID;
			var identification:VostokIdentification = new VostokIdentification(loaderId, locale);
			
			if (!exists(loaderId, locale))
			{
				var message:String = "There is no ILoader object stored with specified arguments:\n";
				message += "<loaderId>: <" + loaderId + ">\n";
				message += "<locale>: <" + locale + ">\n";
				message += "Use method <LoadingService().exists()> to check if a ILoader object exists.\n";
				
				throw new LoaderNotFoundError(identification, message);
			}
			
			//var state:ILoaderState = globalQueueLoader.getLoaderState(identification);
			//return state.equals(LoaderQueued.INSTANCE);
			
			var loader:ILoader = globalQueueLoader.getChild(identification);
			return loader.isStopped;
		}

		/**
		 * description
		 * 
		 * @param queueId
		 * @param assets
		 * @param priority
		 * @param concurrentConnections
		 * @return
		 */
		public function load(loaderId:String, assets:IList, priority:LoadPriority = null, concurrentConnections:int = 1): ILoadingMonitor
		{
			if (StringUtil.isBlank(loaderId)) throw new ArgumentError("Argument <loaderId> must not be null nor an empty String.");
			if (!assets || assets.isEmpty()) throw new ArgumentError("Argument <assets> must not be null nor empty.");
			if (concurrentConnections < 1) throw new ArgumentError("Argument <concurrentConnections> must be greater than zero. Received: <" + concurrentConnections + ">");
			
			//throws org.as3coreaddendum.ClassCastError
			//if there's any type other than Asset in <assets>
			assets = new TypedList(assets, Asset);
			
			//throws ArgumentError
			//if there's any duplicated Asset object
			validateDuplicateAsset(assets);
			
			if (!priority) priority = LoadPriority.MEDIUM;
			
			var identification:VostokIdentification = new VostokIdentification(loaderId, VostokFramework.CROSS_LOCALE_ID);
			
			if (globalQueueLoader.containsChild(identification))
			{
				var errorMessage:String = "There is already a ILoader object stored with specified arguments:\n";
				errorMessage += "<loaderId>: <" + loaderId + ">\n";
				errorMessage += "utilized locale: <" + VostokFramework.CROSS_LOCALE_ID + ">\n";
				errorMessage += "Use method <LoadingService().exists()> to check if a ILoader object already exists.\n";
				errorMessage += "For further information please read the documentation section about ILoader object.";
				
				throw new DuplicateLoaderError(identification, errorMessage);
			}
			
			//TODO:implementar mesmo erro acima porem para LoadingMonitor
			
			var globalMaxConnections:int = LoadingManagementContext.getInstance().maxConcurrentConnections;
			var queueLoader:ILoader = loaderFactory.createComposite(identification, loaderRepository, priority, globalMaxConnections, concurrentConnections);
			
			//throws org.vostokframework.loadingmanagement.report.errors.DuplicateLoadedAssetError
			//if some Asset object is already loaded and cached internally
			checkIfSomeAssetIsAlreadyLoadedAndCached(assets);
			
			//throws org.vostokframework.loadingmanagement.domain.errors.DuplicateLoaderError
			//if there is a ILoader object with the identification of any Asset inside <assets>
			var loaders:IList = createAssetLoaders(assets);
			
			queueLoader.addChildren(loaders);
			
			var assetsAndLoadersMap:IListMap = createAssetsAndLoadersMap(assets, loaders);
			var assetLoadingMonitors:IList = createAssetLoadingMonitors(assetsAndLoadersMap);
			
			var loadingMonitorDispatcher:LoadingMonitorDispatcher = new QueueLoadingMonitorDispatcher(identification.id, identification.locale);
			var monitor:ILoadingMonitor = new CompositeLoadingMonitor(queueLoader, loadingMonitorDispatcher);
			monitor.addChildren(assetLoadingMonitors);
			//loadingMonitorRepository.add(monitor);
			globalMonitor.addChild(monitor);
			
			globalQueueLoader.addChild(queueLoader);
			globalQueueLoader.load();
			
			return monitor;
		}
		
		/**
		 * description
		 * 
		 * @param queueId
		 * @param asset
		 * @param priority
		 * @param concurrentConnections
		 * @return
		 */
		public function loadSingle(loaderId:String, asset:Asset, priority:LoadPriority = null, concurrentConnections:int = 1): ILoadingMonitor
		{
			return load(loaderId, new ArrayList([asset]), priority, concurrentConnections);
		}
		
		/**
		 * description
		 * 
		 * @param queueId
		 * @param assets
		 * @return
		 */
		public function mergeAssets(loaderId:String, assets:IList, locale:String = null): ILoadingMonitor
		{
			if (StringUtil.isBlank(loaderId)) throw new ArgumentError("Argument <loaderId> must not be null nor an empty String.");
			if (!assets || assets.isEmpty()) throw new ArgumentError("Argument <assets> must not be null nor empty.");
			
			if (!locale) locale = VostokFramework.CROSS_LOCALE_ID;
			var identification:VostokIdentification = new VostokIdentification(loaderId, locale);
			
			if (!exists(loaderId, locale))
			{
				var message:String = "There is no ILoader object stored with specified arguments:\n";
				message += "<loaderId>: <" + loaderId + ">\n";
				message += "<locale>: <" + locale + ">\n";
				message += "Use method <LoadingService().exists()> to check if a ILoader object exists.\n";
				
				throw new LoaderNotFoundError(identification, message);
			}
			
			//throws org.as3coreaddendum.ClassCastError
			//if there's any type other than Asset in <assets>
			assets = new TypedList(assets, Asset);
			
			//throws ArgumentError
			//if there's any duplicate Asset object
			validateDuplicateAsset(assets);
			
			//throws org.vostokframework.loadingmanagement.report.errors.DuplicateLoadedAssetError
			//if some Asset object is already loaded and cached internally
			checkIfSomeAssetIsAlreadyLoadedAndCached(assets);
			
			//throws org.vostokframework.loadingmanagement.domain.errors.DuplicateLoaderError
			//if there is a ILoader object with the identification of any Asset inside <assets>
			var loaders:IList = createAssetLoaders(assets);
			
			var assetsAndLoadersMap:IListMap = createAssetsAndLoadersMap(assets, loaders);
			var assetLoadingMonitors:IList = createAssetLoadingMonitors(assetsAndLoadersMap);
			
			var queueLoader:ILoader = globalQueueLoader.getChild(identification);
			queueLoader.addChildren(loaders);
			
			//var monitor:IQueueLoadingMonitor = loadingMonitorRepository.find(queueLoader.id) as IQueueLoadingMonitor;//TODO:type coercion issue
			var monitor:ILoadingMonitor = globalMonitor.getChild(identification);
			monitor.addChildren(assetLoadingMonitors);
			
			return monitor;
		}
		
		/**
		 * description
		 * 
		 * @param assetId
		 * @param locale
		 * @return
		 */
		public function removeAssetData(assetId:String, locale:String = null): void
		{
			if (StringUtil.isBlank(assetId)) throw new ArgumentError("Argument <assetId> must not be null nor an empty String.");
			if (!locale) locale = VostokFramework.CROSS_LOCALE_ID; 
			
			var identification:AssetIdentification = new AssetIdentification(assetId, locale);
			
			if (!isLoaded(assetId, locale))
			{
				var message:String = "There is no data cached for an Asset object with identification:\n";
				message += "<" + identification + ">\n";
				message += "Use method <LoadingService().isLoaded()> to check if an Asset object was loaded and cached.\n";
				
				throw new LoadedAssetDataNotFoundError(identification, message);
			}
			
			loadedAssetRepository.remove(identification);
		}
		
		/**
		 * description
		 * 
		 * @param requestId
		 * @return
		 */
		public function resume(loaderId:String, locale:String = null): void
		{
			if (StringUtil.isBlank(loaderId)) throw new ArgumentError("Argument <loaderId> must not be null nor an empty String.");
			
			if (!locale) locale = VostokFramework.CROSS_LOCALE_ID;
			var identification:VostokIdentification = new VostokIdentification(loaderId, locale);
			
			if (!exists(loaderId, locale))
			{
				var message:String = "There is no ILoader object stored with specified arguments:\n";
				message += "<loaderId>: <" + loaderId + ">\n";
				message += "<locale>: <" + locale + ">\n";
				message += "Use method <LoadingService().exists()> to check if a ILoader object exists.\n";
				
				throw new LoaderNotFoundError(identification, message);
			}
			
			globalQueueLoader.resumeChild(identification);
		}

		/**
		 * description
		 * 
		 * @param requestId
		 * @return
		 */
		public function stop(loaderId:String, locale:String = null): void
		{
			if (StringUtil.isBlank(loaderId)) throw new ArgumentError("Argument <loaderId> must not be null nor an empty String.");
			
			if (!locale) locale = VostokFramework.CROSS_LOCALE_ID;
			var identification:VostokIdentification = new VostokIdentification(loaderId, locale);
			
			if (!exists(loaderId, locale))
			{
				var message:String = "There is no ILoader object stored with specified arguments:\n";
				message += "<loaderId>: <" + loaderId + ">\n";
				message += "<locale>: <" + locale + ">\n";
				message += "Use method <LoadingService().exists()> to check if a ILoader object exists.\n";
				
				throw new LoaderNotFoundError(identification, message);
			}
			
			globalQueueLoader.stopChild(identification);
		}
		
		private function checkIfSomeAssetIsAlreadyLoadedAndCached(assets:IList):void
		{
			var asset:Asset;
			var it:IIterator = assets.iterator();
			
			while (it.hasNext())
			{
				asset = it.next();
				
				if (loadedAssetRepository.exists(asset.identification))
				{
					var report:LoadedAssetReport = loadedAssetRepository.find(asset.identification);
					
					var errorMessage:String = "The Asset object with identification:\n";
					errorMessage += "<" + asset.identification + ">\n";
					errorMessage += "Is already loaded and cached internally.\n";
					errorMessage += "It was loaded by a ILoader object with identification:\n";
					errorMessage += "<" + report.queueIdentification + ">\n";
					errorMessage += "Use the method <LoadingService().isLoaded()> to find it out.\n";
					errorMessage += "Also, cached asset data can be retrieved using <LoadingService().getAssetData()>.";
					
					throw new DuplicateLoadedAssetError(asset.identification, errorMessage);
				}
			}
		}
		
		private function createAssetsAndLoadersMap(assets:IList, loaders:IList):IListMap
		{
			if (!assets || assets.isEmpty()) throw new ArgumentError("Argument <assets> must not be null nor empty.");
			if (!loaders || loaders.isEmpty()) throw new ArgumentError("Argument <loaders> must not be null nor empty.");
			if (assets.size() != loaders.size())
			{
				var errorMessage:String = "Both arguments must have same size.\n";
				errorMessage += "<assets.size()>: " + assets.size();
				errorMessage += "<loaders.size()>: " + loaders.size();
				
				throw new ArgumentError(errorMessage);
			}
			
			var map:IListMap = new ArrayListMap();
			var itAssets:IIterator = assets.iterator();
			var itLoaders:IIterator = loaders.iterator();
			
			while (itAssets.hasNext())
			{
				map.put(itAssets.next(), itLoaders.next());
			}
			
			return map;
		}
		
		private function createAssetLoaders(assets:IList):IList
		{
			var asset:Asset;
			var loader:ILoader;
			var loaders:IList = new ArrayList();
			var it:IIterator = assets.iterator();
			
			while (it.hasNext())
			{
				asset = it.next();
				loader = loaderFactory.createLeaf(asset);
				
				if (globalQueueLoader.containsChild(loader.identification))
				{
					//var childLoaderState:ILoaderState = globalQueueLoader.getLoaderState(loader.identification);
					var parent:ILoader = globalQueueLoader.getParent(loader.identification);
					
					var errorMessage:String = "There is already a ILoader object stored with identification:\n";
					errorMessage += "<" + loader.identification + ">\n";
					//errorMessage += "Its current state is: <" + childLoaderState + ">\n";
					errorMessage += "And it belongs to a parent ILoader object with identification: <" + parent.identification + ">\n";
					errorMessage += "Use method <LoadingService().exists()> to check if a ILoader object already exists for some Asset.\n";
					errorMessage += "For further information please read the documentation section about the ILoader object.";
					
					throw new DuplicateLoaderError(loader.identification, errorMessage);
				}
				
				//dispatches org.vostokframework.loadingmanagement.domain.errors.DuplicateLoaderError
				//if <loaderRepository> already contains AssetLoader object with its id
				//putAssetLoaderInRepository(loader);
				//TODO:remover codigo comentado
				loaders.add(loader);
			}
			
			return loaders;
		}
		
		private function createAssetLoadingMonitors(assetsAndLoaders:IListMap):IList
		{
			var asset:Asset;
			var loader:ILoader;
			var assetLoadingMonitor:ILoadingMonitor;
			var assetLoadingMonitors:IList = new ArrayList();
			var loadingMonitorDispatcher:LoadingMonitorDispatcher;
			var it:IIterator = assetsAndLoaders.iterator();
			
			while (it.hasNext())
			{
				loader = it.next();
				asset = it.pointer();
				
				//assetLoadingMonitor = new AssetLoadingMonitor(asset.identification, asset.type, loader, asset.settings.cache.allowInternalCache);
				loadingMonitorDispatcher = new AssetLoadingMonitorDispatcher(asset.identification.id, asset.identification.locale, asset.type);
				assetLoadingMonitor = new LoadingMonitor(loader, loadingMonitorDispatcher);
				assetLoadingMonitors.add(assetLoadingMonitor);
				
				//may throw DuplicateLoadingMonitorError
				//loadingMonitorRepository.add(assetLoadingMonitor);
				//TODO:remover codigo comentado
			}
			
			return assetLoadingMonitors;
		}
		
		private function validateDuplicateAsset(assets:IList):void
		{
			var duplicate:ICollection = CollectionUtil.getDuplicate(assets);
			
			if (!duplicate.isEmpty())
			{
				var errorMessage:String = "Argument <assets> must not have duplicate elements.\n";
				errorMessage += "The following duplicates were found:\n";
				errorMessage += duplicate;
				
				throw new ArgumentError(errorMessage);
			}
		}
		
	}

}