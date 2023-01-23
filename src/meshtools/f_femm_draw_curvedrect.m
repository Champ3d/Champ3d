function draw2d = f_femm_draw_curvedrect(draw2d,varargin)

%--------------------------------------------------------------------------
% 'c_angle' : angle of the center (degree)
% 'ri' : interior radius
% 're' : exterior radius
% 'arclen' : arc length
% 'max_anglen' : maximal angle of segment (default = 2 deg)
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'id_draw2d','c_angle','ri','re','arc_len','max_anglen','ocenter'};

% --- default input value
c_angle = [];
ri = [];
re = [];
arc_len = 0;
max_anglen = [];
id_draw2d = [];
ocenter = [0 0];

% --- check and update input
for i = 1:(nargin-1)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': Check function arguments : ' strjoin(arglist,', ') ' !']);
    end
end
% -------------------------------------------------------------------------
if arc_len <= 0 || arc_len >= 360
    error([mfilename ': #arclen must > 0 and < 360 !']);
end
if isempty(max_anglen)
    max_anglen = 2;
end
% -------------------------------------------------------------------------
lendr = length(draw2d);
lendr = lendr + 1;
if isempty(id_draw2d)
    id_draw2d = ['XXDraw2dNo' num2str(lendr)];
end
% -------------------------------------------------------------------------
if arc_len <= 180
    % ---------------------------------------------------------------------
    xi1 = ri * cosd(c_angle - arc_len/2) + ocenter(1);
    xi2 = ri * cosd(c_angle + arc_len/2) + ocenter(1);
    yi1 = ri * sind(c_angle - arc_len/2) + ocenter(2);
    yi2 = ri * sind(c_angle + arc_len/2) + ocenter(2);
    mi_drawarc(xi1,yi1,xi2,yi2,arc_len,max_anglen);
    % ---------------------------------------------------------------------
    xe1 = re * cosd(c_angle - arc_len/2) + ocenter(1);
    xe2 = re * cosd(c_angle + arc_len/2) + ocenter(1);
    ye1 = re * sind(c_angle - arc_len/2) + ocenter(2);
    ye2 = re * sind(c_angle + arc_len/2) + ocenter(2);
    mi_drawarc(xe1,ye1,xe2,ye2,arc_len,max_anglen);
    % ---------------------------------------------------------------------
    mi_drawline(xi1,yi1,xe1,ye1);
    mi_drawline(xi2,yi2,xe2,ye2);
    % ---------------------------------------------------------------------
    eps_a = arc_len/2 - arc_len/1e3;
    eps_r = ri + (ri+re)/1e3;
    bottomright(1) = eps_r * cosd(c_angle - eps_a) + ocenter(1);
    bottomright(2) = eps_r * sind(c_angle - eps_a) + ocenter(2);
    bottomleft(1)  = eps_r * cosd(c_angle + eps_a) + ocenter(1);
    bottomleft(2)  = eps_r * sind(c_angle + eps_a) + ocenter(2);
    % ---------------------------------------------------------------------
    eps_a = arc_len/2 - arc_len/1e3;
    eps_r = re - (ri+re)/1e3;
    upperright(1) = eps_r * cosd(c_angle - eps_a) + ocenter(1);
    upperright(2) = eps_r * sind(c_angle - eps_a) + ocenter(2);
    upperleft(1)  = eps_r * cosd(c_angle + eps_a) + ocenter(1);
    upperleft(2)  = eps_r * sind(c_angle + eps_a) + ocenter(2);
    % ---------------------------------------------------------------------
else
    ca = c_angle - arc_len/4;
    max_anglen = round(max_anglen/2);
    % ---------------------------------------------------------------------
    xi1 = ri * cosd(ca - arc_len/4) + ocenter(1);
    xi2 = ri * cosd(ca + arc_len/4) + ocenter(1);
    yi1 = ri * sind(ca - arc_len/4) + ocenter(2);
    yi2 = ri * sind(ca + arc_len/4) + ocenter(2);
    mi_drawarc(xi1,yi1,xi2,yi2,arc_len/2,max_anglen);
    % ---------------------------------------------------------------------
    xe1 = re * cosd(ca - arc_len/4) + ocenter(1);
    xe2 = re * cosd(ca + arc_len/4) + ocenter(1);
    ye1 = re * sind(ca - arc_len/4) + ocenter(2);
    ye2 = re * sind(ca + arc_len/4) + ocenter(2);
    mi_drawarc(xe1,ye1,xe2,ye2,arc_len/2,max_anglen);
    % ---------------------------------------------------------------------
    ca = c_angle + arc_len/4;
    xi3 = ri * cosd(ca + arc_len/4) + ocenter(1);
    xe3 = re * cosd(ca + arc_len/4) + ocenter(1);
    yi3 = ri * sind(ca + arc_len/4) + ocenter(2);
    ye3 = re * sind(ca + arc_len/4) + ocenter(2);
    mi_drawarc(xi2,yi2,xi3,yi3,arc_len/2,max_anglen);
    mi_drawarc(xe2,ye2,xe3,ye3,arc_len/2,max_anglen);
    % ---------------------------------------------------------------------
    mi_drawline(xi1,yi1,xe1,ye1);
    mi_drawline(xi3,yi3,xe3,ye3);
    % ---------------------------------------------------------------------
    ca    = c_angle - arc_len/4;
    eps_a = arc_len/4 - arc_len/1e3;
    % ---
    eps_r = ri + (ri+re)/1e3;
    bottomright(1) = eps_r * cosd(ca - eps_a) + ocenter(1);
    bottomright(2) = eps_r * sind(ca - eps_a) + ocenter(2);
    % ---
    eps_r = re - (ri+re)/1e3;
    upperright(1) = eps_r * cosd(ca - eps_a) + ocenter(1);
    upperright(2) = eps_r * sind(ca - eps_a) + ocenter(2);
    % ---------------------------------------------------------------------
    ca    = c_angle + arc_len/4;
    eps_a = arc_len/4 - arc_len/1e3;
    % ---
    eps_r = ri + (ri+re)/1e3;
    bottomleft(1) = eps_r * cosd(ca + eps_a) + ocenter(1);
    bottomleft(2) = eps_r * sind(ca + eps_a) + ocenter(2);
    % ---
    eps_r = re - (ri+re)/1e3;
    upperleft(1) = eps_r * cosd(ca + eps_a) + ocenter(1);
    upperleft(2) = eps_r * sind(ca + eps_a) + ocenter(2);
    % ---------------------------------------------------------------------
end
% -------------------------------------------------------------------------
center = [(ri+re)/2 * cosd(c_angle)   (ri+re)/2 * sind(c_angle)];
% -------------------------------------------------------------------------
draw2d(lendr).id_draw2d = id_draw2d;
draw2d(lendr).type = 'curved_rectangle';
draw2d(lendr).c_angle = c_angle;
draw2d(lendr).ri = ri;
draw2d(lendr).re = re;
draw2d(lendr).arc_len  = arc_len;
draw2d(lendr).ocenter  = ocenter;
draw2d(lendr).center   = center;
draw2d(lendr).c_vector = [cosd(c_angle) sind(c_angle)];
draw2d(lendr).bottomright = bottomright;
draw2d(lendr).bottomleft  = bottomleft;
draw2d(lendr).upperright  = upperright;
draw2d(lendr).upperleft   = upperleft;
draw2d(lendr).max_anglen  = max_anglen;
% -------------------------------------------------------------------------




