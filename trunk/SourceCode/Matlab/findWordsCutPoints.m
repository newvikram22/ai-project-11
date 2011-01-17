function [cut_points] = findWordsCutPoints(hist_line, line)

% The function could not retrieve the last word if it has been writtend
% really close to the border

    % Maximum length accepted
    MAX_WS = 0.05 * size(line,2); 

    % Find white spaces
    white_spaces = [];
    count = 0;
    for i = 1:length(hist_line)
        if hist_line(i) == 0
            count = count + 1;
        else
            if count > 0
                white_spaces = [white_spaces; [i - count, i - 1, count]];
            end
            count = 0;
        end
    end
    if count ~= 0
        white_spaces = [white_spaces; [i - count, i - 1, count]];
    end
        
    % Show lines and white spaces 
    figure, imshow(line);
    hold on
    x = 1:1:size(line,1);
    for i = 1:size(white_spaces,1)
        plot(white_spaces(i,1), x, 'r');
        hold on 
        plot(white_spaces(i,2), x, 'r');
        hold on
    end
    title('White spaces between words and letters in the line');
    hold off

    % Filter the ones with long length (noise) and keep indexes to the
    % original list
    accepted_ws =  white_spaces(white_spaces(:,3) < MAX_WS, :);
    accepted_ws_indx =  find(white_spaces(:,3) < MAX_WS);
    
    % Cluster them to distinguish between white spaces between words and
    % white spaces between letters
    clusters = kmeans(accepted_ws(:,3), 2, 'emptyaction', 'drop');
    
    % Extract the white spaces between words
    largest_white_space = max(accepted_ws(:,3));
    num_cluster = clusters(accepted_ws(:,3) == largest_white_space);
    spaces = find(clusters(:) == num_cluster);
    
    % Extract cut points for words
%     cut_points = zeros(length(spaces) + 1, 2);
    for i = 1:length(spaces)
            
            % Start X
                if i == 1
                    for j = 1:spaces(1) 
                        prev_discarded = white_spaces(j, 3) > MAX_WS;
                        if prev_discarded
                            cut_points(1,1) = white_spaces(j, 2) - 1;
                        end
                    end
                else
                    if prev_discarded
                        cut_points(i,1) = white_spaces( accepted_ws_indx(spaces(i)) - 1, 2 ) - 1;
                    else
                        cut_points(i,1) = white_spaces( accepted_ws_indx(spaces(i-1)), 2 ) - 1;
                    end
                end
            
            % End X
            cut_points(i,2) = white_spaces( accepted_ws_indx(spaces(i)), 1) + 1;
    end
    
    for j = max(spaces)+1:size(white_spaces,1)
        next_discard = white_spaces(j,3) > MAX_WS;
        if next_discard 
            cut_points(i+1,1) = accepted_ws(end - 1, 2);
            cut_points(i+1,2) = white_spaces(j, 1);
            break
        end
    end
    
end