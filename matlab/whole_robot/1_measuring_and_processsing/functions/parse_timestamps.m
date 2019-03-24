function timestamp_int = parse_timestamps(data, parms)
% Parse function for timestamps

    date_tmp = data.timestamp_hex;
    %%%arduino timestamps for load cells + 1 for timestamp from IMU
    for j = 1:parms.nr_arduino+1

        val_old = 0;
        factor  = 0;

        for i = 1:length(date_tmp)
            
            try
                val_new = hex2dec(date_tmp{i,j});
            catch
                disp("parse_timestamps(): hex to dec conversion goes wrong...");
            end


            if(val_new < val_old)
                factor = factor + 256;
            end

            timestamp_int(i,j) = val_new + factor;
            val_old = val_new;
        end
    end
end