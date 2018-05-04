caf_target_time1 = 100;
caf_target_time2 = 125;
caf_pitch_threshold1 = 0.; 
caf_pitch_threshold2 = 0;


escape_1 = squeeze(ra_output(1, caf_target_time1, :)) <= caf_pitch_threshold1;
escape_2 = squeeze(ra_output(1, caf_target_time2, :)) >= caf_pitch_threshold2;
escape_both = escape_1 & escape_2;
        
        

fprintf(1,'%.0f%% escapes from first contingency.\n', sum(escape_1)/total_motifs*100 )
fprintf(1,'%.0f%% escapes from second contingency.\n', sum(escape_2)/total_motifs*100 )
fprintf(1,'%.0f%% escapes from BOTH contingencies.\n', sum(escape_both)/total_motifs*100 )
