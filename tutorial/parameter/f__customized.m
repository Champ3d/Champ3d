function b = f__customized(celem,args)

arguments
    celem
    args.fx = [];
    args.fy = [];
    args.fz = [];
    args.s  = [0 0 0];
end

% ---
fx = args.fx;
fy = args.fy;
fz = args.fz;
s  = args.s;
% ---
b = zeros(3,size(celem,2));
% ---
x = celem(1,:) - s(1);
y = celem(2,:) - s(2);
z = celem(3,:) - s(3);
% ---
b(1,:) = fx(x, y, z);
b(2,:) = fy(x, y, z);
b(3,:) = fz(x, y, z);
