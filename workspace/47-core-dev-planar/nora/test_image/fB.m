function B = fB(cen, node,I)

arguments
    cen
    node
    I = 1
end

% ---
node = node - f_tocolv(cen);
R = sqrt(node(1,:).^2 + node(2,:).^2);
R(R < 0.1e-3) = 1e6;
% ---
mu0 = 4*pi*1e-7;
Bm = mu0*I./(2*pi.*R);
% ---
uB = [-node(2,:); node(1,:)];
uB = uB./vecnorm(uB);
% ---
B = Bm .* uB;

end