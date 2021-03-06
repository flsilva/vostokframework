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
package org.vostokframework.application
{
	import org.vostokframework.domain.assets.AssetFactory;
	import org.vostokframework.domain.assets.AssetPackageFactory;
	import org.vostokframework.domain.assets.AssetPackageRepository;
	import org.vostokframework.domain.assets.AssetRepository;

	import flash.errors.IllegalOperationError;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class AssetsContext
	{
		/**
		 * @private
		 */
		private static var _instance:AssetsContext = new AssetsContext();
		
		/**
		 * @private
		 */
		private var _assetFactory:AssetFactory;
		private var _assetPackageFactory:AssetPackageFactory;
		private var _assetPackageRepository:AssetPackageRepository;
		private var _assetRepository:AssetRepository;
		
		/**
		 * @private
		 */
		private static var _created :Boolean = false;
		
		{
			_created = true;
		}
		
		/**
		 * description
		 */
		public function get assetFactory(): AssetFactory { return _assetFactory; }

		/**
		 * description
		 */
		public function get assetPackageFactory(): AssetPackageFactory { return _assetPackageFactory; }

		/**
		 * description
		 */
		public function get assetPackageRepository(): AssetPackageRepository { return _assetPackageRepository; }

		/**
		 * description
		 */
		public function get assetRepository(): AssetRepository { return _assetRepository; }
		
		/**
		 * description
		 */
		public function AssetsContext()
		{
			if (_created) throw new IllegalOperationError("<AssetsContext> is a singleton class and should be accessed only by its <getInstance> method.");
			
			_assetFactory = new AssetFactory();
			_assetPackageFactory = new AssetPackageFactory();
			_assetPackageRepository = new AssetPackageRepository();
			_assetRepository = new AssetRepository();
		}
		
		/**
		 * description
		 * 
		 * @return
 		 */
		public static function getInstance(): AssetsContext
		{
			return _instance;
		}

		/**
		 * description
		 * 
		 * @param factory
		 */
		public function setAssetFactory(factory:AssetFactory): void
		{
			if (!factory) throw new ArgumentError("Argument <factory> must not be null.");
			_assetFactory = factory;
		}

		/**
		 * description
		 * 
		 * @param factory
		 */
		public function setAssetPackageFactory(factory:AssetPackageFactory): void
		{
			if (!factory) throw new ArgumentError("Argument <factory> must not be null.");
			_assetPackageFactory = factory;
		}

		/**
		 * description
		 * 
		 * @param repository
		 */
		public function setAssetPackageRepository(repository:AssetPackageRepository): void
		{
			if (!repository) throw new ArgumentError("Argument <repository> must not be null.");
			_assetPackageRepository = repository;
		}

		/**
		 * description
		 * 
		 * @param repository
		 */
		public function setAssetRepository(repository:AssetRepository): void
		{
			if (!repository) throw new ArgumentError("Argument <repository> must not be null.");
			_assetRepository = repository;
		}

	}

}