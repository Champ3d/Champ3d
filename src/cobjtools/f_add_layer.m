function c3dobj = f_add_layer(c3dobj,varargin)
% F_ADD_LAYER ...
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

c3dobj = f_add_geo1d(c3dobj,'geo1d_axis','layer',varargin{:});