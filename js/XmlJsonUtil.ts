module util {
	export class XmlJsonUtil {
        /**
        * @class egret.XML
        * @classdesc
        * XML文件解析工具，它将XML文件解析为标准的JSON对象返回。
        * 用法类似JSON.parse(),传入一个XML字符串给XML.parse()，将能得到一个标准JSON对象。
        * 示例：
        * <pre>
        *      <root value="abc">
        *          <item value="item0"/>
        *          <item value="item1"/>
        *      </root>
        * </pre>         
        * 将解析为:
        * <pre>
        *      {
        *          "name": "root",
        *          "$value": "abc",
        *          "children": [
        *              {"name": "item", "$value": "item0"},
        *              {"name": "item", "$value": "item1"}
        *          ]
        *      }
        * </pre>   
        * 其中XML上的属性节点都使用$+"属性名"的方式表示,子节点都存放在children属性的列表里，name表示节点名称。
        * @includeExample egret/utils/XML.ts
        */
        /**
        * 解析一个XML字符串为JSON对象。
        * @method egret.XML.parse
        * @param value {string} 要解析的XML字符串。
        * @returns {any} 解析完后的JSON对象
        * @platform Web
        */
        public parse(value:string):any{
            var xmlDoc = this.parserXML(value);
            if(!xmlDoc||!xmlDoc.childNodes){
                return null;
            }
            var length:number = xmlDoc.childNodes.length;
            var found:boolean = false;
            for(var i:number=0;i<length;i++){
                var node:any = xmlDoc.childNodes[i];
                if(node.nodeType == 1){
                    found = true;
                    break;
                }
            }
            if(!found){
                return null;
            }
            var xml:any = this.parseNode(node);
            return xml;
        }
        /**
         * SAXParser
         * @deprecated
         */
        public parserXML(textxml:string):any {
            var i = 0;
            while (textxml.charAt(i) == "\n" || textxml.charAt(i) == "\t" || textxml.charAt(i) == "\r" || textxml.charAt(i) == " ") {
                i++;
            }
            
            if (i != 0) {
                textxml = textxml.substring(i, textxml.length);
            }
            
            var xmlDoc;
            
            var isSupportDOMParser: any;
            var parser: any = null;
            if (window["DOMParser"]) {
                isSupportDOMParser = true;
                parser = new DOMParser();
            } else {
                isSupportDOMParser = false;
            }
            
            if (isSupportDOMParser) {
                xmlDoc = parser.parseFromString(textxml, "text/xml");
            } else {
                xmlDoc = new ActiveXObject("Microsoft.XMLDOM");
                xmlDoc.async = "false";
                xmlDoc.loadXML(textxml);
            }
            
            if (xmlDoc == null) {
//                logwarn();
            }
            return xmlDoc;
        }
        
        private parseNode(node: any): any {
            if(!node || node.nodeType != 1) {
                return null;
            }
            var xml: any = {};
            xml.localName = node.localName;
            xml.name = node.nodeName;
            if(node.namespaceURI)
                xml.namespace = node.namespaceURI;
            if(node.prefix)
                xml.prefix = node.prefix;
            var attributes: any = node.attributes;
            var length: number = attributes.length;
            for(var i: number = 0;i < length;i++) {
                var attrib: any = attributes[i];
                var key: string = attrib.name;
                if(key.indexOf("xmlns:") == 0) {
                    continue;
                }
                xml["$" + key] = attrib.value;
            }
            var children: any = node.childNodes;
            length = children.length;
            for(i = 0;i < length;i++) {
                var childNode: any = children[i];
                var childXML: any = this.parseNode(childNode);
                if(childXML) {
                    if(!xml.children) {
                        xml.children = [];
                    }
                    childXML.parent = xml;
                    xml.children.push(childXML);
                }
            }
            if(!xml.children) {
                var text: string = node.textContent.trim();
                if(text) {
                    xml.text = text;
                }
            }
            return xml;
        }
	}
	                
	export function logwarn() {
	}
}