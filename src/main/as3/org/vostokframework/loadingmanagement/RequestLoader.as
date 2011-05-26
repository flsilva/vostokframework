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
package org.vostokframework.loadingmanagement
{
	import org.as3collections.ICollection;
	import org.as3collections.IIterator;
	import org.as3collections.IList;
	import org.as3collections.lists.ArrayList;
	import org.as3collections.lists.ReadOnlyArrayList;
	import org.as3coreaddendum.system.IDisposable;
	import org.as3coreaddendum.system.IEquatable;
	import org.as3coreaddendum.system.IPriority;
	import org.as3utils.StringUtil;
	import org.vostokframework.loadingmanagement.assetloaders.AssetLoader;
	import org.vostokframework.loadingmanagement.errors.AssetLoaderNotFoundError;
	import org.vostokframework.loadingmanagement.events.AssetLoaderEvent;
	import org.vostokframework.loadingmanagement.events.RequestLoaderEvent;

	import flash.errors.IllegalOperationError;
	import flash.events.EventDispatcher;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class RequestLoader extends EventDispatcher implements IEquatable, IDisposable, IPriority
	{
		/**
		 * description
		 */
		private var _historicalStatus:IList;
		private var _id:String;
		private var _priority:LoadingRequestPriority;
		private var _queueManager:AssetLoaderQueueManager;
		private var _status:RequestLoaderStatus;
		
		/**
		 * description
		 */
		public function get historicalStatus(): IList { return new ReadOnlyArrayList(_historicalStatus.toArray()); }
		
		/**
		 * description
		 */
		public function get id(): String { return _id; }
		
		/**
		 * description
		 */
		public function get priority(): int { return _priority.ordinal; }
		
		public function set priority(value:int): void { return; }
		
		/**
		 * description
		 */
		public function get status(): RequestLoaderStatus { return _status; }
		
		/**
		 * description
		 * 
		 * @param id
		 * @param queueManager
		 * @param priority
		 */
		public function RequestLoader(id:String, queueManager:AssetLoaderQueueManager, priority:LoadingRequestPriority): void
		{
			if (StringUtil.isBlank(id)) throw new ArgumentError("Argument <id> must not be null nor an empty String.");
			if (!queueManager) throw new ArgumentError("Argument <queueManager> must not be null.");
			if (!priority) throw new ArgumentError("Argument <priority> must not be null.");
			
			_id = id;
			_queueManager = queueManager;
			_priority = priority;
			_historicalStatus = new ArrayList();
			
			addAssetLoaderListeners();
			setStatus(RequestLoaderStatus.QUEUED);
		}
		
		/**
		 * description
		 * 
		 * @return
 		 */
		public function cancel(): void
		{
			if (_status.equals(RequestLoaderStatus.CANCELED) ||
				_status.equals(RequestLoaderStatus.COMPLETE) ||
				_status.equals(RequestLoaderStatus.COMPLETE_WITH_FAILURES)) return;
			
			setStatus(RequestLoaderStatus.CANCELED);
			cancelAssetLoaders();
		}

		/**
		 * description
		 * 
		 * @param assetLoaderId
		 */
		public function cancelAssetLoader(assetLoaderId:String): void
		{
			//TODO
		}
		
		public function dispose():void
		{
			removeAssetLoaderListeners();
			_queueManager.dispose();
			_historicalStatus.clear();
			
			_historicalStatus = null;
			_priority = null;
			_queueManager = null;
			_status = null;
		}

		public function equals(other : *): Boolean
		{
			if (this == other) return true;
			if (!(other is RequestLoader)) return false;
			
			var otherLoader:RequestLoader = other as RequestLoader;
			return _id == otherLoader.id;
		}

		/**
		 * description
		 * 
		 * @return
 		 */
		public function load(): Boolean
		{
			if (_status.equals(RequestLoaderStatus.CANCELED)) throw new IllegalOperationError("The current status is <RequestLoaderStatus.CANCELED>, therefore it is no longer allowed loadings.");
			if (_status.equals(RequestLoaderStatus.COMPLETE)) throw new IllegalOperationError("The current status is <RequestLoaderStatus.COMPLETE>, therefore it is no longer allowed loadings.");
			if (_status.equals(RequestLoaderStatus.COMPLETE_WITH_FAILURES)) throw new IllegalOperationError("The current status is <RequestLoaderStatus.COMPLETE_WITH_FAILURES>, therefore it is no longer allowed loadings.");
			if (_status.equals(RequestLoaderStatus.LOADING)) throw new IllegalOperationError("The current status is <RequestLoaderStatus.LOADING>, therefore it is not allowed to start a new loading right now.");
			
			setStatus(RequestLoaderStatus.LOADING);
			loadNext();
			
			return true;
		}

		/**
		 * description
		 * 
		 * @param assetLoaders
		 */
		public function mergeAssetLoaders(assetLoaders:ICollection): void
		{
			//TODO
		}

		/**
		 * description
		 * 
		 * @param assetLoaderId
		 */
		public function resumeAssetLoader(assetLoaderId:String): void
		{
			//TODO
		}

		/**
		 * description
		 */
		public function stop(): void
		{
			if (_status.equals(RequestLoaderStatus.STOPPED) ||
				_status.equals(RequestLoaderStatus.CANCELED) ||
				_status.equals(RequestLoaderStatus.COMPLETE) ||
				_status.equals(RequestLoaderStatus.COMPLETE_WITH_FAILURES))
			{
				return;
			}
			
			setStatus(RequestLoaderStatus.STOPPED);
			stopAssetLoaders();
		}

		/**
		 * description
		 * 
		 * @param assetLoaderId
		 */
		public function stopAssetLoader(assetLoaderId:String): void
		{
			if (StringUtil.isBlank(assetLoaderId)) throw new ArgumentError("Argument <assetLoaderId> must not be null nor an empty String.");
			
			var it:IIterator = _queueManager.getAssetLoaders().iterator();
			var loader:AssetLoader;
			
			while (it.hasNext())
			{
				loader = it.next();
				if (loader.id == assetLoaderId)
				{
					try
					{
						loader.stop();
					}
					catch (error:Error)
					{
						//do nothing
					}
					
					return;
				}
			}
			
			var message:String = "There is no AssetLoader object stored with id:\n";
			message += "<" + assetLoaderId + ">";
			throw new AssetLoaderNotFoundError(assetLoaderId, message);
		}
		
		private function addAssetLoaderListeners():void
		{
			var it:IIterator = _queueManager.getAssetLoaders().iterator();
			var loader:AssetLoader;
			
			while (it.hasNext())
			{
				loader = it.next();
				loader.addEventListener(AssetLoaderEvent.STATUS_CHANGED, assetLoaderStatusChangedHandler, false, 0, true);
			}
		}
		
		private function assetLoaderStatusChangedHandler(event:AssetLoaderEvent):void
		{
			if (!_status.equals(RequestLoaderStatus.LOADING)) return;
			loadNext();
		}
		
		private function cancelAssetLoaders():void
		{
			var it:IIterator = _queueManager.getAssetLoaders().iterator();
			var assetLoader:AssetLoader;
			
			while (it.hasNext())
			{
				assetLoader = it.next();
				
				try
				{
					assetLoader.cancel();
				}
				catch (error:Error)
				{
					//do nothing
				}
			}
		}
		
		private function loadNext():void
		{
			if (isLoadingComplete())
			{
				if (_queueManager.totalFailed > 0)
				{
					setStatus(RequestLoaderStatus.COMPLETE_WITH_FAILURES);
				}
				else
				{
					setStatus(RequestLoaderStatus.COMPLETE);
				} 
				
				return;
			}
			
			var assetLoader:AssetLoader = _queueManager.getNext();
			if (assetLoader) assetLoader.load();
		}
		
		private function isLoadingComplete():Boolean
		{
			return _queueManager.activeConnections == 0 &&
					_queueManager.totalQueued == 0 &&
					_queueManager.totalStopped == 0;
		}
		
		private function removeAssetLoaderListeners():void
		{
			var it:IIterator = _queueManager.getAssetLoaders().iterator();
			var loader:AssetLoader;
			
			while (it.hasNext())
			{
				loader = it.next();
				loader.removeEventListener(AssetLoaderEvent.STATUS_CHANGED, assetLoaderStatusChangedHandler, false);
			}
		}
		
		private function stopAssetLoaders():void
		{
			var it:IIterator = _queueManager.getAssetLoaders().iterator();
			var assetLoader:AssetLoader;
			
			while (it.hasNext())
			{
				assetLoader = it.next();
				try
				{
					assetLoader.stop();
				}
				catch (error:Error)
				{
					//do nothing
				}
			}
		}

		private function setStatus(status:RequestLoaderStatus):void
		{
			_status = status;
			_historicalStatus.add(_status);
			dispatchEvent(new RequestLoaderEvent(RequestLoaderEvent.STATUS_CHANGED, _status));
		}

	}

}