/*******************************************
 * author	: Redbug
 * e-mail	: l314kimo@gmail.com
 * blog		: http://redbug0314.blogspot.com
 * purpose	:		
 *******************************************/

package idv.redbug.mturk.photoFetcher.command
{
    import idv.redbug.mturk.photo.PhotoModel;
    import idv.redbug.mturk.photoFetcher.agent.ApiAgent;
    import idv.redbug.robotbody.commands.SimpleCommand;
    
    public class AgentCmd extends SimpleCommand
    {
        private var _agent              :ApiAgent;
        private var _keyword            :String;
        private var _numSearchResult    :int;
        private var _resultRawData      :Array;
        
        public function AgentCmd( keyword:String, numSearchResult:int, resultRawData:Array, agent:ApiAgent, delay:Number=0)
        {
            super(delay);
            this._agent = agent;
            this._keyword = keyword;
            this._numSearchResult = numSearchResult;
            this._resultRawData = resultRawData;
        }
        
        override public function execute():void
        {
            _agent.sgConnectComplete.addOnce( onConnectComplete );
            _agent.sgSearchComplete.addOnce( onSearchComplete );
            _agent.connect();
        }	
        
        private function onConnectComplete( agentId:int ):void
        {
            trace( _agent.getAgentName() + " connected!" );
            trace( "searching..." );
            _agent.search( _keyword, _numSearchResult );
        }
        
        private function onSearchComplete( photoList:Vector.<PhotoModel>, agentId:int ):void
        {
            if( photoList.length > 0 ){
                
                for each( var photo:PhotoModel in photoList )
                {
                    _resultRawData.push(photo.properties);
                }
            }
            complete();
        }
        
    }
}