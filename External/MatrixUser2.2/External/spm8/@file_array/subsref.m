function varargout=subsref(obj,subs)
% SUBSREF Subscripted reference
% An overloaded function...
________
% Copyright (C) 2008 Wellcome Trust Centre for Neuroimaging

%
% $Id: subsref.m 2781 2009-02-24 17:56:05Z guillaume $


if isempty(subs)
    return;
end;

if ~strcmp(subs(1).type,'()'),
    if strcmp(subs(1).type,'.'),
        %error('Attempt to reference field of non-structure array.');
        %if numel(struct(obj))~=1,
        %    error('Can only access the fields of simple file_array objects.');
        %end;

        varargout = access_fields(obj,subs);
        return;
    end;
    if strcmp(subs.type,'{}'), error('Cell contents reference from a non-cell array object.'); end;
end;

if numel(subs)~=1, error('Expression too complicated');end;

dim  = [size(obj) ones(1,16)];
nd   = max(find(dim>1))-1;
sobj = struct(obj);

if length(subs.subs) < nd,
    l   = length(subs.subs);
    dim = [dim(1:(l-1)) prod(dim(l:end))];
    if numel(sobj) ~= 1,
        error('Can only reshape simple file_array objects.');
    else
        if numel(sobj.scl_slope)>1 || numel(sobj.scl_inter)>1,
            error('Can not reshape file_array objects with multiple slopes and intercepts.');
        end;
        sobj.dim = dim;
    end;
end;

do   = ones(16,1);
args = {};
for i=1:length(subs.subs),
    if ischar(subs.subs{i}),
        if ~strcmp(subs.subs{i},':'), error('This shouldn''t happen....'); end;
        args{i} = 1:dim(i);
    else
        args{i} = subs.subs{i};
    end;
    do(i) = length(args{i});
end;

if length(sobj)==1,
    t = subfun(sobj,args{:});
else
    t = zeros(do');
    for j=1:length(sobj),
        ps = [sobj(j).pos ones(1,length(args))];
        dm = [sobj(j).dim ones(1,length(args))];
        for i=1:length(args),
            msk      = find(args{i}>=ps(i) & args{i}<(ps(i)+dm(i)));
            args2{i} = msk;
            args3{i} = double(args{i}(msk))-ps(i)+1;
        end;

        t  = subsasgn(t,struct('type','()','subs',{args2}),subfun(sobj(j),args3{:}));
    end
end
varargout = {t};
return;

function t = subfun(sobj,varargin)
%sobj.dim = [sobj.dim ones(1,16)];
try
    args = cell(size(varargin));
    for i=1:length(varargin)
        args{i} = int32(varargin{i});
    end
    t = file2mat(sobj,args{:});
catch
    t = multifile2mat(sobj,varargin{:});
end
if ~isempty(sobj.scl_slope) || ~isempty(sobj.scl_inter)
    slope = 1;
    inter = 0;
    if ~isempty(sobj.scl_slope), slope = sobj.scl_slope; end;
    if ~isempty(sobj.scl_inter), inter = sobj.scl_inter; end;
    if numel(slope)>1,
        slope = resize_scales(slope,sobj.dim,varargin);
        t     = double(t).*slope;
    else
        t     = double(t)*slope;
    end;
    if numel(inter)>1,
        inter = resize_scales(inter,sobj.dim,varargin);
    end;
    t = t + inter;
end;
return;

function c = access_fields(obj,subs)
%error('Attempt to reference field of non-structure array.');
%if numel(struct(obj))~=1,
%    error('Can only access the fields of simple file_array objects.');
%end;
c    = {};
sobj = struct(obj);
for i=1:numel(sobj),
    %obj = class(sobj(i),'file_array');
    obj = sobj(i);
    switch(subs(1).subs)
    case 'fname',     t = fname(obj);
    case 'dtype',     t = dtype(obj);
    case 'offset',    t = offset(obj);
    case 'dim',       t = dim(obj);
    case 'scl_slope', t = scl_slope(obj);
    case 'scl_inter', t = scl_inter(obj);
    case 'permission',t = permission(obj);
    otherwise, error(['Reference to non-existent field "' subs(1).subs '".']);
    end;
    if numel(subs)>1,
        t = subsref(t,subs(2:end));
    end;
    c{i} = t;
end;
return;

function val = multifile2mat(sobj,varargin)
% Convert subscripts into linear index
[indx2{1:length(varargin)}] = ndgrid(varargin{:});
ind = sub2ind(sobj.dim,indx2{:});

% Work out the partition
dt  = datatypes;
sz  = dt([dt.code]==sobj.dtype).size;
mem = 400*1024*1024; % in bytes, has to be a multiple of 16 (max([dt.size]))
s   = ceil(prod(sobj.dim) * sz / mem);

% Assign indices to partitions
[x,y] = ind2sub([mem/sz s],ind(:));
c     = histc(y,1:s);
cc    = [0 reshape(cumsum(c),1,[])];

% Read data in relevant partitions
obj = sobj;
val = zeros(1,length(x));
for i=reshape(find(c),1,[])
    obj.offset = sobj.offset + mem*(i-1);
    obj.dim = [1 min(mem/sz, prod(sobj.dim)-(i-1)*mem/sz)];
    val(cc(i)+1:cc(i+1)) = file2mat(obj,int32(1),int32(x(y==i)));
end
val = reshape(val,cellfun('length',varargin));
