function [uPitch varPitch, u, var] = SAP_computeGlobalFeatures();

       if(sound_detect())  // we are inside a syllable -- add features
       {
           if(syllDur==1) features.start=sample;
           syllDur++;  stopDur=0;
           if(option->simple_pitch_averaging) sum_pitch+=m_Pitch;
           else
           {
              sum_pitch_simp+=m_Pitch;
              tmp_sum=min(m_PitchGoodness,(float)100)*m_Entropy*m_Entropy;
              sum_pitch+=m_Pitch*tmp_sum;
              sum_factors+=tmp_sum;
           }
           sum_entropy+=m_Entropy;
           sum_fm+=m_FM;
           sum_pgood+=m_PitchGoodness;
           sum_am+=m_AM;
          // if(syllDur>59 && syllDur<80)sum_peakFreq+=m_Pitch;//m_PeakFreq;
           sum_peakFreq+=m_PeakFreq;
           sum_amplitude+=m_amplitude;

           SS_pitch+=m_Pitch*m_Pitch;
           SS_entropy+=m_Entropy*m_Entropy;
           SS_fm+=m_FM*m_FM;
           SS_pgood+=m_PitchGoodness*m_PitchGoodness;
           SS_am+=m_AM*m_AM;
           //if(syllDur>59 && syllDur<80)SS_peakFreq+=m_Pitch*m_Pitch;//m_PeakFreq*m_PeakFreq;
           SS_peakFreq+=m_PeakFreq*m_PeakFreq;
           SS_amplitude+=m_amplitude*m_amplitude;

           if(syllDur>20)boutDur++; // bout starts only if a syllable of significant duration occured
       }
       else  // syllable is over?
       {
          if(stopDur>option->min_stop_duration         // stop was long enough to decide that syllable ended
             && syllDur>option->min_syllable_duration) // syllable is long enough to count
          {       // wrap it up -- syllable has ended

             features.bird_ID=option->bird_ID;
             features.serial_number=option->serial_number;
             features.month=option->month;
             features.day=option->day;
             features.hour=option->hour;
             features.minute=option->minute;
             features.second=option->second;
             features.duration=syllDur;
             if(syllDur<2)syllDur=2; // prevent divition by zero, but this should not happen anyway...

             // first handle pitch...
             if(option->simple_pitch_averaging)
             {
                features.mean_pitch=sum_pitch/syllDur;
                features.var_pitch=0.001*(SS_pitch-(1.0/syllDur)*(sum_pitch*sum_pitch))/(syllDur-1);
             }
             else
             {
               features.mean_pitch=sum_pitch/sum_factors;
               features.var_pitch=0.001*(SS_pitch-(1.0/syllDur)*(sum_pitch_simp*sum_pitch_simp))/(syllDur-1);
               sum_factors=0;
             }
             // now do the rest of the features
             // factors are used for the 16bit encoding of floating point values
             features.mean_FM=10*sum_fm/syllDur;
             features.mean_entropy=100*sum_entropy/syllDur;
             features.mean_pGood=10*sum_pgood/syllDur;
             features.mean_amplitude=10*sum_amplitude/syllDur;
             features.mean_am=100000*SS_am/syllDur; // we use the squere AM as our feature...
             features.mean_peakFr=sum_peakFreq/syllDur;

             features.var_FM=      (SS_fm-(1.0/syllDur)*sum_fm*sum_fm)/(syllDur-1);
             features.var_entropy= 100*(SS_entropy-(1.0/syllDur)*sum_entropy*sum_entropy)/(syllDur-1);
             features.var_pGood=   0.01*(SS_pgood-(1.0/syllDur)*sum_pgood*sum_pgood)/(syllDur-1);
             features.var_amplitude=   (SS_amplitude-(1.0/syllDur)*sum_amplitude*sum_amplitude)/(syllDur-1);
             features.var_am=100000*(SS_am-(1.0/syllDur)*sum_am*sum_am)/(syllDur-1);
             features.var_peakFr=  0.001*(SS_peakFreq-(1.0/syllDur)*sum_peakFreq*sum_peakFreq)/(syllDur-1);

             mem_recs.push_back(features);//[syllable_number]=features;
             syllable_number++;
          }
          // reset variables (note that we keep reseting every frame durign the stop)
          if(stopDur>option->min_stop_duration)
          {
             syllDur=0; sum_pitch=0; sum_pitch_simp=0; sum_entropy=0; sum_fm=0; sum_pgood=0; sum_amplitude=0;
             sum_am=0; sum_peakFreq=0; SS_pitch=0; SS_entropy=0;
             SS_fm=0; SS_pgood=0; SS_am=0; SS_peakFreq=0;  SS_amplitude=0;
          }

          if(maxSyllableDur<syllDur)maxSyllableDur=syllDur;
          stopDur++;
          if(boutDur) boutDur++;
          if(stopDur > option->stop_duration_thresh)
          {
            if(maxBoutDur<boutDur){maxBoutDur=boutDur; bout_end=sample;}
            boutDur=0;
          }
      }
      if(option->create_feature_arrays) add_features_to_vars();// for the single task and for the similarity scores
}
