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
	import org.as3utils.URLUtil;
	import org.vostokframework.VostokFramework;
	import org.vostokframework.VostokIdentification;
	import org.vostokframework.domain.assets.AssetType;
	import org.vostokframework.domain.loading.GlobalLoadingSettings;
	import org.vostokframework.domain.loading.ILoader;
	import org.vostokframework.domain.loading.ILoaderFactory;
	import org.vostokframework.domain.loading.ILoaderState;
	import org.vostokframework.domain.loading.ILoadingSettingsFactory;
	import org.vostokframework.domain.loading.LoadPriority;
	import org.vostokframework.domain.loading.LoaderRepository;
	import org.vostokframework.domain.loading.settings.LoadingCacheSettings;
	import org.vostokframework.domain.loading.settings.LoadingExtraSettings;
	import org.vostokframework.domain.loading.settings.LoadingMediaSettings;
	import org.vostokframework.domain.loading.settings.LoadingPolicySettings;
	import org.vostokframework.domain.loading.settings.LoadingSecuritySettings;
	import org.vostokframework.domain.loading.settings.LoadingSettings;
	import org.vostokframework.domain.loading.states.fileloader.IFileLoadingAlgorithm;
	import org.vostokframework.domain.loading.states.fileloader.IFileLoadingAlgorithmFactory;
	import org.vostokframework.domain.loading.states.fileloader.QueuedFileLoader;
	import org.vostokframework.domain.loading.states.fileloader.algorithms.FileLoadingAlgorithmFactory;
	import org.vostokframework.domain.loading.states.queueloader.IQueueLoadingPolicy;
	import org.vostokframework.domain.loading.states.queueloader.QueueLoadingStatus;
	import org.vostokframework.domain.loading.states.queueloader.QueuedQueueLoader;
	import org.vostokframework.domain.loading.states.queueloader.policies.SpecialHighestLowestQueueLoadingPolicy;

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
		private var _fileLoadingAlgorithmFactory:IFileLoadingAlgorithmFactory;
		private var _loadingSettingsFactory:ILoadingSettingsFactory;
		
		public function get fileLoadingAlgorithmFactory(): IFileLoadingAlgorithmFactory { return _fileLoadingAlgorithmFactory; }
		
		/**
		 * description
		 * 
		 * @param asset
		 * @param fileLoader
		 */
		public function VostokLoaderFactory(loadingSettingsFactory:ILoadingSettingsFactory)
		{
			if (!loadingSettingsFactory) throw new ArgumentError("Argument <loadingSettingsFactory> must not be null.");
			
			_loadingSettingsFactory = loadingSettingsFactory;
			_fileLoadingAlgorithmFactory = new FileLoadingAlgorithmFactory();
		}
		
		public function createComposite(identification:VostokIdentification, loaderRepository:LoaderRepository, globalLoadingSettings:GlobalLoadingSettings, priority:LoadPriority = null, localMaxConnections:int = 3):ILoader
		{
			if (!identification) throw new ArgumentError("Argument <identification> must not be null.");
			if (!loaderRepository) throw new ArgumentError("Argument <loaderRepository> must not be null.");
			
			if (!priority) priority = LoadPriority.MEDIUM;
			
			var policy:IQueueLoadingPolicy = createPolicy(loaderRepository, globalLoadingSettings);
			var state:ILoaderState = createCompositeLoaderState(policy, localMaxConnections);
			
			return instantiateComposite(identification, state, priority);
		}
		
		public function createLeaf(identification:VostokIdentification, src:String, type:AssetType, settings:LoadingSettings = null):ILoader
		{
			if (!identification) throw new ArgumentError("Argument <identification> must not be null.");
			if (StringUtil.isBlank(src)) throw new ArgumentError("Argument <src> must not be null nor an empty String..");
			if (!type) throw new ArgumentError("Argument <type> must not be null.");
			
			if (!settings) settings = _loadingSettingsFactory.create();
			
			var state:ILoaderState = createLeafLoaderState(type, src, settings);
			return instantiateLeaf(identification, state, settings.policy.priority);
		}
		
		public function setFileLoadingAlgorithmFactory(factory:IFileLoadingAlgorithmFactory): void
		{
			if (!factory) throw new ArgumentError("Argument <factory> must not be null.");
			_fileLoadingAlgorithmFactory = factory;
		}
		
		protected function createCompositeLoaderState(policy:IQueueLoadingPolicy, localMaxConnections:int):ILoaderState
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
			var algorithm:IFileLoadingAlgorithm = _fileLoadingAlgorithmFactory.create(type, url, settings);
			
			return new QueuedFileLoader(algorithm);
		}
		
		protected function instantiateComposite(identification:VostokIdentification, state:ILoaderState, priority:LoadPriority):ILoader
		{
			return new VostokLoader(identification, state, priority);
		}
		
		protected function instantiateLeaf(identification:VostokIdentification, state:ILoaderState, priority:LoadPriority):ILoader
		{
			return new VostokLoader(identification, state, priority);
		}
		
		protected function parseUrl(url:String, killExternalCache:Boolean, baseURL:String):String
		{
			if (killExternalCache) url = URLUtil.appendVar(url, VostokFramework.KILL_CACHE_VAR_NAME, String(new Date().getTime()));
			if (baseURL != null) url = baseURL + url;
			
			return url;
		}
		
		protected function createPolicy(loaderRepository:LoaderRepository, globalLoadingSettings:GlobalLoadingSettings):IQueueLoadingPolicy
		{
			var policy:IQueueLoadingPolicy = new SpecialHighestLowestQueueLoadingPolicy(loaderRepository, globalLoadingSettings);
			return policy;
		}
		
	}

}