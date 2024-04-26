function vout = f_feval(f,varargin)
%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2023
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------


% --- valid argument list (to be updated each time modifying function)
arglist = {'argument_array','varargin_list'};

% --- default input value
argument_array = {};
varargin_list = {};

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
nb_fargin = f_nargin(f);
%--------------------------------------------------------------------------
if nb_fargin ~= length(argument_array)
    error([mfilename ': Check number of f arguments !']);
end
%--------------------------------------------------------------------------
if isempty(varargin_list)
    if nb_fargin == 0
        vout = f();
    elseif nb_fargin == 1
        vout = f(argument_array{1});
    elseif nb_fargin == 2
        vout = f(argument_array{1},argument_array{2});
    elseif nb_fargin == 3
        vout = f(argument_array{1},argument_array{2},argument_array{3});
    elseif nb_fargin == 4
        vout = f(argument_array{1},argument_array{2},argument_array{3},argument_array{4});
    elseif nb_fargin == 5
        vout = f(argument_array{1},argument_array{2},argument_array{3},argument_array{4},argument_array{5});
    elseif nb_fargin == 6
        vout = f(argument_array{1},argument_array{2},argument_array{3},argument_array{4},argument_array{5},argument_array{6});
    end
else
    if nb_fargin == 0
        vout = f(varargin_list{:});
    elseif nb_fargin == 1
        vout = f(argument_array{1},varargin_list{:});
    elseif nb_fargin == 2
        vout = f(argument_array{1},argument_array{2},varargin_list{:});
    elseif nb_fargin == 3
        vout = f(argument_array{1},argument_array{2},argument_array{3},varargin_list{:});
    elseif nb_fargin == 4
        vout = f(argument_array{1},argument_array{2},argument_array{3},argument_array{4},varargin_list{:});
    elseif nb_fargin == 5
        vout = f(argument_array{1},argument_array{2},argument_array{3},argument_array{4},argument_array{5},varargin_list{:});
    elseif nb_fargin == 6
        vout = f(argument_array{1},argument_array{2},argument_array{3},argument_array{4},argument_array{5},argument_array{6},varargin_list{:});
    end
end