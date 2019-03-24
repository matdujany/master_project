function [bool_frame, head] = check_frame(data, parms)
% Check conditions for frame and return boolean and head index
% if frame has been found.

bool_frame = 0;
head       = 0;

if(strcmp(data.last_byte,parms.endByte))
    
%     fprintf("Checking frame:\n")
%     fprintf("First expression is true\n")
    i_tmp               = data.last_byte_index;
    i_start_tmp         = (i_tmp + 1) - parms.frame_size;

    if i_start_tmp <= 0
        return
    end
    
    firstStartByte_calc = data.raw( i_start_tmp , :);
    
    if(strcmp(firstStartByte_calc,parms.firstStartByte))
%         fprintf("Second expression is true\n")
        
        i_tmp                = data.last_byte_index;
        
        
        secondStartByte_calc = data.raw( (i_tmp + 2) - parms.frame_size , :);
        
        if(strcmp(secondStartByte_calc,parms.secondStartByte))
%             fprintf("Third expression is true\n")
            bool_frame  = compare_checksum(data, parms);
                        
            
            if(bool_frame)
%                 fprintf("Checksum check is true\n")
                head        = i_tmp;
            end
        end
    end
end

end
