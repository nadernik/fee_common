function final_noise = generate_lman_noise_ra_dlm(rows, cols, weight, debugging)
% GENERATE_LMAN_NOISE_RA_DLM generates random noise with power spectrum
% matching measured pitch fluctuations from bird named mes010. The power
% spectrum is compensated to account for the filtering that happens through
% the RA-DLM recurrence.
%
% Noise has the same power spectrum as the pitch fluctuations measured in a
% 20 ms harmoic stack from bird 'mes010', including dc offset. Noise will
% have same sampling rate as pitch data measured from the bird (1 kHz). 
% 
% Usage:
%   nz = generate_lman_noise(timesteps, trials, weight)
%       returns matrix nz where each column is one trial of noise. Weight
%       is the weight on DLM from RA.
%   nz = generate_lman_noise(timesteps, trials, weight, debugging)
%       debugging can be set to true to show many plots to compare
%       simulated and actual noise



if ~exist('debugging', 'var')
    debugging = false;
end

nfft = 1024;
persistent f;
if isempty(f)
f = [ ...
    4.4053
    4.4047
    4.4015
    4.3946
    4.3836
    4.3683
    4.3485
    4.3240
    4.2949
    4.2611
    4.2228
    4.1800
    4.1329
    4.0814
    4.0260
    3.9666
    3.9037
    3.8374
    3.7680
    3.6958
    3.6212
    3.5445
    3.4660
    3.3859
    3.3046
    3.2227
    3.1403
    3.0579
    2.9756
    2.8937
    2.8126
    2.7324
    2.6535
    2.5759
    2.4999
    2.4255
    2.3530
    2.2833
    2.2159
    2.1507
    2.0877
    2.0271
    1.9689
    1.9130
    1.8596
    1.8089
    1.7608
    1.7148
    1.6709
    1.6289
    1.5888
    1.5504
    1.5138
    1.4788
    1.4455
    1.4135
    1.3827
    1.3530
    1.3245
    1.2971
    1.2705
    1.2448
    1.2199
    1.1958
    1.1723
    1.1494
    1.1271
    1.1054
    1.0842
    1.0636
    1.0437
    1.0243
    1.0055
    0.9873
    0.9697
    0.9526
    0.9361
    0.9199
    0.9041
    0.8887
    0.8737
    0.8592
    0.8449
    0.8309
    0.8173
    0.8039
    0.7910
    0.7783
    0.7659
    0.7537
    0.7418
    0.7300
    0.7185
    0.7072
    0.6961
    0.6852
    0.6746
    0.6643
    0.6543
    0.6446
    0.6351
    0.6258
    0.6167
    0.6079
    0.5994
    0.5911
    0.5832
    0.5755
    0.5680
    0.5607
    0.5535
    0.5466
    0.5398
    0.5333
    0.5270
    0.5210
    0.5151
    0.5095
    0.5041
    0.4990
    0.4942
    0.4897
    0.4854
    0.4814
    0.4776
    0.4739
    0.4705
    0.4673
    0.4642
    0.4613
    0.4586
    0.4561
    0.4538
    0.4517
    0.4498
    0.4480
    0.4465
    0.4451
    0.4440
    0.4431
    0.4424
    0.4418
    0.4414
    0.4412
    0.4412
    0.4415
    0.4418
    0.4424
    0.4432
    0.4442
    0.4454
    0.4466
    0.4480
    0.4495
    0.4511
    0.4527
    0.4545
    0.4562
    0.4579
    0.4596
    0.4613
    0.4629
    0.4644
    0.4657
    0.4669
    0.4679
    0.4687
    0.4693
    0.4697
    0.4700
    0.4700
    0.4697
    0.4693
    0.4686
    0.4676
    0.4664
    0.4649
    0.4632
    0.4613
    0.4591
    0.4567
    0.4541
    0.4512
    0.4482
    0.4450
    0.4416
    0.4381
    0.4345
    0.4308
    0.4270
    0.4231
    0.4192
    0.4152
    0.4112
    0.4072
    0.4032
    0.3992
    0.3953
    0.3915
    0.3878
    0.3842
    0.3808
    0.3775
    0.3743
    0.3712
    0.3683
    0.3657
    0.3632
    0.3610
    0.3590
    0.3574
    0.3560
    0.3549
    0.3541
    0.3536
    0.3533
    0.3534
    0.3538
    0.3544
    0.3553
    0.3563
    0.3576
    0.3591
    0.3608
    0.3625
    0.3644
    0.3663
    0.3682
    0.3702
    0.3722
    0.3742
    0.3763
    0.3785
    0.3806
    0.3828
    0.3849
    0.3870
    0.3890
    0.3910
    0.3929
    0.3947
    0.3964
    0.3980
    0.3994
    0.4006
    0.4017
    0.4027
    0.4034
    0.4040
    0.4044
    0.4046
    0.4046
    0.4044
    0.4039
    0.4032
    0.4022
    0.4011
    0.3997
    0.3980
    0.3961
    0.3940
    0.3916
    0.3890
    0.3862
    0.3832
    0.3800
    0.3766
    0.3731
    0.3694
    0.3657
    0.3618
    0.3578
    0.3536
    0.3494
    0.3451
    0.3407
    0.3363
    0.3319
    0.3274
    0.3229
    0.3184
    0.3140
    0.3095
    0.3050
    0.3005
    0.2961
    0.2918
    0.2874
    0.2832
    0.2789
    0.2748
    0.2707
    0.2667
    0.2627
    0.2588
    0.2551
    0.2514
    0.2479
    0.2445
    0.2414
    0.2384
    0.2356
    0.2329
    0.2304
    0.2280
    0.2257
    0.2236
    0.2216
    0.2197
    0.2180
    0.2165
    0.2151
    0.2140
    0.2130
    0.2122
    0.2115
    0.2109
    0.2104
    0.2100
    0.2097
    0.2094
    0.2091
    0.2089
    0.2088
    0.2088
    0.2088
    0.2088
    0.2088
    0.2090
    0.2091
    0.2092
    0.2094
    0.2097
    0.2099
    0.2102
    0.2106
    0.2110
    0.2114
    0.2119
    0.2124
    0.2129
    0.2135
    0.2141
    0.2146
    0.2152
    0.2158
    0.2165
    0.2171
    0.2177
    0.2183
    0.2189
    0.2195
    0.2200
    0.2205
    0.2210
    0.2215
    0.2220
    0.2224
    0.2228
    0.2232
    0.2236
    0.2240
    0.2244
    0.2247
    0.2250
    0.2253
    0.2255
    0.2258
    0.2260
    0.2262
    0.2264
    0.2266
    0.2268
    0.2271
    0.2274
    0.2277
    0.2280
    0.2284
    0.2288
    0.2292
    0.2296
    0.2301
    0.2306
    0.2311
    0.2317
    0.2323
    0.2331
    0.2339
    0.2348
    0.2358
    0.2369
    0.2381
    0.2395
    0.2409
    0.2425
    0.2442
    0.2460
    0.2479
    0.2499
    0.2519
    0.2541
    0.2562
    0.2585
    0.2607
    0.2630
    0.2652
    0.2675
    0.2697
    0.2718
    0.2739
    0.2758
    0.2777
    0.2795
    0.2811
    0.2826
    0.2838
    0.2849
    0.2858
    0.2866
    0.2871
    0.2874
    0.2875
    0.2873
    0.2869
    0.2863
    0.2855
    0.2844
    0.2831
    0.2816
    0.2799
    0.2780
    0.2759
    0.2736
    0.2712
    0.2686
    0.2659
    0.2632
    0.2603
    0.2574
    0.2545
    0.2515
    0.2485
    0.2454
    0.2424
    0.2395
    0.2365
    0.2336
    0.2308
    0.2281
    0.2255
    0.2229
    0.2205
    0.2182
    0.2160
    0.2139
    0.2120
    0.2101
    0.2084
    0.2067
    0.2053
    0.2039
    0.2027
    0.2016
    0.2007
    0.1998
    0.1991
    0.1984
    0.1978
    0.1973
    0.1969
    0.1965
    0.1962
    0.1959
    0.1957
    0.1955
    0.1954
    0.1952
    0.1952
    0.1951
    0.1951
    0.1950
    0.1950
    0.1949
    0.1948
    0.1947
    0.1946
    0.1944
    0.1941
    0.1939
    0.1936
    0.1932
    0.1928
    0.1923
    0.1917
    0.1912
    0.1905
    0.1898
    0.1890
    0.1882
    0.1873
    0.1863
    0.1852
    0.1841
    0.1829
    0.1817
    0.1805
    0.1793
    0.1781
    0.1770
    0.1759
    0.1751
    0.1744
    0.1741
    0.1744
    0.1751
    0.1759
    0.1770
    0.1781
    0.1793
    0.1805
    0.1817
    0.1829
    0.1841
    0.1852
    0.1863
    0.1873
    0.1882
    0.1890
    0.1898
    0.1905
    0.1912
    0.1917
    0.1923
    0.1928
    0.1932
    0.1936
    0.1939
    0.1941
    0.1944
    0.1946
    0.1947
    0.1948
    0.1949
    0.1950
    0.1950
    0.1951
    0.1951
    0.1952
    0.1952
    0.1954
    0.1955
    0.1957
    0.1959
    0.1962
    0.1965
    0.1969
    0.1973
    0.1978
    0.1984
    0.1991
    0.1998
    0.2007
    0.2016
    0.2027
    0.2039
    0.2053
    0.2067
    0.2084
    0.2101
    0.2120
    0.2139
    0.2160
    0.2182
    0.2205
    0.2229
    0.2255
    0.2281
    0.2308
    0.2336
    0.2365
    0.2395
    0.2424
    0.2454
    0.2485
    0.2515
    0.2545
    0.2574
    0.2603
    0.2632
    0.2659
    0.2686
    0.2712
    0.2736
    0.2759
    0.2780
    0.2799
    0.2816
    0.2831
    0.2844
    0.2855
    0.2863
    0.2869
    0.2873
    0.2875
    0.2874
    0.2871
    0.2866
    0.2858
    0.2849
    0.2838
    0.2826
    0.2811
    0.2795
    0.2777
    0.2758
    0.2739
    0.2718
    0.2697
    0.2675
    0.2652
    0.2630
    0.2607
    0.2585
    0.2562
    0.2541
    0.2519
    0.2499
    0.2479
    0.2460
    0.2442
    0.2425
    0.2409
    0.2395
    0.2381
    0.2369
    0.2358
    0.2348
    0.2339
    0.2331
    0.2323
    0.2317
    0.2311
    0.2306
    0.2301
    0.2296
    0.2292
    0.2288
    0.2284
    0.2280
    0.2277
    0.2274
    0.2271
    0.2268
    0.2266
    0.2264
    0.2262
    0.2260
    0.2258
    0.2255
    0.2253
    0.2250
    0.2247
    0.2244
    0.2240
    0.2236
    0.2232
    0.2228
    0.2224
    0.2220
    0.2215
    0.2210
    0.2205
    0.2200
    0.2195
    0.2189
    0.2183
    0.2177
    0.2171
    0.2165
    0.2158
    0.2152
    0.2146
    0.2141
    0.2135
    0.2129
    0.2124
    0.2119
    0.2114
    0.2110
    0.2106
    0.2102
    0.2099
    0.2097
    0.2094
    0.2092
    0.2091
    0.2090
    0.2088
    0.2088
    0.2088
    0.2088
    0.2088
    0.2089
    0.2091
    0.2094
    0.2097
    0.2100
    0.2104
    0.2109
    0.2115
    0.2122
    0.2130
    0.2140
    0.2151
    0.2165
    0.2180
    0.2197
    0.2216
    0.2236
    0.2257
    0.2280
    0.2304
    0.2329
    0.2356
    0.2384
    0.2414
    0.2445
    0.2479
    0.2514
    0.2551
    0.2588
    0.2627
    0.2667
    0.2707
    0.2748
    0.2789
    0.2832
    0.2874
    0.2918
    0.2961
    0.3005
    0.3050
    0.3095
    0.3140
    0.3184
    0.3229
    0.3274
    0.3319
    0.3363
    0.3407
    0.3451
    0.3494
    0.3536
    0.3578
    0.3618
    0.3657
    0.3694
    0.3731
    0.3766
    0.3800
    0.3832
    0.3862
    0.3890
    0.3916
    0.3940
    0.3961
    0.3980
    0.3997
    0.4011
    0.4022
    0.4032
    0.4039
    0.4044
    0.4046
    0.4046
    0.4044
    0.4040
    0.4034
    0.4027
    0.4017
    0.4006
    0.3994
    0.3980
    0.3964
    0.3947
    0.3929
    0.3910
    0.3890
    0.3870
    0.3849
    0.3828
    0.3806
    0.3785
    0.3763
    0.3742
    0.3722
    0.3702
    0.3682
    0.3663
    0.3644
    0.3625
    0.3608
    0.3591
    0.3576
    0.3563
    0.3553
    0.3544
    0.3538
    0.3534
    0.3533
    0.3536
    0.3541
    0.3549
    0.3560
    0.3574
    0.3590
    0.3610
    0.3632
    0.3657
    0.3683
    0.3712
    0.3743
    0.3775
    0.3808
    0.3842
    0.3878
    0.3915
    0.3953
    0.3992
    0.4032
    0.4072
    0.4112
    0.4152
    0.4192
    0.4231
    0.4270
    0.4308
    0.4345
    0.4381
    0.4416
    0.4450
    0.4482
    0.4512
    0.4541
    0.4567
    0.4591
    0.4613
    0.4632
    0.4649
    0.4664
    0.4676
    0.4686
    0.4693
    0.4697
    0.4700
    0.4700
    0.4697
    0.4693
    0.4687
    0.4679
    0.4669
    0.4657
    0.4644
    0.4629
    0.4613
    0.4596
    0.4579
    0.4562
    0.4545
    0.4527
    0.4511
    0.4495
    0.4480
    0.4466
    0.4454
    0.4442
    0.4432
    0.4424
    0.4418
    0.4415
    0.4412
    0.4412
    0.4414
    0.4418
    0.4424
    0.4431
    0.4440
    0.4451
    0.4465
    0.4480
    0.4498
    0.4517
    0.4538
    0.4561
    0.4586
    0.4613
    0.4642
    0.4673
    0.4705
    0.4739
    0.4776
    0.4814
    0.4854
    0.4897
    0.4942
    0.4990
    0.5041
    0.5095
    0.5151
    0.5210
    0.5270
    0.5333
    0.5398
    0.5466
    0.5535
    0.5607
    0.5680
    0.5755
    0.5832
    0.5911
    0.5994
    0.6079
    0.6167
    0.6258
    0.6351
    0.6446
    0.6543
    0.6643
    0.6746
    0.6852
    0.6961
    0.7072
    0.7185
    0.7300
    0.7418
    0.7537
    0.7659
    0.7783
    0.7910
    0.8039
    0.8173
    0.8309
    0.8449
    0.8592
    0.8737
    0.8887
    0.9041
    0.9199
    0.9361
    0.9526
    0.9697
    0.9873
    1.0055
    1.0243
    1.0437
    1.0636
    1.0842
    1.1054
    1.1271
    1.1494
    1.1723
    1.1958
    1.2199
    1.2448
    1.2705
    1.2971
    1.3245
    1.3530
    1.3827
    1.4135
    1.4455
    1.4788
    1.5138
    1.5504
    1.5888
    1.6289
    1.6709
    1.7148
    1.7608
    1.8089
    1.8596
    1.9130
    1.9689
    2.0271
    2.0877
    2.1507
    2.2159
    2.2833
    2.3530
    2.4255
    2.4999
    2.5759
    2.6535
    2.7324
    2.8126
    2.8937
    2.9756
    3.0579
    3.1403
    3.2227
    3.3046
    3.3859
    3.4660
    3.5445
    3.6212
    3.6958
    3.7680
    3.8374
    3.9037
    3.9666
    4.0260
    4.0814
    4.1329
    4.1800
    4.2228
    4.2611
    4.2949
    4.3240
    4.3485
    4.3683
    4.3836
    4.3946
    4.4015
    4.4047];
end

% Compensate for RA-DLM recurrence
radlm_filter = weight .^ (0:rows-1);
radlm_filter_fft = fft(radlm_filter, nfft)';
f_compensated = f ./ radlm_filter_fft;


frequency_domain_filter = f_compensated * ones(1, cols);

e = dpss(rows, 1);
dpss_window = e(:, 1) * ones(1, cols);

% Generate zero mean Gaussian white noise
white_noise = randn(rows, cols);

% Take Fourier Transform of white noise and normalize
white_noise_fft = fft(white_noise, nfft);
white_noise_fft = white_noise_fft ./ mean(mean(abs(white_noise_fft)));

% Filter transformed noise by multiplying in the frequency domain.
filtered_noise_fft = white_noise_fft .* frequency_domain_filter;

% Inverse Fourier transform to get filtered noise in the time domain.
filtered_noise_ifft = ifft(filtered_noise_fft);
filtered_noise = filtered_noise_ifft(1:rows, :);

% Rescale to compensate for dpss window that was used to calculate
% the frequency domain filter (this is hidden pitchfluctuations.m) and for
% the length of the noise
scale_factor = (1 ./ mean(dpss_window(:,1)));
dc_std = 0;%.35;
extra_dc = ones(rows, 1) * (randn(1, cols) .* dc_std);
final_noise = filtered_noise .* scale_factor + extra_dc;


if debugging
    close all
    
    clear d
    ddc = load('c:\stetner\data\pitchfluctuations\long_stacks_for_figure\mes010_yesdc.mat');
    
    % All pitch traces
    n_plot = min(size(ddc.pitches, 2), cols);
    figure
    ax(1) = subplot(1,2,1);
    n = randsample(cols, n_plot);
    plot(final_noise(:,n))
    title('simulated')
    ax(2) = subplot(1,2,2);
    n = randsample(size(ddc.pitches, 2), n_plot);
    plot(ddc.pitches(:,n))
    title('actual')
    linkaxes(ax, 'y')
    
    % Spectra
    figure
    f2 = fft(final_noise .* dpss_window, nfft);
    loglog(mean(abs(f2(1:ddc.nfft/2, :)), 2))
    hold all
    loglog(mean(abs(ddc.fftcoefs(1:ddc.nfft/2,:)), 2))
    legend('simulated', 'actual')
    title('spectra')
    xlabel('Frequency (Hz)')
    ylabel('Magnitude')
    keyboard

    
    % Pitch density (spectrogram)
    figure
    centers = -10:1:10;
    for t = 1:rows
        nsimulated(t, :) = hist(final_noise(t,:), centers);
        if t < size(ddc.pitches, 1)
            nactual(t, :) = hist(ddc.pitches(t, :), centers);
        end
    end
    subplot(1,2,1)
    imagesc(1:rows, centers, nsimulated')
    title('simulated')
    xlabel('time (ms)')
    ylabel('% from mean')
    subplot(1,2,2)
    imagesc(1:size(ddc.pitches, 1), centers, nactual')
    title('actual')
    xlabel('time (ms)')
    ylabel('% from mean')
    
    % histogram of pitches
    t = 1;
    figure
    stairs(centers, nsimulated(t, :) ./ sum(nsimulated(t,:)))
    hold all
    stairs(centers, nactual(t, :) ./ sum(nactual(t, :)))
    legend('simulated', 'actual')
    xlabel('pitch')
    ylabel('probability')
    
    % Histogram of dc offsets
    figure
    centers = -9:9;
    dc = mean(final_noise, 1);
    N = hist(dc, centers);
    N = N ./ sum(N);
    stairs(centers, N)
    hold all
    N = hist(ddc.offset(1,:), centers);
    N = N ./ sum(N);
    stairs(centers, N)
    legend('simulated', 'actual')
    xlabel('dc offset')
    ylabel('probablility')
    
    % ratio of spectra
%     figure
%     ratio = mean(abs(f2(1:nfft/2, :)), 2) ./ frequency_domain_filter(1:nfft/2)';
%     plot(ratio)
%     title('ratio of spectra')
    
    % autocorrelation
    acorr = zeros(ddc.P.MaxLag * 2 + 1, size(final_noise, 2));
    for col = 1:size(final_noise, 2)
        [c, lags] = xcorr(final_noise(:, col), ddc.P.MaxLag, 'unbiased');
        acorr(:, col) = c / max(c);
    end
    
    for col = 1:size(ddc.pitches, 2)
        [c, lags] = xcorr(ddc.pitches(:, col), ddc.P.MaxLag, 'unbiased');
        acorr_data(:,col) = c/max(c);
    end
    figure
    plot(lags, mean(acorr, 2))
    hold all
    plot(lags, mean(acorr_data, 2))
    legend('simulated', 'actual')
    xlabel('lag (ms)')
    ylabel('autocorrelation')
    
    % Example pitch traces
    figure
    for n = 1:cols
        subplot(1,2,1)
        plot(final_noise(:, n))
        axis([0 rows -10 10])
        title('simulated')
        subplot(1,2,2)
        plot(ddc.pitches(:, n))
        axis([0 size(ddc.pitches, 1) -10 10])
        title('actual')
        pause
    end
end
end

