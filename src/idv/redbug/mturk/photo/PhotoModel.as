/*******************************************
 * author	: Redbug
 * e-mail	: l314kimo@gmail.com
 * blog		: http://redbug0314.blogspot.com
 * purpose	:		
 *******************************************/

package idv.redbug.mturk.photo
{
    public class PhotoModel
    {
        public static const CT_NONE       :int = 0;
        public static const CT_RESTAURANT :int = 1;
        public static const CT_DISH       :int = 2;
        public static const CT_LOGO       :int = 3;
        
        private var _properties  :Object;
        
        public function PhotoModel( properties:Object=null )
        {
            if( properties ){
                _properties = properties;
            } else{
                _properties = new Object();
            }
            
        }
        
        public function toString():String
        {
            var info:String = new String();
            info += "id: " + id + "\n";
            info += "title: " + title + "\n";
            info += "urlOwner: " + urlOwner + "\n";
            info += "urlSource: " + urlSource + "\n";
            info += "urlThumb: " + urlThumb + "\n";
            info += "width: " + width + "\n";
            info += "height: " + height + "\n";
            info += "description: " + removeNewLineSymbols( description ) + "\n";
            info += "tags: " + tags + "\n";
            info += "contentType: " + contentType + "\n";
            info += "from: " + from + "\n";
            
            return info;
        }
        
        private function removeNewLineSymbols( str:String ):String
        {
            var myPattern	:RegExp = /[\r\n]/g;
            return description.replace(myPattern, "");
        }
        
        public function get id():String
        {
            return _properties.id;
        }
        
        public function set id( value:String ):void
        {
            _properties.id = value;
        }
        
        public function get title():String
        {
            return _properties.title;
        }

        public function set title(value:String):void
        {
            _properties.title = value;
        }

        public function get urlOwner():String
        {
            return _properties.urlOwner;
        }

        public function set urlOwner(value:String):void
        {
            _properties.urlOwner = value;
        }

        public function get urlSource():String
        {
            return _properties.urlSource;
        }

        public function set urlSource(value:String):void
        {
            _properties.urlSource = value;
        }

        public function get urlThumb():String
        {
            return _properties.urlThumb;
        }

        public function set urlThumb(value:String):void
        {
            _properties.urlThumb = value;
        }

        public function get width():int
        {
            return _properties.width;
        }

        public function set width(value:int):void
        {
            _properties.width = value;
        }

        public function get height():int
        {
            return _properties.height;
        }

        public function set height(value:int):void
        {
            _properties.height = value;
        }

        public function get description():String
        {
            return _properties.description;
        }

        public function set description(value:String):void
        {
            _properties.description = value;
        }

        public function get tags():String
        {
            return _properties.tags;
        }

        public function set tags(value:String):void
        {
            _properties.tags = value;
        }

        public function get from():String
        {
            return _properties.from;
        }

        public function set from(value:String):void
        {
            _properties.from = value;
        }

        public function get contentType():int
        {
            return _properties.contentType;
        }
        
        public function set contentType( value:int ):void
        {
            _properties.contentType = value;
        }
        
        public function get properties():Object
        {
            return _properties;
        }
        
    }
}