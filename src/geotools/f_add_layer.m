function geo = f_add_layer(geo,varargin)
% F_ADD_LAYER ...
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

geo = f_add_geo1d(geo,'geo1d_axis','layer',varargin{:});