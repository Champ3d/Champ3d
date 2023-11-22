function dgeo = f_make_shape2d(varargin)
% 1. rectangle domain
% Without rotation around 'center' by an angle 'a'
%      => 'wid' = length along x, 'hei' = length along y
% dom2D = f_make_shape2d('shape','rec','wid',w,'hei',h,'center',[x y],'angle',a);
% dom2D = f_make_shape2d('shape','rec','wid',w,'hei',h);
% dom2D = f_make_shape2d('shape','rec','wid',w,'hei',h,'cbase',[x y],'angle',a);
% dom2D = f_make_shape2d('shape','rec','wid',w,'hei',h,'lbase',[x y],'angle',a);
% dom2D = f_make_shape2d('shape','rec','wid',w,'hei',h,'rbase',[x y],'angle',a);
%
% 2. circular domain
% dom2D = f_make_shape2d('shape','cir','radius',r,'center',[x y]);
% d3 = f_make_shape2d('shape','cir','radius',1,'center',[0 1]);
% 3. elliptical domain
% dom2D = f_make_shape2d('shape','ell','xradius',xr,'yradius',yr,'center',[x y],'angle',a);
% d4 = f_make_shape2d('shape','ell','xradius',2,'yradius',0.5,'center',[0 2],'angle',0);
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
arglist = {'shape','center','angle','wid','hei'};

% --- default input value
dgeo = [];
datin = [];

for i = 1:nargin/2
    datin.(lower(varargin{2*i-1})) = varargin{2*i};
end

if ~isfield(datin,'type')
    datin.type = 'geofromdom';
end

if ~isfield(datin,'shape')
    error([mfilename ': Shape undefined ! (shape = rec, cir, ell, pol)']);
end

if ~isfield(datin,'center')
    datin.center = [0 0];
end

if ~isfield(datin,'angle')
    datin.angle = 0;
end
datin.angle = datin.angle/180*pi;

switch lower(datin.type)
    case 'geofromedge'
        dgeo.type = 'geofromedge';
        % Decomposed Geometry Matrix
        %  + circle edge  ---> [1 x1 x2 y1 y2 zleft zright xcen ycen R 0 0].';
        %  + line edge    ---> [2 x1 x2 y1 y2 zleft zright 0 0 0 0 0].';
        %  + ellipse edge ---> [4 x1 x2 y1 y2 zleft zright xcen ycen Rx Ry angle].';
        switch lower(datin.shape)
            case 'rec'
                a = datin.angle;
                x = datin.wid; xc = datin.center(1);
                y = datin.hei; yc = datin.center(2);
                mrot = [cos(a) -sin(a);...
                        sin(a)  cos(a)];
                XY = mrot*[-x/2+xc +x/2+xc   +x/2+xc -x/2+xc; ...
                           -y/2+yc -y/2+yc   +y/2+yc +y/2+yc];
                dg = [];
                for i = 1:size(XY,2)
                    j = i+1;
                    if j > size(XY,2); j = 1; end
                    dg = [dg; 2 XY(1,i) XY(1,j) XY(2,i) XY(2,j) datin.zleft datin.zright 0 0 0 0 0];
                end
                dgeo.dgeo = dg.';
            case 'cir'
                r  = datin.radius;
                xc = datin.center(1);
                yc = datin.center(2);
                dg = [1 +r+xc +00+xc +00+yc +r+yc datin.zleft datin.zright xc yc r; ...
                      1 +00+xc -r+xc +r+yc +00+yc datin.zleft datin.zright xc yc r; ...
                      1 -r+xc +00+xc +00+yc -r+yc datin.zleft datin.zright xc yc r; ...
                      1 +00+xc +r+xc -r+yc +00+yc datin.zleft datin.zright xc yc r];
                dgeo.dgeo = dg.';
            case 'ell'
                rx = datin.xradius;
                ry = datin.yradius;
                xc = datin.center(1);
                yc = datin.center(2);
                a  = datin.angle;
                dg = [4 +rx+xc +00+xc +00+yc +ry+yc datin.zleft datin.zright xc yc rx ry a; ...
                      4 +00+xc -rx+xc +ry+yc +00+yc datin.zleft datin.zright xc yc rx ry a; ...
                      4 -rx+xc +00+xc +00+yc -ry+yc datin.zleft datin.zright xc yc rx ry a; ...
                      4 +00+xc +rx+xc -ry+yc +00+yc datin.zleft datin.zright xc yc rx ry a];
                dgeo.dgeo = dg.';
            case 'pol'
                dgeo = [];
            otherwise
                dgeo = [];
        end
    otherwise
        dgeo.type = 'geofromdom';
        switch datin.shape
            case 'rec'
                a = datin.angle;
                x = datin.wid; xc = datin.center(1);
                y = datin.hei; yc = datin.center(2);
                mrot = [cos(a) -sin(a);...
                        sin(a)  cos(a)];
                XY = mrot*[-x/2+xc +x/2+xc   +x/2+xc -x/2+xc; ...
                           -y/2+yc -y/2+yc   +y/2+yc +y/2+yc];
                dg = [3 4 reshape(XY.',1,numel(XY))].';
                dgeo.dgeo = dg;
            case 'cir'
                r  = datin.radius;
                xc = datin.center(1);
                yc = datin.center(2);
                dg = [1 xc yc r 0 0 0 0 0 0].';
                dgeo.dgeo = dg;
            case 'ell'
                rx = datin.xradius;
                ry = datin.yradius;
                xc = datin.center(1);
                yc = datin.center(2);
                a  = datin.angle;
                dg = [4 xc yc rx ry a 0 0 0 0].';
                dgeo.dgeo = dg;
            case 'pol'
                dg = [];
                dgeo.dgeo = dg;
            otherwise
                dg = [];
                dgeo.dgeo = dg;
        end
end





