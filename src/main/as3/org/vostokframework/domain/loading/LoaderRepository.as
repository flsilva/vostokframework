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
package org.vostokframework.domain.loading
{
	import org.as3collections.IIterator;
	import org.as3collections.IList;
	import org.as3collections.IMap;
	import org.as3collections.lists.ReadOnlyArrayList;
	import org.as3collections.lists.TypedList;
	import org.as3collections.maps.HashMap;
	import org.as3collections.maps.TypedMap;
	import org.as3utils.ReflectionUtil;
	import org.vostokframework.VostokIdentification;
	import org.vostokframework.domain.loading.errors.DuplicateLoaderError;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class LoaderRepository
	{
		private var _loaderMap:IMap;//key = ILoader().identification.toString() (String) | value = ILoader 
		
		public function get openedConnections():int
		{
			var it:IIterator = _loaderMap.iterator();
			var loader:ILoader;
			var sum:int;
			
			while (it.hasNext())
			{
				loader = it.next();
				sum += loader.openedConnections;
			}
			
			return sum;
		}

		/**
		 * description
		 */
		public function LoaderRepository()
		{
			_loaderMap = new TypedMap(new HashMap(), String, ILoader);
		}
		
		/**
		 * description
		 * 
		 * @param 	loader
		 * @throws 	ArgumentError 	if the <code>loader</code> argument is <code>null</code>.
		 * @throws 	org.vostokframework.loadermanagement.errors.DuplicateLoaderError 	if already exists an <code>ILoader</code> object stored with the same <code>id</code> of the provided <code>loader</code> argument.
		 * @return
		 */
		public function add(loader:ILoader): void
		{
			if (!loader) throw new ArgumentError("Argument <loader> must not be null.");
			
			if (_loaderMap.containsKey(loader.identification.toString()))
			{
				var message:String = "There is already an ILoader object stored with identification:\n";
				message += "<" + loader.identification + ">\n";
				message += "Use the method <LoaderRepository().exists()> to check if a ILoader object already exists.\n";
				message += "For further information please read the documentation section about the ILoader object.";
				
				throw new DuplicateLoaderError(loader.identification, message);
			}
			
			_loaderMap.put(loader.identification.toString(), loader);
		}
		
		/**
		 * description
		 * 
		 * @return
 		 */
		public function clear(): void
		{
			_loaderMap.clear();
		}

		/**
		 * description
		 * 
		 * @param 	loaderId    
		 * @throws 	ArgumentError 	if the <code>loaderId</code> argument is <code>null</code> or <code>empty</code>.
		 * @return
		 */
		public function exists(identification:VostokIdentification): Boolean
		{
			if (!identification) throw new ArgumentError("Argument <identification> must not be null.");
			
			return _loaderMap.containsKey(identification.toString());
		}

		/**
		 * description
		 * 
		 * @param 	loaderId    
		 * @throws 	ArgumentError 	if the <code>loaderId</code> argument is <code>null</code> or <code>empty</code>.
		 * @return
		 */
		public function find(identification:VostokIdentification): ILoader
		{
			if (!identification) throw new ArgumentError("Argument <identification> must not be null.");
			
			return _loaderMap.getValue(identification.toString());
		}

		/**
		 * description
		 * 
		 * @return
 		 */
		public function findAll(): IList
		{
			if (isEmpty()) return null;
			var l:IList = new ReadOnlyArrayList(_loaderMap.getValues().toArray());
			
			return l;
		}
		
		/**
		 * description
		 * 
		 * @return
 		 */
		/*public function findAllLoading(): IList
		{
			var list1:IList = new ArrayList(findByStatus(LoaderConnecting.INSTANCE).toArray());
			var list2:IList = new ArrayList(findByStatus(LoaderLoading.INSTANCE).toArray());
			//TODO: otimizar
			var unique:UniqueList = new UniqueList(new ArrayList());
			unique.addAll(list1);
			unique.addAll(list2);
			
			return new ReadOnlyArrayList(unique.toArray());
		}*/
		
		/**
		 * description
		 * 
		 * @return
 		 */
		/*public function findByStatus(status:LoaderState): IList
		{
			if (!status) throw new ArgumentError("Argument <status> must not be null.");
			
			var it:IIterator = _loaderMap.getValues().iterator();
			var loader:ILoader;
			var list:IList = new ArrayList();
			
			while (it.hasNext())
			{
				loader = it.next();
				if (loader.state.equals(status))
				{
					list.add(loader);
				}
			}
			
			return new ReadOnlyArrayList(list.toArray());
		}*/
		
		public function findParentLoader(childIdentification:VostokIdentification):ILoader
		{
			var it:IIterator = _loaderMap.getValues().iterator();
			var parentLoader:ILoader;
			
			while (it.hasNext())
			{
				parentLoader = it.next();
				if (parentLoader.containsChild(childIdentification)) return parentLoader;
			}
			
			return null;
		}
		
		/**
		 * description
		 * 
		 * @return
		 */
		public function isEmpty(): Boolean
		{
			return _loaderMap.isEmpty();
		}

		/**
		 * description
		 * 
		 * @param 	loaderId    
		 * @throws 	ArgumentError 	if the <code>loaderId</code> argument is <code>null</code> or <code>empty</code>.
		 * @return
		 */
		public function remove(identification:VostokIdentification): Boolean
		{
			if (!identification) throw new ArgumentError("Argument <identification> must not be null.");
			
			return _loaderMap.remove(identification.toString()) != null;
		}
		
		/**
		 * description
		 * 
		 * @param 	loaders    
		 * @throws 	ArgumentError 	if the <code>loaders</code> argument is <code>null</code>.
		 * @return
		 */
		public function removeAll(loaders:IList): Boolean
		{
			if (!loaders) throw new ArgumentError("Argument <loaders> must not be null.");
			if (loaders.isEmpty()) return false;
			
			var prevSize:int = size();
			var $loaders:IList = new TypedList(loaders, ILoader);
			var it:IIterator = $loaders.iterator();
			var loader:ILoader;
			
			while (it.hasNext())
			{
				loader = it.next();
				remove(loader.identification);
			}
			
			return size() != prevSize;
		}
		
		/**
		 * description
		 * 
		 * @return
		 */
		public function size(): int
		{
			return _loaderMap.size();
		}
		
		/**
		 * description
		 * 
		 * @return
		 */
		public function toString(): String
		{
			return "[" + ReflectionUtil.getClassName(this) + "] <" + _loaderMap.getValues() + ">";
		}
		
	}

}