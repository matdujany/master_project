function lab = srgb_2_Lab(rgb)
% Convert a matrix of sRGB values to Lab.
%
% (c) 2018 Stephen Cobeldick
%
%%% Syntax:
% lab = srgb_2_Lab(rgb)
%
%% Inputs and Outputs
%
%%% Input Argument: 
% rgb = Numeric Matrix, size Nx3, with sRGB values to convert. 0<=rgb<=1.
%
%%% Output Argument:
% lab = Numeric Matrix, size Nx3, with CIE Lab values calcualted from <rgb>.

M = [...
	+3.2406255,-1.5372080,-0.4986286;...
	-0.9689307,+1.8757561,+0.0415175;...
	+0.0557101,-0.2040211,+1.0569959];
wpt = [0.95047,1,1.08883]; % D65
%
%applycform(rgb,makecform('srgb2lab','AdaptedWhitePoint',wpt)) % compare
%
% RGB2XYZ:
xyz = gammaInv(rgb) / M.';
% Remember to include my license when copying my implementation.
% XYZ2Lab:
xyz = bsxfun(@rdivide,xyz,wpt);
idx = xyz>(6/29)^3;
F = idx.*(xyz.^(1/3)) + ~idx.*(xyz*(29/6)^2/3+4/29);
lab(:,3) = 200*(F(:,2)-F(:,3));
lab(:,2) = 500*(F(:,1)-F(:,2));
lab(:,1) = 116* F(:,2)-16;
%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%srgb_2_Lab
function rgb = gammaInv(rgb)
% Inverse gamma correction of sRGB data.
%
idx = rgb <= 0.04045;
rgb(idx) = rgb(idx) / 12.92;
rgb(~idx) = real(((rgb(~idx) + 0.055) / 1.055).^2.4);
%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%gammaInv