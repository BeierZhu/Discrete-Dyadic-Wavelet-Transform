function [SWD,SWA] = wvt(data, scale)
% SWD wavelet
% SWA scale 
h = [0.125, 0.375, 0.375, 0.125].*sqrt(2);
g = [2, -2];
l_h = 4;
l_g = 2;

n = length(data);

SWD = data';
Sf_b = data';
for i = 1:scale
    for j = 1:n
        Sf(j) = 0;
        for k = 1:l_h
            if j - k + floor(l_h/2) + 1 <= 0
                Sf(j) =  Sf(j) + h(k) * Sf_b(1);
            elseif j - k + floor(l_h/2) + 1 > n
                Sf(j) =  Sf(j) + h(k) * Sf_b(n);
            else
                Sf(j) =  Sf(j) + h(k) * Sf_b(j - k + floor(l_h/2) + 1);
            end     
        end
    end
    for j = 1:n
        Sw(j) = 0;
        for k = 1:l_g
            if j - k + floor(l_g/2) + 1 <= 0
                Sw(j) =  Sw(j) + g(k) * Sf_b(1);
            elseif j - k + floor(l_g/2) + 1 > n
                Sw(j) =  Sw(j) + g(k) * Sf_b(n);
            else
                Sw(j) =  Sw(j) + g(k) * Sf_b(j - k + floor(l_g/2) + 1);
            end     
        end
    end
    Sf_b = Sf;
    SWD = [SWD;Sw];
    if i == 1
        SWA = Sf;
    else
        SWA = [SWA;Sf];
    end
    hb = h;
    gb = g;
    h = zeros(1,2*l_h-1);
    g = zeros(1,2*l_g-1);
    for j = 1:l_h
        h(2*j-1) = hb(j);
    end
    for j = 1:l_g
        g(2*j-1) = gb(j);
    end
    l_h = 2 * l_h - 1;
    l_g = 2 * l_g - 1;
end