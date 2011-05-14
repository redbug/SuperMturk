/*******************************************
 * author	: Redbug
 * e-mail	: l314kimo@gmail.com
 * blog		: http://redbug0314.blogspot.com
 * purpose	:		
 *******************************************/

package idv.redbug.mturk.photoFetcher.agent
{
    import flash.events.Event;
    import flash.events.TimerEvent;
    import flash.utils.Timer;
    
    import idv.redbug.mturk.photo.PhotoModel;
    import idv.redbug.mturk.photoFetcher.proxy.IProxy;
    
    import org.osflash.signals.Signal;
    import org.osflash.signals.natives.NativeSignal;
    
    public class ApiAgent implements IProxy
    {
        public static const ID_FLICKR     :int = 0;
        public static const ID_GOOGLE     :int = 1;
        
        protected const MAX_RETRY         :int = 3; 
        
        protected var _photoModelList          :Vector.<PhotoModel>;
        
        protected var _sgConnectComplete  :Signal;
        protected var _sgSearchComplete   :Signal;
        protected var _sgError            :Signal;  //all api agent dispatch the error event to upper level
        protected var _sgLog              :Signal;  //all api agent dispatch the print out message to upper level
        
        protected var _isConnected        :Boolean;
        protected var _agentId            :int;
        
        protected var _numRetried_connect :int;     // the number of retry when exception occurred in connection
        protected var _numRetried_search  :int;     // the number of retry when exception occurred in search 
        
        protected var _keyword            :String;
        protected var _numResult          :int;     ////max number of google api is limited to 64 results
        
        protected var _sgTimer            :NativeSignal;
        protected var _timer              :Timer;
        
        public function ApiAgent()
        {
            _isConnected = false;
            
            _numRetried_connect = 0;
            _numRetried_search = 0;
            
            _timer = new Timer( 1000 );
            
            _sgSearchComplete = new Signal( Vector.<PhotoModel>, int );
            _sgConnectComplete = new Signal( int );
            _sgError = new Signal( String );
            _sgLog = new Signal( String );

            _sgTimer = new NativeSignal( _timer, TimerEvent.TIMER, TimerEvent );
            
            reset();
        }
        
        public function reset():void
        {
            _photoModelList = new Vector.<PhotoModel>();
        }
        
        public function destroy():void
        {
            _sgSearchComplete.removeAll();
            _sgSearchComplete = null;
            
            _sgConnectComplete.removeAll();
            _sgConnectComplete = null;
            
            _sgError.removeAll();
            _sgError = null;
            
            _sgLog.removeAll();
            _sgLog = null;
            
            _sgTimer.removeAll();
            _sgTimer = null;
            
            _photoModelList = null;
        }
        
        public function getAgentName():String
        {
            switch( _agentId ){
                case ApiAgent.ID_FLICKR:
                    return "Flickr";
                    break;
                case ApiAgent.ID_GOOGLE:
                    return "Google Image";
                    break;
                default:
                    return "Unknown agent";
            }
        }
        
        //connect to API
        public function connect():void
        {
            
        }
        
        public function onConnectReady( event:Event=null ):void
        {
        
        }
        
        public function onConnectError( event:Event=null ):void
        {
        
        }
        
        //Send searching query to API
        public function search( keyword:String, numResult:int ):void
        {
        
        }
        public function onSearchComplete( event:Event=null ):void
        {
        
        }
        
        public function onSearchError( event:Event=null ):void
        {
        
        }
        
        
        //--------------- Signal ----------------------//
        
        public function get sgSearchComplete():Signal
        {
            return _sgSearchComplete;
        }
        
        public function set sgSearchComplete(value:Signal):void
        {
            _sgSearchComplete = value;
        }
        
        public function get sgConnectComplete():Signal
        {
            return _sgConnectComplete;
        }
        
        public function set sgConnectComplete(value:Signal):void
        {
            _sgConnectComplete = value;
        }

        public function get sgError():Signal
        {
            return _sgError;
        }

        public function set sgError(value:Signal):void
        {
            _sgError = value;
        }

        public function get sgLog():Signal
        {
            return _sgLog;
        }

        public function set sgLog(value:Signal):void
        {
            _sgLog = value;
        }


    }
}