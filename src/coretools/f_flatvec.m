function [vout, return_position_list, return_len_list] = f_flatvec(vin,varargin)
% F_FLATVEC 
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'position'};

% --- default input value
position = 1; % index of the dimension

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
lenlist_o = size(vin);
positionlist_o = 1:length(lenlist_o);
len_position = lenlist_o(position);
% ---
positionlist_new = positionlist_o;
positionlist_new(position) = [];
positionlist_new = [position positionlist_new];
lenlist_new = lenlist_o(positionlist_new);
vout = reshape(permute(vin,positionlist_new),len_position,[]);
% ---
return_position_list = positionlist_new;
return_len_list = lenlist_new;

end



