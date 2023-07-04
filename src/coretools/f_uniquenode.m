function IDNode = f_uniquenode(elem,varargin)
% f_uniquenode returns the (unique) nodes that build up the elements.
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'elem','nb_vertices'};
% --- default input value
nb_vertices = size(elem,1);
% --- check and update input
for i = 1:length(varargin)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': Check function arguments : ' strjoin(arglist,', ') ' !']);
    end
end
%--------------------------------------------------------------------------
elem = elem(1:nb_vertices,:);
%--------------------------------------------------------------------------
allNodeID = reshape(elem,1,numel(elem));
IDNode = unique(allNodeID);











