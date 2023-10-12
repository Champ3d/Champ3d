function vout = f_foreach(f,varargin)
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------


% --- valid argument list (to be updated each time modifying function)
arglist = {'argument_array','nb_elem'};

% --- default input value
argument_array = {};
nb_elem = [];

% --- check and update input
for i = 1:length(varargin)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': #' varargin{2*i-1} ' argument is not valid. Function arguments list : ' strjoin(arglist,', ') ' !']);
    end
end
%--------------------------------------------------------------------------
if ~isa(f,'function_handle')
    error([mfilename ': #f must be a function handle !']);
end
%--------------------------------------------------------------------------
argument_array = f_to_scellargin(argument_array);
nb_arg = length(argument_array);
nb_fargin = f_nargin(f);
%--------------------------------------------------------------------------
if nb_fargin ~= length(argument_array)
    error([mfilename ': Check number of f arguments !']);
end
%--------------------------------------------------------------------------
nb_elem__ = zeros(1,nb_arg);
size_arg = {};
len_size = {};
for i = 1:nb_arg
    size_arg{i}  = size(argument_array{i});
    len_size{i}  = length(size_arg{i});
    nb_elem__(i) = max(size_arg{i});
end
%--------------------------------------------------------------------------
if isempty(nb_elem)
    nb_elem = max(nb_elem__);
end
%--------------------------------------------------------------------------
poidelem = zeros(1,nb_arg);
for i = 1:nb_arg
    po = find(size_arg{i} == nb_elem);
    if ~isempty(po)
        poidelem(i) = po;
    end
end
%--------------------------------------------------------------------------
arg_pattern = {};
for i = 1:nb_arg
    ap = '(';
    for j = 1:len_size{i}
        if j == poidelem(i)
            ap = [ap 'id_elem,'];
        else
            ap = [ap ':,'];
        end
    end
    ap(end) = [];
    ap = [ap ')'];
    arg_pattern{i} = ap;
end
%--------------------------------------------------------------------------
% if nb_arg > 1
%     if ~all(diff(nb_elem__) == 0)
%         error([mfilename ': Check size of #argument_array !']);
%     end
% end
%--------------------------------------------------------------------------
% Test
a = {};
for i = 1:nb_fargin
    id_elem = 1;
    eval(['a{i} = argument_array{i}' arg_pattern{i} ';']);
end
%--------------------------------------------------------------------------
if nb_fargin == 0
    vtest = f();
elseif nb_fargin == 1
    vtest = f(a{1});
elseif nb_fargin == 2
    vtest = f(a{1},a{2});
elseif nb_fargin == 3
    vtest = f(a{1},a{2},a{3});
elseif nb_fargin == 4
    vtest = f(a{1},a{2},a{3},a{4});
elseif nb_fargin == 5
    vtest = f(a{1},a{2},a{3},a{4},a{5});
elseif nb_fargin == 6
    vtest = f(a{1},a{2},a{3},a{4},a{5},a{6});
end
%--------------------------------------------------------------------------
sizev = size(vtest);
vout  = zeros([nb_elem sizev]);
if numel(vtest) == 1
    len_size_vout = 1;
else
    len_size_vout = length(sizev);
end
%--------------------------------------------------------------------------
vout_pattern = '(id_elem,';
for i = 1:len_size_vout
    vout_pattern = [vout_pattern ':,'];
end
vout_pattern(end) = [];
vout_pattern = [vout_pattern ')'];
%--------------------------------------------------------------------------
for id_elem = 1:nb_elem
    %----------------------------------------------------------------------
    a = {};
    for i = 1:nb_fargin
        eval(['a{i} = argument_array{i}' arg_pattern{i} ';']);
    end
    %----------------------------------------------------------------------
    if nb_fargin == 0
        eval(['vout' vout_pattern  '= f();']);
    elseif nb_fargin == 1
        eval(['vout' vout_pattern '= f(a{1});']);
    elseif nb_fargin == 2
        eval(['vout' vout_pattern '= f(a{1},a{2});']);
    elseif nb_fargin == 3
        eval(['vout' vout_pattern '= f(a{1},a{2},a{3});']);
    elseif nb_fargin == 4
        eval(['vout' vout_pattern '= f(a{1},a{2},a{3},a{4});']);
    elseif nb_fargin == 5
        eval(['vout' vout_pattern '= f(a{1},a{2},a{3},a{4},a{5});']);
    elseif nb_fargin == 6
        eval(['vout' vout_pattern '= f(a{1},a{2},a{3},a{4},a{5},a{6});']);
    end
end
%--------------------------------------------------------------------------
vout = squeeze(vout);


