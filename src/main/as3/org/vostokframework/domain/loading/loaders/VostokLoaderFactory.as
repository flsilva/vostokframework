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
package org.vostokframework.domain.loading.loaders
{
	import org.as3utils.StringUtil;
	import org.as3collections.IList;
	import org.as3coreaddendum.errors.IllegalStateError;
	import org.as3utils.URLUtil;
	import org.vostokframework.VostokFramework;
	import org.vostokframework.VostokIdentification;
	import org.vostokframework.domain.assets.AssetType;
	import org.vostokframework.domain.loading.settings.ApplicationDomainSetting;
	import org.vostokframework.domain.loading.settings.LoadingCacheSettings;
	import org.vostokframework.domain.loading.settings.LoadingExtraSettings;
	import org.vostokframework.domain.loading.settings.LoadingMediaSettings;
	import org.vostokframework.domain.loading.settings.LoadingPolicySettings;
	import org.vostokframework.domain.loading.settings.LoadingSecuritySettings;
	import org.vostokframework.domain.loading.settings.LoadingSettings;
	import org.vostokframework.domain.loading.settings.SecurityDomainSetting;
	import org.vostokframework.domain.loading.DataParserRepository;
	import org.vostokframework.domain.loading.ILoader;
	import org.vostokframework.domain.loading.ILoaderFactory;
	import org.vostokframework.domain.loading.ILoaderState;
	import org.vostokframework.domain.loading.LoadPriority;
	import org.vostokframework.domain.loading.LoaderRepository;
	import org.vostokframework.domain.loading.policies.ElaborateLoadingPolicy;
	import org.vostokframework.domain.loading.policies.ILoadingPolicy;
	import org.vostokframework.domain.loading.states.fileloader.FileLoadingAlgorithm;
	import org.vostokframework.domain.loading.states.fileloader.IDataLoader;
	import org.vostokframework.domain.loading.states.fileloader.IFileLoadingAlgorithm;
	import org.vostokframework.domain.loading.states.fileloader.QueuedFileLoader;
	import org.vostokframework.domain.loading.states.fileloader.adapters.AutoCreateNetStreamVideo;
	import org.vostokframework.domain.loading.states.fileloader.adapters.AutoResizeNetStreamVideo;
	import org.vostokframework.domain.loading.states.fileloader.adapters.AutoStopNetStream;
	import org.vostokframework.domain.loading.states.fileloader.adapters.NativeLoaderAdapter;
	import org.vostokframework.domain.loading.states.fileloader.adapters.NativeNetStreamAdapter;
	import org.vostokframework.domain.loading.states.fileloader.adapters.NativeURLLoaderAdapter;
	import org.vostokframework.domain.loading.states.fileloader.adapters.ProgressNetStream;
	import org.vostokframework.domain.loading.states.fileloader.algorithms.DelayableFileLoadingAlgorithm;
	import org.vostokframework.domain.loading.states.fileloader.algorithms.LatencyTimeoutFileLoadingAlgorithm;
	import org.vostokframework.domain.loading.states.fileloader.algorithms.MaxAttemptsFileLoadingAlgorithm;
	import org.vostokframework.domain.loading.states.fileloader.dataparsers.XMLDataParser;
	import org.vostokframework.domain.loading.states.queueloader.QueueLoadingStatus;
	import org.vostokframework.domain.loading.states.queueloader.QueuedQueueLoader;

	import flash.display.Loader;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
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
		private var _defaultLoadingSettings:LoadingSettings;
		
		public function get dataParserRepository(): DataParserRepository { return _dataParserRepository; }
		
		public function get defaultLoadingSettings(): LoadingSettings { return _defaultLoadingSettings; }
		
		/**
		 * description
		 * 
		 * @param asset
		 * @param fileLoader
		 */
		public function VostokLoaderFactory()
		{
			initDataParserRepository();
			
			var defaultLoadingSettings:LoadingSettings = createDefaultLoadingSettings();
			setDefaultLoadingSettings(defaultLoadingSettings);
		}
		
		public function createComposite(identification:VostokIdentification, loaderRepository:LoaderRepository, priority:LoadPriority = null, globalMaxConnections:int = 6, localMaxConnections:int = 3):ILoader
		{
			if (!identification) throw new ArgumentError("Argument <identification> must not be null.");
			if (!loaderRepository) throw new ArgumentError("Argument <loaderRepository> must not be null.");
			
			if (!priority) priority = LoadPriority.MEDIUM;
			
			var policy:ILoadingPolicy = createPolicy(loaderRepository, globalMaxConnections);
			var state:ILoaderState = createCompositeLoaderState(policy, localMaxConnections);
			
			return instanciateComposite(identification, state, priority);
		}
		
		public function createLeaf(identification:VostokIdentification, src:String, type:AssetType, settings:LoadingSettings = null):ILoader
		{
			if (!identification) throw new ArgumentError("Argument <identification> must not be null.");
			if (StringUtil.isBlank(src)) throw new ArgumentError("Argument <src> must not be null nor an empty String..");
			if (!type) throw new ArgumentError("Argument <type> must not be null.");
			
			if (!settings) settings = _defaultLoadingSettings;
			
			var state:ILoaderState = createLeafLoaderState(type, src, settings);
			return instanciateLeaf(identification, state, settings.policy.priority);
		}
		
		public function setDataParserRepository(repository:DataParserRepository): void
		{
			if (!repository) throw new ArgumentError("Argument <repository> must not be null.");
			
			if (_dataParserRepository) _dataParserRepository.clear();
			_dataParserRepository = repository;
		}
		
		/**
		 * description
		 * 
		 * @param settings
		 * @throws 	ArgumentError 	if the <code>settings</code> argument is <code>null</code>.
		 */
		public function setDefaultLoadingSettings(settings:LoadingSettings): void
		{
			if (!settings) throw new ArgumentError("Argument <settings> must not be null.");
			_defaultLoadingSettings = settings;
		}
		
		protected function createCompositeLoaderState(policy:ILoadingPolicy, localMaxConnections:int):ILoaderState
		{
			var queueLoadingStatus:QueueLoadingStatus = new QueueLoadingStatus();
			var state:ILoaderState = new QueuedQueueLoader(queueLoadingStatus, policy, localMaxConnections);
			
			return state;
		}
		
		/**
		 * @private
		 */
		protected function createDefaultLoadingSettings():LoadingSettings
		{
			var cache:LoadingCacheSettings = new LoadingCacheSettings();
			var extra:LoadingExtraSettings = new LoadingExtraSettings();
			var media:LoadingMediaSettings = new LoadingMediaSettings();
			var policy:LoadingPolicySettings = new LoadingPolicySettings();
			var security:LoadingSecuritySettings = new LoadingSecuritySettings();
			
			cache.allowInternalCache = true;
			cache.killExternalCache = false;
			
			media.autoCreateVideo = false;
			media.autoResizeVideo = false;
			media.autoStopStream = false;
			media.bufferPercent = .1;
			media.bufferPercent = 0;
			
			policy.latencyTimeout = 12000;
			policy.maxAttempts = 2;
			policy.priority = LoadPriority.MEDIUM;
			
			var settings:LoadingSettings = new LoadingSettings();
			settings.cache = cache;
			settings.extra = extra;
			settings.media = media;
			settings.policy = policy;
			settings.security = security;
			
			return settings;
		}
		
		protected function createLeafLoaderState(type:AssetType, url:String, settings:LoadingSettings):ILoaderState
		{
			var killExternalCache:Boolean = settings.cache.killExternalCache;
			var baseURL:String = settings.extra.baseURL;
			
			url = parseUrl(url, killExternalCache, baseURL);
			var dataLoader:IDataLoader = createNativeDataLoader(type, url, settings);
			var algorithm:IFileLoadingAlgorithm = createFileLoadingAlgorithm(type, dataLoader, settings);
			
			return new QueuedFileLoader(algorithm);
		}
		
		protected function createFileLoadingAlgorithm(type:AssetType, dataLoader:IDataLoader, settings:LoadingSettings):IFileLoadingAlgorithm
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
			
			return algorithm;
		}
		
		protected function createNativeDataLoader(type:AssetType, url:String, settings:LoadingSettings):IDataLoader
		{
			var dataLoader:IDataLoader;
			var urlRequest:URLRequest = new URLRequest(url);
			
			switch(type)
			{
				case AssetType.IMAGE:
				{
					var loader:Loader = new Loader();
					var loaderContext:LoaderContext = createLoaderContext(settings.security);
					
					dataLoader = new NativeLoaderAdapter(loader, urlRequest, loaderContext);
					break;
				}
				
				case AssetType.CSS:
				case AssetType.JSON:
				case AssetType.TXT:
				case AssetType.XML:
				{
					var urlLoader:URLLoader = new URLLoader();
					urlLoader.dataFormat = URLLoaderDataFormat.TEXT;
					
					dataLoader = new NativeURLLoaderAdapter(urlLoader, urlRequest);
					break;
				}
				
				case AssetType.AAC:
				case AssetType.VIDEO:
				{
					var netConnection:NetConnection = new NetConnection();
					netConnection.connect(null);
					
					var netStream:NetStream = new NetStream(netConnection);
					netStream.bufferTime = settings.media.bufferTime;
					netStream.checkPolicyFile = settings.security.checkPolicyFile;
					
					dataLoader = new NativeNetStreamAdapter(netStream, netConnection, urlRequest);
					dataLoader = new ProgressNetStream(dataLoader, netStream, settings.media.bufferPercent);
					
					if (settings.media.autoStopStream) dataLoader = new AutoStopNetStream(dataLoader, netStream);
					
					if (settings.media.autoCreateVideo)
					{
						dataLoader = new AutoCreateNetStreamVideo(dataLoader, netStream);
						if (settings.media.autoResizeVideo)
						{
							dataLoader = new AutoResizeNetStreamVideo(dataLoader, netStream);
						}
					}
					
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
			
			//TODO:settings.media.audioLinkage
			
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
		
		protected function createLoaderContext(security:LoadingSecuritySettings):LoaderContext
		{
			var checkPolicyFile:Boolean = security.checkPolicyFile;
			var ignoreLocalSecurityDomain:Boolean = security.ignoreLocalSecurityDomain;
			
			var applicationDomain:ApplicationDomain = getApplicationDomain(security.applicationDomain);
			var securityDomain:SecurityDomain = getSecurityDomain(security.securityDomain);
			
			//if (ignoreLocalSecurityDomain && isLocal) securityDomain = null;//TODO:implement it
			
			return new LoaderContext(checkPolicyFile, applicationDomain, securityDomain);
		}
		
		//protected function createPolicy(loaderRepository:LoaderRepository, globalMaxConnections:int, localMaxConnections:int):ILoadingPolicy
		protected function createPolicy(loaderRepository:LoaderRepository, globalMaxConnections:int):ILoadingPolicy
		{
			var policy:ILoadingPolicy = new ElaborateLoadingPolicy(loaderRepository);
			policy.globalMaxConnections = globalMaxConnections;
			//policy.localMaxConnections = localMaxConnections;
			
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