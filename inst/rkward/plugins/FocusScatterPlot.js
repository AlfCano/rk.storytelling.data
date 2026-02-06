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
        code += " + ggplot2::theme(plot.title = ggplot2::element_text(face = \"bold\", color = \"#111111\"), plot.subtitle = ggplot2::element_text(color = \"#555555\", margin = ggplot2::margin(b = 10)))";
        code += " + ggplot2::theme(axis.title.y = ggplot2::element_text(angle = " + y_t_ang + ", vjust = " + y_vjust + ", hjust = " + y_hjust + ", color = \"gray30\", face = \"bold\"), axis.title.x = ggplot2::element_text(angle = " + x_t_ang + ", hjust = 0, color = \"gray30\"))";
        code += " + ggplot2::theme(axis.text.x = ggplot2::element_text(angle = " + x_ang + ", color = \"gray30\"), axis.text.y = ggplot2::element_text(angle = " + y_ang + ", color = \"gray30\"))";
        return code;
    }

    function getSafeColor(id, defaultVal) {
        var c = getValue(id);
        if (!c || c === "") return defaultVal;
        return c;
    }
  
    var df = getValue("scat_data"); var x = getCol("scat_x"); var y = getCol("scat_y");
    var lbl = getCol("scat_lbl"); var f_txt = getValue("scat_focus_list");
    echo("plot_data <- " + df + "\n");
    echo("focus_col <- \"" + getSafeColor("scat_col_focus", "#941100") + "\"\n");
    echo("ctx_col <- \"" + getSafeColor("scat_col_context", "#D9D9D9") + "\"\n");
    if (f_txt != "") {
        var manual_list = f_txt.split(",").map(function(s){ return "\"" + s.trim() + "\""; }).join(", ");
        echo("plot_data <- plot_data %>% dplyr::mutate(story_focus = (.data[[\"" + lbl + "\"]] %in% c(" + manual_list + ")) )\n");
    } else {
        echo("plot_data$story_focus <- FALSE\n");
    }
    echo("avg_x <- mean(plot_data[[\"" + x + "\"]], na.rm=TRUE)\n");
    echo("avg_y <- mean(plot_data[[\"" + y + "\"]], na.rm=TRUE)\n");
    echo("p <- ggplot2::ggplot(plot_data, ggplot2::aes(x = .data[[\"" + x + "\"]], y = .data[[\"" + y + "\"]])) +\n");
    echo("  ggplot2::geom_point(ggplot2::aes(color = story_focus), size = 3) +\n");
    echo("  ggplot2::scale_color_manual(values = c(\"FALSE\" = ctx_col, \"TRUE\" = focus_col))\n");
    if (getValue("scat_avg_x") == "1") {
        echo("p <- p + ggplot2::geom_vline(xintercept = avg_x, linetype = \"dashed\", color = \"gray60\") + ");
        echo("ggplot2::annotate(\"text\", x = avg_x, y = max(plot_data[[\"" + y + "\"]], na.rm=TRUE), label = \"AVG\", angle = 90, color = \"gray60\", vjust = -0.5)\n");
    }
    if (getValue("scat_avg_y") == "1") {
        echo("p <- p + ggplot2::geom_hline(yintercept = avg_y, linetype = \"dashed\", color = \"gray60\") + ");
        echo("ggplot2::annotate(\"text\", x = max(plot_data[[\"" + x + "\"]], na.rm=TRUE), y = avg_y, label = \"AVG\", color = \"gray60\", vjust = -0.5)\n");
    }
    if (getValue("scat_avg_cross") == "1") {
        echo("p <- p + ggplot2::geom_point(ggplot2::aes(x = avg_x, y = avg_y), size = 4, color = \"black\") + ");
        echo("ggplot2::geom_label(ggplot2::aes(x = avg_x, y = avg_y, label = \"AVG\"), hjust = 1.25, label.size = 0, fill = \"white\", alpha = 0.7)\n");
    }
    echo("p <- p + ggrepel::geom_text_repel(data = . %>% dplyr::filter(story_focus), ggplot2::aes(label = .data[[\"" + lbl + "\"]]), color = focus_col, fontface = \"bold\")\n");
    var tit = getValue("scat_title"); if(tit) echo("p <- p + ggplot2::labs(title = \"" + tit + "\")\n");
    echo("p <- p " + getThemeCode("scat") + "\n");
    if (getValue("scat_capped") == "1") {
        echo("p <- p + ggplot2::theme(axis.line = ggplot2::element_line(color=\"black\")) + lemon::coord_capped_cart(bottom=\"right\", left=\"top\")\n");
    }
  
}

function printout(is_preview){
	// read in variables from dialog


	// printout the results
	if(!is_preview) {
		new Header(i18n("Focus Scatter Plot results")).print();	
	}
        if (is_preview) {
            echo("print(p)\n");
        } else {
            var opts = [];
            opts.push("device.type=\"" + getValue("scat_dev_type") + "\"");
            opts.push("width=" + getValue("scat_dev_w"));
            opts.push("height=" + getValue("scat_dev_h"));
            opts.push("res=" + getValue("scat_dev_res"));
            opts.push("bg=\"" + getValue("scat_dev_bg") + "\"");
            echo("rk.graph.on(" + opts.join(", ") + ")\n");
            echo("print(p)\n");
            echo("rk.graph.off()\n");
            echo("p_scatter_focus <- p\n");
        }
      
	if(!is_preview) {
		//// save result object
		// read in saveobject variables
		var scatSave = getValue("scat_save");
		var scatSaveActive = getValue("scat_save.active");
		var scatSaveParent = getValue("scat_save.parent");
		// assign object to chosen environment
		if(scatSaveActive) {
			echo(".GlobalEnv$" + scatSave + " <- p_scatter_focus\n");
		}	
	}

}

