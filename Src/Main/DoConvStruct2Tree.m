
function Root=DoConvStruct2Tree(S)
%convert matlab XML structure to tree structure
for i=1:length(S.Attributes)
    if strcmp(S.Attributes(i).Name,'name')
       RootName=[S.Name ' : ' S.Attributes(i).Value];
    else
       RootName=S.Name;
    end
end

Root=uitreenode('v0', '0', RootName , [], false);
ChildNode(Root,S,0);

function ChildNode(Root,S,Level)
    if isempty(S.Children)
        return;
    else
        for i=1:length(S.Children)
            Level(end+1)=i;
            ChildRoot=uitreenode('v0',Level,S.Children(i).Name, [], false);
            ChildNode(ChildRoot,S.Children(i),Level);
            Root.add(ChildRoot);
        end
    end
end

end