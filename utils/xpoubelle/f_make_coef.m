function coef = f_make_coef(varargin)
% Allow separated declaration of coefficient with different dependency.
% 'f' : dependency function
%     + if a constant -> chose 'f' = value, ex. 'f' = 5
%     + give function handle for 'f'
%          * ex: 'f',@(a,b,c) a+b+c
% 'depend_on' :
%     + 'elem_temp' : (average) element temperature
%     + 'node_temp' : nodal temperature
%     + 'b' : induction (flux density)
%     + 'h' : magnetic field strength
%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2023
% as a contribution to Champ3d code.
%--------------------------------------------------------------------------
% Champ3d is copyright (c) 2023-2025 H-K. Bui.
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'f','depend_on','varargin_list',...
           'coef_size','coef_type','input_size'};

% --- default input value
f = [];
depend_on = [];
varargin_list = {};
% -
coef_type = 'single';
coef_size = [];
input_size = [];

% --- valid depend_on
valid_depend_on = {'celem','cface', ...
    'bv','jv','hv','pv','av','phiv','tv','omev','tempv',...
    'bs','js','hs','ps','as','phis','ts','omes','temps'};

% --- valid coef_size
% valid_coef_type = { '1 x 1', '1', 'scalar', ...
%                     '3 x 1', '1 x 3', 'vector', ...
%                     'nb_elem x 1', 'n x 1', 'array_of_scalar', ...
%                     'nb_elem x 3', 'n x 3', 'array_of_vector', ...
%                     '3 x 3', 'gtensor', ...
%                     'nb_elem x 3 x 3', 'n x 3 x 3', 'array_of_gtensor', ...
%                     '1 x ltensor', 'ltensor', ...
%                     'nb_elem x ltensor', 'n x ltensor', 'array_of_ltensor'};

valid_coef_type = { 'single','array'};

% --- check and update input
for i = 1:length(varargin)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': #' varargin{2*i-1} ' argument is not valid. Function arguments list : ' strjoin(arglist,', ') ' !']);
    end
end
%--------------------------------------------------------------------------
if isempty(f)
    error([mfilename ' : #f must be given, numeric or function_handle !']);
else
    if isa(f,'numeric')
        ptype = 'number';
    elseif isa(f,'function_handle')
        ptype = 'function';
    end
end

if ~isempty(varargin_list)
    if mod(length(varargin_list),2) ~= 0
        error([mfilename ' : #varargin_list must be given as cell and in pairs !']);
    end
end
%------------------------------------------------------------------
if isempty(coef_type)
    error([mfilename ': #coef_type must be given !']);
elseif ~isa(coef_type,'char')
    error([mfilename ': #coef_type must be given as char with single quote !']);
elseif ~any(strcmpi(strrep(coef_type,' ',''),strrep(valid_coef_type,' ','')))
    error([mfilename ': #coef_type must be one of these type : ' strjoin(valid_coef_type,', ') ' !']);
end
%--------------------------------------------------------------------------
switch ptype
    case 'number'
        f = str2func(['@()' num2str(f)]);
    case 'function'
        %------------------------------------------------------------------
        if ~isempty(depend_on)
            %--------------------------------------------------------------
            depend_on = f_to_scellargin(depend_on);
            %--------------------------------------------------------------
            for i = 1:length(depend_on)
                dep_on = depend_on{i};
                field_name = split(dep_on,'.');
                field_name = field_name{end};
                if ~any(strcmpi(field_name,valid_depend_on))
                    error([mfilename ' : #depend_on is not valid. Check field names : ' strjoin(valid_depend_on,', ') ' !']);
                end
            end
            %--------------------------------------------------------------
            if f_nargin(f)
                if f_nargin(f) ~= length(depend_on)
                    error([mfilename ': Check number of f arguments !']);
                end
            end
        end
end
%--------------------------------------------------------------------------
% --- Output
coef.f = f;
coef.depend_on = depend_on;
coef.varargin_list = varargin_list;
% -
coef.coef_type  = coef_type;
coef.coef_size  = coef_size;
coef.input_size = input_size;
% --- Log message
vl = {};
if ~isempty(varargin_list)
    for i = 1:length(varargin_list)/2
        vli = varargin_list{2*i - 1};
        if isnumeric(vli)
            vl{i} = num2str(vli);
        elseif ischar(vli)
            vl{i} = vli;
        elseif isa(vli,'function_handle') || isa(vli,'scatteredInterpolant')
            vl{i} = char(vli);
        else
            vl{i} = '';
        end
    end
end
% ---
depon = {};
if ~isempty(depend_on)
    depon = depend_on;
end
% ---
f_fprintf(0,'Make coef with f:',1,char(f), ...
          0,', depend_on:',     1,strjoin(depon,' '), ...
          0,', varargin_list:', 1,strjoin(vl,' '), ...
          0,', coef_type:',     1,coef_type,...
          0,'\n');


     
     
     
