%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

function output = f_callx(fhandle, varargin)

% --- default input value
with_out = [];

% --- eval args
for i = 1:length(varargin)/2
    eval([lower(varargin{2*i-1}) '= varargin{2*i};'])
end

% --- check and update input
if isempty(with_out)
    % ---
    output = feval(fhandle,varargin{:});
else
    
    % ---
    output = feval(fhandle,validargs{:});
end
