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
package org.vostokframework.domain.loading.states.fileloader.algorithms
{
	import org.as3collections.IList;
	import org.vostokframework.domain.assets.AssetType;
	import org.vostokframework.domain.loading.DataParserRepository;
	import org.vostokframework.domain.loading.settings.LoadingSettings;
	import org.vostokframework.domain.loading.states.fileloader.IDataLoader;
	import org.vostokframework.domain.loading.states.fileloader.IDataLoaderFactory;
	import org.vostokframework.domain.loading.states.fileloader.IFileLoadingAlgorithm;
	import org.vostokframework.domain.loading.states.fileloader.IFileLoadingAlgorithmFactory;
	import org.vostokframework.domain.loading.states.fileloader.adapters.DataLoaderFactory;
	import org.vostokframework.domain.loading.states.fileloader.dataparsers.XMLDataParser;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class FileLoadingAlgorithmFactory implements IFileLoadingAlgorithmFactory
	{
		/**
		 * @private
 		 */
		private var _dataLoaderFactory:IDataLoaderFactory;
		private var _dataParserRepository:DataParserRepository;
		
		public function get dataLoaderFactory(): IDataLoaderFactory { return _dataLoaderFactory; }
		
		public function get dataParserRepository(): DataParserRepository { return _dataParserRepository; }
		
		/**
		 * description
		 * 
		 */
		public function FileLoadingAlgorithmFactory()
		{
			_dataLoaderFactory = new DataLoaderFactory();
			
			initDataParserRepository();
		}
		
		public function create(type:AssetType, url:String, settings:LoadingSettings):IFileLoadingAlgorithm
		{
			var dataLoader:IDataLoader = _dataLoaderFactory.create(type, url, settings);
			
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
		
		public function setDataLoaderFactory(factory:IDataLoaderFactory): void
		{
			if (!factory) throw new ArgumentError("Argument <factory> must not be null.");
			_dataLoaderFactory = factory;
		}
		
		public function setDataParserRepository(repository:DataParserRepository): void
		{
			if (!repository) throw new ArgumentError("Argument <repository> must not be null.");
			
			if (_dataParserRepository) _dataParserRepository.clear();
			_dataParserRepository = repository;
		}
		
		protected function initDataParserRepository():void
		{
			_dataParserRepository = new DataParserRepository();
			
			_dataParserRepository.add(AssetType.XML, new XMLDataParser());
		}

	}

}