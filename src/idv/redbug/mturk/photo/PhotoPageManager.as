/*******************************************
 * author	: Redbug
 * e-mail	: l314kimo@gmail.com
 * blog		: http://redbug0314.blogspot.com
 * purpose	:		
 *******************************************/

package idv.redbug.mturk.photo
{
    import flash.display.DisplayObject;
    import flash.display.SpreadMethod;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    
    import idv.redbug.robotbody.util.Toolkits;
    
    import org.osflash.signals.Signal;

    public class PhotoPageManager
    {
        private var _panel      :Sprite
        private var _spriteList :Vector.<Sprite>;
        private var _currentPage:int;
        private var _totalPage  :int;
        private var _numPerPage :int;
        private var _space      :int;

        private var _sgPageUpdate   :Signal;
        
        public function PhotoPageManager( panel:Sprite, spriteList:Vector.<Sprite>, numPerpage:int)
        {
            _panel = panel;
            
            _sgPageUpdate = new Signal();
            
            _space = _panel.stage.stageWidth / numPerpage; 
            _spriteList = spriteList;

            _numPerPage = numPerpage;
            _currentPage = 0;            
            _totalPage =  Math.ceil( _spriteList.length / Number(numPerpage) );
        }
        
        public function nextPage( event:MouseEvent=null ):void
        {
            
            if( _currentPage < _totalPage )
            {
                Toolkits.removeAllChildren( _panel );

                _currentPage++;
                _sgPageUpdate.dispatch();
                
                var start   :int = ( _currentPage - 1 ) * _numPerPage;
                var end     :int = start + _numPerPage;
                end = ( end < _spriteList.length )? end: _spriteList.length;
                
                
                for( var i:int = start; i < end; ++i )
                {
                    _panel.addChild( _spriteList[i] );
                    _spriteList[i].x = _space * ( i % _numPerPage );
                }
            }
        }
        
        public function previousPage( event:MouseEvent=null ):void
        {
            if( _currentPage > 1 )
            {
                _currentPage--;
                _sgPageUpdate.dispatch();
                
                Toolkits.removeAllChildren( _panel );
                
                var start   :int = ( _currentPage - 1 ) * _numPerPage;
                var end     :int = start + _numPerPage;
                
                for( var i:int = start; i < end; ++i )
                {
                    _panel.addChild( _spriteList[i] );
                    _spriteList[i].x = _space * ( i % _numPerPage );
                }
            }        
        }

        public function get currentPage():int
        {
            return _currentPage;
        }

        public function set currentPage(value:int):void
        {
            _currentPage = value;
        }

        public function get totalPage():int
        {
            return _totalPage;
        }

        public function set totalPage(value:int):void
        {
            _totalPage = value;
        }

        public function get sgPageUpdate():Signal
        {
            return _sgPageUpdate;
        }

        public function set sgPageUpdate(value:Signal):void
        {
            _sgPageUpdate = value;
        }
    }
}