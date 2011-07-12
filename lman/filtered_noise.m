function noise_filtered = filtered_noise(varargin)

switch nargin
    case 2
        siz = varargin{1};
        power_spectrum = varargin{2};
    case 3
        siz = [varargin{1} varargin{2}];
        power_spectrum = varargin{3};
    otherwise
        error('Wrong number of arguments')
end

noise = rand(siz);
nfft = length(power_spectrum);
noise_transformed = fft(noise, nfft);
noise_transformed_filtered = noise_transformed .* power_spectrum;
temp = ifft(noise_transformed_filtered);
noise_filtered = temp(1:siz(1), :);