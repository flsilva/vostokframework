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
package org.vostokframework.domain.loading.states.queueloader
{
	import org.as3collections.IList;
	import org.as3collections.IMap;
	import org.as3collections.IQueue;
	import org.as3collections.lists.ArrayList;
	import org.as3collections.maps.HashMap;
	import org.as3collections.maps.TypedMap;
	import org.as3collections.queues.PriorityIndexQueue;
	import org.as3collections.utils.ListUtil;
	import org.as3collections.utils.QueueUtil;
	import org.vostokframework.domain.loading.ILoader;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class QueueLoadingStatus
	{
		
		/**
		 * @private
		 */
		private var _allLoaders:IMap;
		private var _completeLoaders:IList;
		//private var _disposed:Boolean;
		private var _failedLoaders:IList;
		private var _loadingLoaders:IList;
		private var _queuedLoaders:IQueue;
		private var _stoppedLoaders:IList;
		
		public function get allLoaders():IMap { return _allLoaders; }
		
		public function get completeLoaders():IList { return _completeLoaders; }
		
		public function get failedLoaders():IList { return _failedLoaders; }
		
		public function get loadingLoaders():IList { return _loadingLoaders; }
		
		public function get queuedLoaders():IQueue { return _queuedLoaders; }
		
		public function get stoppedLoaders():IList { return _stoppedLoaders; }
		
		/**
		 * description
		 * 
		 * @param name
		 * @param ordinal
		 */
		public function QueueLoadingStatus()
		{
			// IMap<String, ILoader>
			// VostokIdentification().toString() used for performance optimization
			_allLoaders = new TypedMap(new HashMap(null, true), String, ILoader);
			
			_completeLoaders = ListUtil.getUniqueTypedList(new ArrayList(), ILoader);
			_failedLoaders = ListUtil.getUniqueTypedList(new ArrayList(), ILoader);
			_loadingLoaders = ListUtil.getUniqueTypedList(new ArrayList(), ILoader);
			_queuedLoaders = QueueUtil.getUniqueTypedQueue(new PriorityIndexQueue(), ILoader);
			_stoppedLoaders = ListUtil.getUniqueTypedList(new ArrayList(), ILoader);
		}
		/*
		public function clone():*
		{
			var clone:QueueLoadingStatus = new QueueLoadingStatus();
			clone.allLoaders.putAll(_allLoaders);
			clone.completeLoaders.addAll(_completeLoaders);
			clone.failedLoaders.addAll(_failedLoaders);
			clone.loadingLoaders.addAll(_loadingLoaders);
			clone.queuedLoaders.addAll(_queuedLoaders);
			clone.stoppedLoaders.addAll(stoppedLoaders);
			
			return clone;
		}
		
		public function dispose():void
		{
			if (_disposed) return;
			
			_allLoaders.clear();
			_completeLoaders.clear();
			_failedLoaders.clear();
			_loadingLoaders.clear();
			_queuedLoaders.clear();
			_stoppedLoaders.clear();
			
			_disposed = true;
			_allLoaders = null;
			_completeLoaders = null;
			_failedLoaders = null;
			_loadingLoaders = null;
			_queuedLoaders = null;
			_stoppedLoaders = null;
		}
		*/
	}

}