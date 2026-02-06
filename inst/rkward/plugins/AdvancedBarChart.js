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
		echo("if(!base::require(lemon)){stop(" + i18n("Preview not available, because package lemon is not installed or cannot be loaded.") + ")}\n");
	} else {
		echo("require(lemon)\n");
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
  
    var df = getValue("bar_data"); var x = getCol("bar_cat"); var y = getCol("bar_val");
    var fill = getCol("bar_fill"); var facet = getCol("bar_facet");
    var freq = getValue("bar_freq_type"); var order = getValue("bar_order");
    var rule = getValue("bar_rule"); var man = getValue("bar_man_val");

    echo("plot_data <- " + df + "\n");
    echo("focus_col <- \"" + getSafeColor("bar_col_focus", "#941100") + "\"\n");
    echo("ctx_col <- \"" + getSafeColor("bar_col_context", "#D9D9D9") + "\"\n");

    if (freq == "rel") {
        echo("plot_data <- plot_data %>% dplyr::group_by(across(all_of(\"" + x + "\")), across(all_of(if(\"" + facet + "\" != \"NULL\") \"" + facet + "\" else NULL))) %>% dplyr::mutate(PlotValue = " + y + " / sum(" + y + ", na.rm=TRUE)) %>% dplyr::ungroup()\n");
    } else {
        echo("plot_data <- plot_data %>% dplyr::mutate(PlotValue = " + y + ")\n");
    }

    var focus_target = (fill != "NULL") ? fill : x;
    if(rule == "manual") {
        echo("plot_data <- plot_data %>% dplyr::mutate(story_focus = (.data[[\"" + focus_target + "\"]] == \"" + man + "\"))\n");
    } else {
        echo("plot_data$story_focus <- FALSE\n");
    }

    var x_aes = ".data[[\"" + x + "\"]]";
    if (order == "freq_desc") { x_aes = "reorder(.data[[\"" + x + "\"]], -PlotValue)"; }
    else if (order == "freq_asc") { x_aes = "reorder(.data[[\"" + x + "\"]], PlotValue)"; }

    var pos = (freq == "rel") ? "fill" : "stack";
    echo("p <- ggplot2::ggplot(plot_data, ggplot2::aes(x = " + x_aes + ", y = PlotValue");
    if (fill != "NULL") { echo(", fill = .data[[\"" + fill + "\"]]"); } else { echo(", fill = story_focus"); }
    echo(")) + ggplot2::geom_col(position = \"" + pos + "\", width = 0.7, color = \"white\")\n");

    if (fill != "NULL") {
        echo("lvls <- unique(as.character(plot_data[[\"" + fill + "\"]]))\n");
        echo("fill_cols <- setNames(rep(ctx_col, length(lvls)), lvls)\n");
        echo("if(\"" + man + "\" %in% lvls) fill_cols[\"" + man + "\"] <- focus_col\n");
        echo("p <- p + ggplot2::scale_fill_manual(values = fill_cols)\n");
    } else {
        echo("p <- p + ggplot2::scale_fill_manual(values = c(\"FALSE\" = ctx_col, \"TRUE\" = focus_col))\n");
    }

    if (getValue("bar_show_labels") == "1") {
        var label_fmt = (freq == "rel") ? "scales::percent(PlotValue, accuracy=1)" : "round(PlotValue, 1)";
        var lbl_size = getValue("bar_lbl_size");
        var lbl_col = getValue("bar_lbl_col");
        var vjust = getValue("bar_lbl_vjust");
        var hjust = getValue("bar_lbl_hjust");
        echo("p <- p + ggplot2::geom_text(ggplot2::aes(label = " + label_fmt + "), position = ggplot2::position_" + pos + "(vjust = " + vjust + "), hjust = " + hjust + ", color = \"" + lbl_col + "\", size = " + lbl_size + ")\n");
    }

    if (facet != "NULL") {
        echo("p <- p + ggplot2::facet_grid(~.data[[\"" + facet + "\"]], switch = \"both\") + ggplot2::theme(strip.placement = \"outside\", strip.background = ggplot2::element_blank())\n");
    }

    var xlab = getValue("bar_xlab"); if(xlab) echo("p <- p + ggplot2::xlab(\"" + xlab + "\")\n");
    var ylab = getValue("bar_ylab"); if(ylab) echo("p <- p + ggplot2::ylab(\"" + ylab + "\")\n");
    var tit = getValue("bar_title"); if(tit) echo("p <- p + ggplot2::labs(title = \"" + tit + "\")\n");
    var sub = getValue("bar_subtitle"); if(sub) echo("p <- p + ggplot2::labs(subtitle = \"" + sub + "\")\n");
    var cap = getValue("bar_caption"); if(cap) echo("p <- p + ggplot2::labs(caption = \"" + cap + "\")\n");

    echo("p <- p " + getThemeCode("bar") + "\n");

    var y_fmt = (freq == "rel") ? "scales::percent_format()" : "ggplot2::waiver()";
    echo("p <- p + ggplot2::theme(axis.line = ggplot2::element_line(color=\"gray40\")) + ggplot2::scale_y_continuous(labels = " + y_fmt + ", expand = c(0,0))\n");

    if (getValue("bar_flip") == "1") {
        echo("p <- p + lemon::coord_capped_flip(left = \"top\", bottom = \"right\")\n");
    } else {
        echo("p <- p + lemon::coord_capped_cart(left = \"top\")\n");
    }
  
}

function printout(is_preview){
	// read in variables from dialog


	// printout the results
	if(!is_preview) {
		new Header(i18n("Advanced Bar Chart results")).print();	
	}
        if (is_preview) {
            echo("print(p)\n");
        } else {
            var opts = [];
            opts.push("device.type=\"" + getValue("bar_dev_type") + "\"");
            opts.push("width=" + getValue("bar_dev_w"));
            opts.push("height=" + getValue("bar_dev_h"));
            opts.push("res=" + getValue("bar_dev_res"));
            opts.push("bg=\"" + getValue("bar_dev_bg") + "\"");
            echo("rk.graph.on(" + opts.join(", ") + ")\n");
            echo("print(p)\n");
            echo("rk.graph.off()\n");
            echo("p_bar_adv <- p\n");
        }
      
	if(!is_preview) {
		//// save result object
		// read in saveobject variables
		var barSave = getValue("bar_save");
		var barSaveActive = getValue("bar_save.active");
		var barSaveParent = getValue("bar_save.parent");
		// assign object to chosen environment
		if(barSaveActive) {
			echo(".GlobalEnv$" + barSave + " <- p_bar_adv\n");
		}	
	}

}

