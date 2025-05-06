%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
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
