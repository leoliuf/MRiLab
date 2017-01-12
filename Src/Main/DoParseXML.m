
function theStruct = DoParseXML(dnode)
%DoParseXML(XML_filename)
%convert XML file to a MATLAB structure.

try
   tree = xmlread(dnode);
catch me
   error('Failed to read XML file %s.',dnode);
end

% Recurse over child nodes. This could run into problems 
% with very deeply nested trees.

theStruct = parseChildNodes(tree);
theStruct.current=1;

% ----- Subfunction PARSECHILDNODES -----
function children = parseChildNodes(theNode)
% Recurse over node children.
children = [];
if theNode.hasChildNodes
   childNodes = theNode.getChildNodes;
   numChildNodes = childNodes.getLength;
   allocCell = cell(1, numChildNodes);
   children = struct('Name', allocCell,...
                     'Attributes', allocCell,...
                     'Data', allocCell,...
                     'Children', allocCell,...
                     'current', allocCell);
    i=0;
    for count = 1:numChildNodes
        theChild = childNodes.item(count-1);
        c = makeStructFromNode(theChild);
        if isempty(c)
            i=i+1;
        else
            children(count-i) = c;
        end
    end
    if i>0
        children(numChildNodes-i+1:numChildNodes)=[]; 
    end
end

% ----- Subfunction MAKESTRUCTFROMNODE -----
function nodeStruct = makeStructFromNode(theNode)
% Create structure of node info.

PC=parseChildNodes(theNode);
nodeStruct = struct('Name', char(theNode.getNodeName),...
                    'Attributes', parseAttributes(theNode),...
                    'Data', '',...
                    'Children', PC,...
                    'current',0);

if any(strcmp(methods(theNode), 'getData'))
   nodeStruct.Data = char(theNode.getData); 
else
   nodeStruct.Data = '';
end
if strcmp(nodeStruct.Name,'#text')
   nodeStruct=[];
end

% ----- Subfunction PARSEATTRIBUTES -----
function attributes = parseAttributes(theNode)
% Create attributes structure.
attributes = [];
if theNode.hasAttributes
   theAttributes = theNode.getAttributes;
   numAttributes = theAttributes.getLength;
   allocCell = cell(1, numAttributes);
   attributes = struct('Name', allocCell,...
                       'Value', allocCell);

   for count = 1:numAttributes
      attrib = theAttributes.item(count-1);
      attributes(count).Name = char(attrib.getName);
      attributes(count).Value = char(attrib.getValue);
   end
end

