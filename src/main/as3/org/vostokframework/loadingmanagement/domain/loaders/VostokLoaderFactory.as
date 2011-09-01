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
package org.vostokframework.loadingmanagement.domain.loaders
{
	import org.as3collections.IList;
	import org.as3coreaddendum.errors.IllegalStateError;
	import org.as3utils.URLUtil;
	import org.vostokframework.VostokFramework;
	import org.vostokframework.VostokIdentification;
	import org.vostokframework.assetmanagement.domain.Asset;
	import org.vostokframework.assetmanagement.domain.AssetType;
	import org.vostokframework.assetmanagement.domain.settings.ApplicationDomainSetting;
	import org.vostokframework.assetmanagement.domain.settings.AssetLoadingSecuritySettings;
	import org.vostokframework.assetmanagement.domain.settings.AssetLoadingSettings;
	import org.vostokframework.assetmanagement.domain.settings.SecurityDomainSetting;
	import org.vostokframework.loadingmanagement.domain.DataParserRepository;
	import org.vostokframework.loadingmanagement.domain.ILoader;
	import org.vostokframework.loadingmanagement.domain.ILoaderFactory;
	import org.vostokframework.loadingmanagement.domain.ILoaderState;
	import org.vostokframework.loadingmanagement.domain.LoadPriority;
	import org.vostokframework.loadingmanagement.domain.LoaderRepository;
	import org.vostokframework.loadingmanagement.domain.policies.ElaborateLoadingPolicy;
	import org.vostokframework.loadingmanagement.domain.policies.ILoadingPolicy;
	import org.vostokframework.loadingmanagement.domain.states.fileloader.FileLoadingAlgorithm;
	import org.vostokframework.loadingmanagement.domain.states.fileloader.IFileLoadingAlgorithm;
	import org.vostokframework.loadingmanagement.domain.states.fileloader.NativeDataLoader;
	import org.vostokframework.loadingmanagement.domain.states.fileloader.QueuedFileLoader;
	import org.vostokframework.loadingmanagement.domain.states.fileloader.adapters.NativeLoaderAdapter;
	import org.vostokframework.loadingmanagement.domain.states.fileloader.adapters.NativeURLLoaderAdapter;
	import org.vostokframework.loadingmanagement.domain.states.fileloader.algorithms.DelayableFileLoadingAlgorithm;
	import org.vostokframework.loadingmanagement.domain.states.fileloader.algorithms.LatencyTimeoutFileLoadingAlgorithm;
	import org.vostokframework.loadingmanagement.domain.states.fileloader.algorithms.MaxAttemptsFileLoadingAlgorithm;
	import org.vostokframework.loadingmanagement.domain.states.fileloader.dataparsers.XMLDataParser;
	import org.vostokframework.loadingmanagement.domain.states.queueloader.QueueLoadingStatus;
	import org.vostokframework.loadingmanagement.domain.states.queueloader.QueuedQueueLoader;

	import flash.display.Loader;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.system.SecurityDomain;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class VostokLoaderFactory implements ILoaderFactory
	{
		/**
		 * @private
		 */
		private var _dataParserRepository:DataParserRepository;
		
		public function get dataParserRepository(): DataParserRepository { return _dataParserRepository; }
		
		/**
		 * description
		 * 
		 * @param asset
		 * @param fileLoader
		 */
		public function VostokLoaderFactory()
		{
			initDataParserRepository();
		}
		
		public function createComposite(identification:VostokIdentification, loaderRepository:LoaderRepository, priority:LoadPriority = null, globalMaxConnections:int = 6, localMaxConnections:int = 3):ILoader
		{
			if (!priority) priority = LoadPriority.MEDIUM;
			
			var policy:ILoadingPolicy = createPolicy(loaderRepository, globalMaxConnections, localMaxConnections);
			var state:ILoaderState = createCompositeLoaderState(policy);
			
			return instanciateComposite(identification, state, priority);
		}
		
		public function createLeaf(asset:Asset):ILoader
		{
			var state:ILoaderState = createLeafLoaderState(asset.type, asset.src, asset.settings);
			return instanciateLeaf(asset.identification, state, asset.priority);
		}
		
		public function setDataParserRepository(repository:DataParserRepository): void
		{
			if (!repository) throw new ArgumentError("Argument <repository> must not be null.");
			
			if (_dataParserRepository) _dataParserRepository.clear();
			_dataParserRepository = repository;
		}
		
		protected function createCompositeLoaderState(policy:ILoadingPolicy):ILoaderState
		{
			var queueLoadingStatus:QueueLoadingStatus = new QueueLoadingStatus();
			var state:ILoaderState = new QueuedQueueLoader(queueLoadingStatus, policy);
			
			return state;
		}
		
		protected function createLeafLoaderState(type:AssetType, url:String, settings:AssetLoadingSettings):ILoaderState
		{
			var killExternalCache:Boolean = settings.cache.killExternalCache;
			var baseURL:String = settings.extra.baseURL;
			
			url = parseUrl(url, killExternalCache, baseURL);
			var dataLoader:NativeDataLoader = createNativeDataLoader(type, url, settings);
			var algorithm:IFileLoadingAlgorithm = createFileLoadingAlgorithm(type, dataLoader, settings);
			
			return new QueuedFileLoader(algorithm);
		}
		
		protected function createFileLoadingAlgorithm(type:AssetType, dataLoader:NativeDataLoader, settings:AssetLoadingSettings):IFileLoadingAlgorithm
		{
			var algorithm:IFileLoadingAlgorithm = new FileLoadingAlgorithm(dataLoader);
			algorithm = new LatencyTimeoutFileLoadingAlgorithm(algorithm, settings.policy.latencyTimeout);
			algorithm = new DelayableFileLoadingAlgorithm(algorithm);
			algorithm = new MaxAttemptsFileLoadingAlgorithm(algorithm, settings.policy.maxAttempts);
			
			if (_dataParserRepository)
			{
				var parsers:IList = _dataParserRepository.find(type);
				algorithm.addParsers(parsers);
			}
			
			//TODO:settings.extra.userDataContainer
			//TODO:settings.extra.userTotalBytes
			
			//TODO:settings.media.audioLinkage
			//TODO:settings.media.autoCreateVideo
			//TODO:settings.media.autoResizeVideo
			//TODO:settings.media.autoStopStream
			//TODO:settings.media.bufferPercent
			//TODO:settings.media.bufferTime
			
			return algorithm;
		}
		
		protected function createNativeDataLoader(type:AssetType, url:String, settings:AssetLoadingSettings):NativeDataLoader
		{
			var dataLoader:NativeDataLoader;
			
			switch(type)
			{
				case AssetType.IMAGE:
				{
					var loader:Loader = new Loader();
					var loaderRequest:URLRequest = new URLRequest(url);
					var loaderContext:LoaderContext = createLoaderContext(settings.security);
					
					dataLoader = new NativeLoaderAdapter(loader, loaderRequest, loaderContext);
					break;
				}
				
				case AssetType.XML:
				{
					var urlLoader:URLLoader = new URLLoader();
					var urlLoaderRequest:URLRequest = new URLRequest(url);
					
					dataLoader = new NativeURLLoaderAdapter(urlLoader, urlLoaderRequest);
					break;
				}
				
			}
			
			if (!dataLoader)
			{
				var errorMessage:String = "It was not possible to create a NativeDataLoader object for the received type:\n";
				errorMessage = "<type>: " + type + "\n";
				errorMessage = "<url>: " + url + "\n";
				
				throw new IllegalStateError(errorMessage);
			}
			
			return dataLoader;
		}
		
		protected function instanciateComposite(identification:VostokIdentification, state:ILoaderState, priority:LoadPriority):ILoader
		{
			return new VostokLoader(identification, state, priority);
		}
		
		protected function instanciateLeaf(identification:VostokIdentification, state:ILoaderState, priority:LoadPriority):ILoader
		{
			return new VostokLoader(identification, state, priority);
		}
		
		protected function parseUrl(url:String, killExternalCache:Boolean, baseURL:String):String
		{
			if (killExternalCache) url = URLUtil.appendVar(url, VostokFramework.KILL_CACHE_VAR_NAME, String(new Date().getTime()));
			if (baseURL != null) url = baseURL + url;
			
			return url;
		}
		
		protected function createLoaderContext(security:AssetLoadingSecuritySettings):LoaderContext
		{
			var checkPolicyFile:Boolean = security.checkPolicyFile;
			var ignoreLocalSecurityDomain:Boolean = security.ignoreLocalSecurityDomain;
			
			var applicationDomain:ApplicationDomain = getApplicationDomain(security.applicationDomain);
			var securityDomain:SecurityDomain = getSecurityDomain(security.securityDomain);
			
			//if (ignoreLocalSecurityDomain && isLocal) securityDomain = null;//TODO:implement it
			
			return new LoaderContext(checkPolicyFile, applicationDomain, securityDomain);
		}
		
		protected function createPolicy(loaderRepository:LoaderRepository, globalMaxConnections:int, localMaxConnections:int):ILoadingPolicy
		{
			var policy:ILoadingPolicy = new ElaborateLoadingPolicy(loaderRepository);
			policy.globalMaxConnections = globalMaxConnections;
			policy.localMaxConnections = localMaxConnections;
			
			return policy;
		}
		
		protected function getApplicationDomain(setting:ApplicationDomainSetting):ApplicationDomain
		{
			if (!setting) return null;
			
			var applicationDomain:ApplicationDomain;
			
			if (setting.equals(ApplicationDomainSetting.APART))
			{
				applicationDomain = new ApplicationDomain();
			}
			else if (setting.equals(ApplicationDomainSetting.CHILD))
			{
				applicationDomain = new ApplicationDomain(ApplicationDomain.currentDomain);
			}
			else if (setting.equals(ApplicationDomainSetting.CURRENT))
			{
				applicationDomain = ApplicationDomain.currentDomain;
			}
			
			return applicationDomain;
		}
		
		protected function getSecurityDomain(setting:SecurityDomainSetting):SecurityDomain
		{
			if (!setting) return null;
			
			var securityDomain:SecurityDomain;
			
			if (setting.equals(SecurityDomainSetting.CURRENT))
			{
				securityDomain = SecurityDomain.currentDomain;
			}
			
			return securityDomain;
		}
		
		protected function initDataParserRepository():void
		{
			_dataParserRepository = new DataParserRepository();
			
			_dataParserRepository.add(AssetType.XML, new XMLDataParser());
		}
		
	}

}