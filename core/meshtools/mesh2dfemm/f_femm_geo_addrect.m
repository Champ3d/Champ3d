function f_geo_addRect(xcen,ycen,w,h,domName,varargin)
%--------------------------------------------------------------------------
% FEMM
% Author : David Meeker
% Copyright (C) 1998-2015
%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2023
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------
automesh = 0;
meshsize = 0;
incircuit  = 0;
magdir   = 0;
group    = 0;
turns    = 1;
bcon     = 0;

% -------------------------------------------------------------------------
for i = 1:(nargin-5)/2
    eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
end

% -------------------------------------------------------------------------
x1 = xcen - w/2;
y1 = ycen - h/2;
x2 = xcen + w/2;
y2 = ycen + h/2;

mi_drawline(x1,y1,x2,y1);
mi_drawline(x2,y1,x2,y2);
mi_drawline(x2,y2,x1,y2);
mi_drawline(x1,y2,x1,y1);

hsize = 1e-6;
vsize = 1e-6;
if bcon ~= 0
    % mi_selectsegment((x1+x2)/2,y1);
    % mi_selectsegment((x1+x2)/2,y2);
    % mi_selectsegment(x1,(y1+y2)/2);
    % mi_selectsegment(x2,(y1+y2)/2);
    
    mi_selectrectangle(xcen - w/2 - hsize,ycen - h/2 - vsize,...
                       xcen - w/2 + hsize,ycen + h/2 + vsize,1);
                   
    mi_selectrectangle(xcen + w/2 - hsize,ycen - h/2 - vsize,...
                       xcen + w/2 + hsize,ycen + h/2 + vsize,1);
                   
    mi_selectrectangle(xcen - w/2 - hsize,ycen - h/2 - vsize,...
                       xcen + w/2 + hsize,ycen - h/2 + vsize,1);
                   
    mi_selectrectangle(xcen - w/2 - hsize,ycen + h/2 - vsize,...
                       xcen + w/2 + hsize,ycen + h/2 + vsize,1);
                   
    mi_setsegmentprop(bcon,0,0,0,0);
    mi_clearselected();
end

xmid = (x1+x2)/2;
ymid = (y1+y2)/2;
mi_addblocklabel(xmid,ymid);
mi_selectlabel(xmid,ymid);
mi_setblockprop(domName,0,meshsize,incircuit,0,0,turns);
mi_clearselected();


