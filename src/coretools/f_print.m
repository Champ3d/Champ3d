function f_print(str_in, varargin)
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'pad_len','pad_char'};

% --- default input value
pad_len = 0;
pad_char   = '_';
%--------------------------------------------------------------------------
% --- check and update input
for i = 1:length(varargin)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': Check function arguments : ' strjoin(arglist,', ') ' !']);
    end
end

%--------------------------------------------------------------------------
if ~iscell(str_in)
    str_in{1} = str_in;
end
%--------------------------------------------------------------------------
lenstr = length(str_in);
%--------------------------------------------------------------------------
pad_len = padarray(pad_len,lenstr,'post');
%--------------------------------------------------------------------------
for i = 1:lenstr
    str_out{i} = pad(str_in{i},pad_len(i),'right',pad_char);
end
%--------------------------------------------------------------------------
fprintf([strjoin(str_out) '\n']);
%--------------------------------------------------------------------------



