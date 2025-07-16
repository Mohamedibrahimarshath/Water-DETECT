
function DisplayRules(Rules)

    for i=1:size(Rules,1)
        disp(['Rule #' num2str(i) ': ' mat2str(Rules{i,1}) ' --> ' mat2str(Rules{i,2})]);
        disp(['       Support = ' num2str(Rules{i,3})]);
        disp(['    Confidenec = ' num2str(Rules{i,4})]);
        disp(['          Lift = ' num2str(Rules{i,5})]);
        disp(' ');
    end

end