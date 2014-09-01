function saved_segments = pitch_from_dbase(dbase, target_syllable_titles)

% segmented and labeled in electro_gui
n = 0;
for file_number = 1:length(dbase.SoundFiles) % for each file
    audio_is_loaded = false;
    full_file_name = [dbase.PathName, filesep, dbase.SoundFiles(file_number).name];
    
    for segment_number = 1:length(dbase.SegmentTitles{file_number})
        
        % if this segment is a target segment (note that segment labels ARE
        % CASE SENSITIVE!)
        segment_title = dbase.SegmentTitles{file_number}(segment_number);
        if any(strcmp(segment_title, target_syllable_titles))
            
            % Load the audio from this file if we haven't already. If there
            % are no target syllables in the file, we will never load its
            % audio, thereby saving lots of time!
            if ~audio_is_loaded
                [audio fs dateandtime label props] = feval(['egl_' dbase.SoundLoader], full_file_name, 1);
                audio_is_loaded = 1;
            end
            n_start = dbase.SegmentTimes{file_number}(segment_number, 1);
            n_end   = dbase.SegmentTimes{file_number}(segment_number, 2);
            segment_audio = audio(n_start:n_end);
            
            % calculate pitch during target syllable
            [pitch, pitch_goodness, harmonic_power, pitch_time, entropy] = estimatePitch(segment_audio, fs);
            
            n=n+1;
            saved_segments(n).filename = full_file_name;
            saved_segments(n).title = segment_title;
            saved_segments(n).n_start = n_start;
            saved_segments(n).n_end   = n_end;
            saved_segments(n).t_start = dbase.Times(file_number) + samp2days(n_start, dbase.Fs);
            saved_segments(n).t_end   = dbase.Times(file_number) + samp2days(n_end  , dbase.Fs);
            saved_segments(n).audio = segment_audio;
            saved_segments(n).pitch = pitch;
            saved_segments(n).pitch_time = pitch_time;
        end
            
    end
end

figure
hold on
for n = 1:length(saved_segments)
    plot(saved_segments(n).pitch_time, saved_segments(n).pitch)
end