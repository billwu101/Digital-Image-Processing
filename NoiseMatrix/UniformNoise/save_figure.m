function save_figure(picture_name)
    [~, base_name, ~] = fileparts(picture_name);
    if ~exist('result', 'dir')
        mkdir('result');
    end
    output_filename = fullfile('result', base_name + "_result.png");
    exportgraphics(gcf, output_filename, 'Resolution', 1200);
end
