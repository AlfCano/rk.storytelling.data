// this code was generated using the rkwarddev package.
// perhaps don't make changes here, but in the rkwarddev script instead!

function preview(){
	preprocess(true);
	calculate(true);
	printout(true);
}

function preprocess(is_preview){
	// add requirements etc. here
	if(is_preview) {
		echo("if(!base::require(ggplot2)){stop(" + i18n("Preview not available, because package ggplot2 is not installed or cannot be loaded.") + ")}\n");
	} else {
		echo("require(ggplot2)\n");
	}	if(is_preview) {
		echo("if(!base::require(dplyr)){stop(" + i18n("Preview not available, because package dplyr is not installed or cannot be loaded.") + ")}\n");
	} else {
		echo("require(dplyr)\n");
	}	if(is_preview) {
		echo("if(!base::require(ggrepel)){stop(" + i18n("Preview not available, because package ggrepel is not installed or cannot be loaded.") + ")}\n");
	} else {
		echo("require(ggrepel)\n");
	}	if(is_preview) {
		echo("if(!base::require(lemon)){stop(" + i18n("Preview not available, because package lemon is not installed or cannot be loaded.") + ")}\n");
	} else {
		echo("require(lemon)\n");
	}	if(is_preview) {
		echo("if(!base::require(tidyr)){stop(" + i18n("Preview not available, because package tidyr is not installed or cannot be loaded.") + ")}\n");
	} else {
		echo("require(tidyr)\n");
	}	if(is_preview) {
		echo("if(!base::require(scales)){stop(" + i18n("Preview not available, because package scales is not installed or cannot be loaded.") + ")}\n");
	} else {
		echo("require(scales)\n");
	}
}

function calculate(is_preview){
	// read in variables from dialog


	// the R code to be evaluated

    function getCol(id) {
        var raw = getValue(id);
        if (!raw) return "NULL";
        if (raw.indexOf("[[") > -1) {
            var match = raw.match(/\[\[\"(.*?)\"\]\]/);
            return match ? match[1] : raw;
        }
        return raw.split("$").pop();
    }

    function getThemeCode(prefix) {
        var txt_size = getValue(prefix + "_txt_size");
        var leg_pos = getValue(prefix + "_legend_pos");
        var x_ang = getValue(prefix + "_x_angle");
        var y_ang = getValue(prefix + "_y_angle");
        var x_t_ang = getValue(prefix + "_x_title_angle");
        var y_t_ang = getValue(prefix + "_y_title_angle");

        var y_vjust = (y_t_ang == 0) ? "1.02" : "0.5";
        var y_hjust = (y_t_ang == 0) ? "0" : "0.5";

        var code = " + ggplot2::theme_minimal(base_size = " + txt_size + ")";
        code += " + ggplot2::theme(plot.title.position = \"plot\", legend.position = \"" + leg_pos + "\", legend.justification = \"left\", panel.grid.minor = ggplot2::element_blank(), panel.grid.major.x = ggplot2::element_blank())";
        code += " + ggplot2::theme(axis.title.y = ggplot2::element_text(angle = " + y_t_ang + ", vjust = " + y_vjust + ", hjust = " + y_hjust + ", color = \"gray40\"), axis.title.x = ggplot2::element_text(angle = " + x_t_ang + ", hjust = 0, color = \"gray40\"))";
        code += " + ggplot2::theme(axis.text.x = ggplot2::element_text(angle = " + x_ang + "), axis.text.y = ggplot2::element_text(angle = " + y_ang + "))";
        return code;
    }

    function getSafeColor(id, defaultVal) {
        var c = getValue(id);
        if (!c || c === "") return defaultVal;
        return c;
    }
  
    var df = getValue("line_data"); var x = getCol("line_x"); var y = getCol("line_y"); var grp = getCol("line_grp");
    var f_txt = getValue("line_focus_groups"); var f_n = getValue("line_top_n");
    echo("plot_data <- " + df + "\n");
    echo("focus_col <- \"" + getSafeColor("line_col_focus", "#941100") + "\"\n");
    echo("ctx_col <- \"" + getSafeColor("line_col_context", "#D9D9D9") + "\"\n");
    echo("plot_data <- plot_data %>% dplyr::mutate(story_focus = FALSE)\n");
    if (f_n > 0) {
        echo("top_groups <- plot_data %>% dplyr::group_by(across(all_of(\"" + grp + "\"))) %>% dplyr::summarise(max_val = max(across(all_of(\"" + y + "\")), na.rm=TRUE)) %>% dplyr::slice_max(max_val, n=" + f_n + ") %>% dplyr::pull(\"" + grp + "\")\n");
        echo("plot_data <- plot_data %>% dplyr::mutate(story_focus = (" + grp + " %in% top_groups))\n");
    } else if (f_txt != "") {
        var manual_list = f_txt.split(",").map(function(s){ return "\"" + s.trim() + "\""; }).join(", ");
        echo("plot_data <- plot_data %>% dplyr::mutate(story_focus = (" + grp + " %in% c(" + manual_list + ")) )\n");
    }
    echo("p <- ggplot2::ggplot(plot_data, ggplot2::aes(x = .data[[\"" + x + "\"]], y = .data[[\"" + y + "\"]], group = .data[[\"" + grp + "\"]])) +\n");
    echo("  ggplot2::geom_line(data = . %>% dplyr::filter(!story_focus), color = ctx_col, size = 0.5) +\n");
    echo("  ggplot2::geom_line(data = . %>% dplyr::filter(story_focus), color = focus_col, size = 1.2)\n");
    echo("p <- p + ggrepel::geom_text_repel(data = . %>% dplyr::filter(story_focus) %>% dplyr::filter(.data[[\"" + x + "\"]] == max(.data[[\"" + x + "\"]])), ggplot2::aes(label = .data[[\"" + grp + "\"]]), color = focus_col, nudge_x = 0.5, direction = \"y\", hjust = 0, size = 4, fontface = \"bold\")\n");
    var tit = getValue("line_title"); if(tit) echo("p <- p + ggplot2::labs(title = \"" + tit + "\")\n");
    echo("p <- p " + getThemeCode("line") + "\n");
  
}

function printout(is_preview){
	// read in variables from dialog


	// printout the results
	if(!is_preview) {
		new Header(i18n("Focus Line Chart results")).print();	
	}
        if (is_preview) {
            echo("print(p)\n");
        } else {
            var opts = [];
            opts.push("device.type=\"" + getValue("line_dev_type") + "\"");
            opts.push("width=" + getValue("line_dev_w"));
            opts.push("height=" + getValue("line_dev_h"));
            opts.push("res=" + getValue("line_dev_res"));
            opts.push("bg=\"" + getValue("line_dev_bg") + "\"");
            echo("rk.graph.on(" + opts.join(", ") + ")\n");
            echo("print(p)\n");
            echo("rk.graph.off()\n");
            echo("p_line_focus <- p\n");
        }
      
	if(!is_preview) {
		//// save result object
		// read in saveobject variables
		var lineSave = getValue("line_save");
		var lineSaveActive = getValue("line_save.active");
		var lineSaveParent = getValue("line_save.parent");
		// assign object to chosen environment
		if(lineSaveActive) {
			echo(".GlobalEnv$" + lineSave + " <- p_line_focus\n");
		}	
	}

}

