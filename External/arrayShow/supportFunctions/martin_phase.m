function c = martin_phase(N)
% phase colormap as found in a tool from Martin Uecker (muecker@gwdg.de)

    if nargin < 1
        N = 64;
    end


phase = linspace(0,2*pi,N);

c = zeros(N,3);
c(:,1) = sin(phase);
c(:,2) = sin(phase + 120 * pi/180);
c(:,3) = sin(phase + 240 * pi/180);

c = (c + 1)/2;

end



