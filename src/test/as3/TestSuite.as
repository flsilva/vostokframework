/*
 * Licensed under the MIT License
 * 
 * Copyright 2010 (c) Flávio Silva, http://flsilva.com
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

package 
{
	import org.vostokframework.assetmanagement.domain.AssetFactoryTests;
	import org.vostokframework.assetmanagement.domain.AssetPackageFactoryTests;
	import org.vostokframework.assetmanagement.domain.AssetPackageRepositoryTests;
	import org.vostokframework.assetmanagement.domain.AssetPackageTests;
	import org.vostokframework.assetmanagement.domain.AssetRepositoryTests;
	import org.vostokframework.assetmanagement.domain.AssetTests;
	import org.vostokframework.assetmanagement.domain.UrlAssetParserTests;
	import org.vostokframework.assetmanagement.services.AssetPackageServiceTests;
	import org.vostokframework.assetmanagement.services.AssetServiceTests;
	import org.vostokframework.loadingmanagement.domain.loaders.VostokLoaderTests;
	import org.vostokframework.loadingmanagement.domain.monitors.CompositeLoadingMonitorTests;
	import org.vostokframework.loadingmanagement.domain.monitors.CompositeLoadingMonitorTestsIntegration;
	import org.vostokframework.loadingmanagement.domain.monitors.LoadingMonitorTests;
	import org.vostokframework.loadingmanagement.domain.monitors.LoadingMonitorWrapperTestsIntegration;
	import org.vostokframework.loadingmanagement.domain.policies.ElaborateLoadingPolicyTests;
	import org.vostokframework.loadingmanagement.domain.policies.ElaborateLoadingPolicyTestsHighestLowest;
	import org.vostokframework.loadingmanagement.domain.policies.LoadingPolicyTests;
	import org.vostokframework.loadingmanagement.domain.states.fileloader.CanceledFileLoaderTests;
	import org.vostokframework.loadingmanagement.domain.states.fileloader.CompleteFileLoaderTests;
	import org.vostokframework.loadingmanagement.domain.states.fileloader.FailedFileLoaderTests;
	import org.vostokframework.loadingmanagement.domain.states.fileloader.LoadingFileLoaderTests;
	import org.vostokframework.loadingmanagement.domain.states.fileloader.LoadingFileLoaderTestsCancel;
	import org.vostokframework.loadingmanagement.domain.states.fileloader.LoadingFileLoaderTestsInstantiation;
	import org.vostokframework.loadingmanagement.domain.states.fileloader.LoadingFileLoaderTestsStop;
	import org.vostokframework.loadingmanagement.domain.states.fileloader.QueuedFileLoaderTests;
	import org.vostokframework.loadingmanagement.domain.states.fileloader.QueuedFileLoaderTestsCancel;
	import org.vostokframework.loadingmanagement.domain.states.fileloader.QueuedFileLoaderTestsLoad;
	import org.vostokframework.loadingmanagement.domain.states.fileloader.QueuedFileLoaderTestsStop;
	import org.vostokframework.loadingmanagement.domain.states.fileloader.StoppedFileLoaderTests;
	import org.vostokframework.loadingmanagement.domain.states.fileloader.StoppedFileLoaderTestsCancel;
	import org.vostokframework.loadingmanagement.domain.states.fileloader.StoppedFileLoaderTestsLoad;
	import org.vostokframework.loadingmanagement.domain.states.queueloader.CanceledQueueLoaderTests;
	import org.vostokframework.loadingmanagement.domain.states.queueloader.CanceledQueueLoaderTestsContainsChild;
	import org.vostokframework.loadingmanagement.domain.states.queueloader.CanceledQueueLoaderTestsGetChild;
	import org.vostokframework.loadingmanagement.domain.states.queueloader.CompleteQueueLoaderTests;
	import org.vostokframework.loadingmanagement.domain.states.queueloader.CompleteQueueLoaderTestsContainsChild;
	import org.vostokframework.loadingmanagement.domain.states.queueloader.CompleteQueueLoaderTestsGetChild;
	import org.vostokframework.loadingmanagement.domain.states.queueloader.LoadingQueueLoaderTests;
	import org.vostokframework.loadingmanagement.domain.states.queueloader.LoadingQueueLoaderTestsAddChild;
	import org.vostokframework.loadingmanagement.domain.states.queueloader.LoadingQueueLoaderTestsAddChildren;
	import org.vostokframework.loadingmanagement.domain.states.queueloader.LoadingQueueLoaderTestsCancel;
	import org.vostokframework.loadingmanagement.domain.states.queueloader.LoadingQueueLoaderTestsCancelChild;
	import org.vostokframework.loadingmanagement.domain.states.queueloader.LoadingQueueLoaderTestsContainsChild;
	import org.vostokframework.loadingmanagement.domain.states.queueloader.LoadingQueueLoaderTestsGetChild;
	import org.vostokframework.loadingmanagement.domain.states.queueloader.LoadingQueueLoaderTestsInstanciation;
	import org.vostokframework.loadingmanagement.domain.states.queueloader.LoadingQueueLoaderTestsLoad;
	import org.vostokframework.loadingmanagement.domain.states.queueloader.LoadingQueueLoaderTestsRemoveChild;
	import org.vostokframework.loadingmanagement.domain.states.queueloader.LoadingQueueLoaderTestsResumeChild;
	import org.vostokframework.loadingmanagement.domain.states.queueloader.LoadingQueueLoaderTestsStop;
	import org.vostokframework.loadingmanagement.domain.states.queueloader.LoadingQueueLoaderTestsStopChild;
	import org.vostokframework.loadingmanagement.domain.states.queueloader.QueuedQueueLoaderTestsAddChild;
	import org.vostokframework.loadingmanagement.domain.states.queueloader.QueuedQueueLoaderTestsAddChildren;
	import org.vostokframework.loadingmanagement.domain.states.queueloader.QueuedQueueLoaderTestsCancel;
	import org.vostokframework.loadingmanagement.domain.states.queueloader.QueuedQueueLoaderTestsCancelChild;
	import org.vostokframework.loadingmanagement.domain.states.queueloader.QueuedQueueLoaderTestsContainsChild;
	import org.vostokframework.loadingmanagement.domain.states.queueloader.QueuedQueueLoaderTestsGetChild;
	import org.vostokframework.loadingmanagement.domain.states.queueloader.QueuedQueueLoaderTestsLoad;
	import org.vostokframework.loadingmanagement.domain.states.queueloader.QueuedQueueLoaderTestsRemoveChild;
	import org.vostokframework.loadingmanagement.domain.states.queueloader.QueuedQueueLoaderTestsResumeChild;
	import org.vostokframework.loadingmanagement.domain.states.queueloader.QueuedQueueLoaderTestsStop;
	import org.vostokframework.loadingmanagement.domain.states.queueloader.QueuedQueueLoaderTestsStopChild;
	import org.vostokframework.loadingmanagement.domain.states.queueloader.StoppedQueueLoaderTests;
	import org.vostokframework.loadingmanagement.domain.states.queueloader.StoppedQueueLoaderTestsAddChild;
	import org.vostokframework.loadingmanagement.domain.states.queueloader.StoppedQueueLoaderTestsAddChildren;
	import org.vostokframework.loadingmanagement.domain.states.queueloader.StoppedQueueLoaderTestsCancel;
	import org.vostokframework.loadingmanagement.domain.states.queueloader.StoppedQueueLoaderTestsCancelChild;
	import org.vostokframework.loadingmanagement.domain.states.queueloader.StoppedQueueLoaderTestsContainsChild;
	import org.vostokframework.loadingmanagement.domain.states.queueloader.StoppedQueueLoaderTestsGetChild;
	import org.vostokframework.loadingmanagement.domain.states.queueloader.StoppedQueueLoaderTestsLoad;
	import org.vostokframework.loadingmanagement.domain.states.queueloader.StoppedQueueLoaderTestsRemoveChild;
	import org.vostokframework.loadingmanagement.domain.states.queueloader.StoppedQueueLoaderTestsResumeChild;
	import org.vostokframework.loadingmanagement.services.LoadingServiceTestsCancel;
	import org.vostokframework.loadingmanagement.services.LoadingServiceTestsExists;
	import org.vostokframework.loadingmanagement.services.LoadingServiceTestsGetAssetData;
	import org.vostokframework.loadingmanagement.services.LoadingServiceTestsGetMonitor;
	import org.vostokframework.loadingmanagement.services.LoadingServiceTestsIntegration;
	import org.vostokframework.loadingmanagement.services.LoadingServiceTestsIsLoaded;
	import org.vostokframework.loadingmanagement.services.LoadingServiceTestsIsLoading;
	import org.vostokframework.loadingmanagement.services.LoadingServiceTestsIsQueued;
	import org.vostokframework.loadingmanagement.services.LoadingServiceTestsLoad;
	import org.vostokframework.loadingmanagement.services.LoadingServiceTestsMergeAssets;
	import org.vostokframework.loadingmanagement.services.LoadingServiceTestsRemoveAssetData;
	import org.vostokframework.loadingmanagement.services.LoadingServiceTestsResume;
	import org.vostokframework.loadingmanagement.services.LoadingServiceTestsStop;

	/**
	 * @author Flávio Silva
	 */
	[Suite]
	[RunWith("org.flexunit.runners.Suite")]
	public class TestSuite
	{
		
		//org.vostokframework.assetmanagement.domain
		public var assetTests:AssetTests;
		public var assetFactoryTests:AssetFactoryTests;
		public var assetPackageTests:AssetPackageTests;
		public var assetPackageFactoryTests:AssetPackageFactoryTests;
		public var assetRepositoryTests:AssetRepositoryTests;
		public var assetPackageRepositoryTests:AssetPackageRepositoryTests;
		public var urlAssetParserTests:UrlAssetParserTests;
		
		//org.vostokframework.assetmanagement.services
		public var assetServiceTests:AssetServiceTests;
		public var assetPackageServiceTests:AssetPackageServiceTests;
		
		//org.vostokframework.loadingmanagement.domain
		public var vostokLoaderTests:VostokLoaderTests;
		
		//org.vostokframework.loadingmanagement.domain.loaders
		
		
		//org.vostokframework.loadingmanagement.domain.monitors
		public var compositeLoadingMonitorTests:CompositeLoadingMonitorTests;
		public var compositeLoadingMonitorTestsIntegration:CompositeLoadingMonitorTestsIntegration;
		public var loadingMonitorTests:LoadingMonitorTests;
		public var loadingMonitorWrapperTestsIntegration:LoadingMonitorWrapperTestsIntegration;
		
		//org.vostokframework.loadingmanagement.domain.policies
		public var loadingPolicyTests:LoadingPolicyTests;
		public var elaborateLoadingPolicyTests:ElaborateLoadingPolicyTests;
		public var elaborateLoadingPolicyTestsHighestLowest:ElaborateLoadingPolicyTestsHighestLowest;
		
		//org.vostokframework.loadingmanagement.domain.states.fileloader
		public var canceledFileLoaderTests:CanceledFileLoaderTests;
		public var completeFileLoaderTests:CompleteFileLoaderTests;
		public var failedFileLoaderTests:FailedFileLoaderTests;
		public var loadingFileLoaderTests:LoadingFileLoaderTests;
		public var loadingFileLoaderTestsCancel:LoadingFileLoaderTestsCancel;
		public var loadingFileLoaderTestsInstantiation:LoadingFileLoaderTestsInstantiation;
		public var loadingFileLoaderTestsStop:LoadingFileLoaderTestsStop;
		public var queuedFileLoaderTests:QueuedFileLoaderTests;
		public var queuedFileLoaderTestsCancel:QueuedFileLoaderTestsCancel;
		public var queuedFileLoaderTestsLoad:QueuedFileLoaderTestsLoad;
		public var queuedFileLoaderTestsStop:QueuedFileLoaderTestsStop;
		public var stoppedFileLoaderTests:StoppedFileLoaderTests;
		public var stoppedFileLoaderTestsCancel:StoppedFileLoaderTestsCancel;
		public var stoppedFileLoaderTestsLoad:StoppedFileLoaderTestsLoad;
		
		//org.vostokframework.loadingmanagement.domain.states.queueloader
		public var canceledQueueLoaderTests:CanceledQueueLoaderTests;
		public var canceledQueueLoaderTestsContainsChild:CanceledQueueLoaderTestsContainsChild;
		public var canceledQueueLoaderTestsGetChild:CanceledQueueLoaderTestsGetChild;
		
		public var completeQueueLoaderTests:CompleteQueueLoaderTests;
		public var completeQueueLoaderTestsContainsChild:CompleteQueueLoaderTestsContainsChild;
		public var completeQueueLoaderTestsGetChild:CompleteQueueLoaderTestsGetChild;
		
		public var loadingQueueLoaderTests:LoadingQueueLoaderTests;
		public var loadingQueueLoaderTestsAddChild:LoadingQueueLoaderTestsAddChild;
		public var loadingQueueLoaderTestsAddChildren:LoadingQueueLoaderTestsAddChildren;
		public var loadingQueueLoaderTestsCancel:LoadingQueueLoaderTestsCancel;
		public var loadingQueueLoaderTestsCancelChild:LoadingQueueLoaderTestsCancelChild;
		public var loadingQueueLoaderTestsContainsChild:LoadingQueueLoaderTestsContainsChild;
		public var loadingQueueLoaderTestsGetChild:LoadingQueueLoaderTestsGetChild;
		public var loadingQueueLoaderTestsInstanciation:LoadingQueueLoaderTestsInstanciation;
		public var loadingQueueLoaderTestsLoad:LoadingQueueLoaderTestsLoad;
		public var loadingQueueLoaderTestsRemoveChild:LoadingQueueLoaderTestsRemoveChild;
		public var loadingQueueLoaderTestsResumeChild:LoadingQueueLoaderTestsResumeChild;
		public var loadingQueueLoaderTestsStop:LoadingQueueLoaderTestsStop;
		public var loadingQueueLoaderTestsStopChild:LoadingQueueLoaderTestsStopChild;
		
		public var queuedQueueLoaderTestsAddChild:QueuedQueueLoaderTestsAddChild;
		public var queuedQueueLoaderTestsAddChildren:QueuedQueueLoaderTestsAddChildren;
		public var queuedQueueLoaderTestsCancel:QueuedQueueLoaderTestsCancel;
		public var queuedQueueLoaderTestsCancelChild:QueuedQueueLoaderTestsCancelChild;
		public var queuedQueueLoaderTestsContainsChild:QueuedQueueLoaderTestsContainsChild;
		public var queuedQueueLoaderTestsGetChild:QueuedQueueLoaderTestsGetChild;
		public var queuedQueueLoaderTestsLoad:QueuedQueueLoaderTestsLoad;
		public var queuedQueueLoaderTestsRemoveChild:QueuedQueueLoaderTestsRemoveChild;
		public var queuedQueueLoaderTestsResumeChild:QueuedQueueLoaderTestsResumeChild;
		public var queuedQueueLoaderTestsStop:QueuedQueueLoaderTestsStop;
		public var queuedQueueLoaderTestsStopChild:QueuedQueueLoaderTestsStopChild;
		
		public var stoppedQueueLoaderTests:StoppedQueueLoaderTests;
		public var stoppedQueueLoaderTestsAddChild:StoppedQueueLoaderTestsAddChild;
		public var stoppedQueueLoaderTestsAddChildren:StoppedQueueLoaderTestsAddChildren;
		public var stoppedQueueLoaderTestsCancel:StoppedQueueLoaderTestsCancel;
		public var stoppedQueueLoaderTestsCancelChild:StoppedQueueLoaderTestsCancelChild;
		public var stoppedQueueLoaderTestsContainsChild:StoppedQueueLoaderTestsContainsChild;
		public var stoppedQueueLoaderTestsGetChild:StoppedQueueLoaderTestsGetChild;
		public var stoppedQueueLoaderTestsLoad:StoppedQueueLoaderTestsLoad;
		public var stoppedQueueLoaderTestsRemoveChild:StoppedQueueLoaderTestsRemoveChild;
		public var stoppedQueueLoaderTestsResumeChild:StoppedQueueLoaderTestsResumeChild;
		
		//org.vostokframework.loadingmanagement.services
		public var loadingServiceTestsCancel:LoadingServiceTestsCancel;
		public var loadingServiceTestsExists:LoadingServiceTestsExists;
		public var loadingServiceTestsGetAssetData:LoadingServiceTestsGetAssetData;
		public var loadingServiceTestsGetMonitor:LoadingServiceTestsGetMonitor;
		public var loadingServiceTestsIsLoaded:LoadingServiceTestsIsLoaded;
		public var loadingServiceTestsIsLoading:LoadingServiceTestsIsLoading;
		public var loadingServiceTestsIsQueued:LoadingServiceTestsIsQueued;
		public var loadingServiceTestsLoad:LoadingServiceTestsLoad;
		public var loadingServiceTestsMergeAssets:LoadingServiceTestsMergeAssets;
		public var loadingServiceTestsRemoveAssetData:LoadingServiceTestsRemoveAssetData;
		public var loadingServiceTestsResume:LoadingServiceTestsResume;
		public var loadingServiceTestsStop:LoadingServiceTestsStop;
		public var loadingServiceTestsIntegration:LoadingServiceTestsIntegration;
		
		public function TestSuite()
		{
			
		}

	}

}