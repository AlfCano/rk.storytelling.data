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
		echo("if(!base::require(tidyr)){stop(" + i18n("Preview not available, because package tidyr is not installed or cannot be loaded.") + ")}\n");
	} else {
		echo("require(tidyr)\n");
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
  
    var df=getValue("slope_data"); var cat=getCol("slope_cat"); var time=getCol("slope_time"); var val=getCol("slope_val");
    echo("plot_data <- " + df + "\n");
    echo("focus_col <- \"" + getSafeColor("slope_col_focus", "#941100") + "\"\n");
    echo("p <- ggplot2::ggplot(plot_data, ggplot2::aes(x=.data[[\"" + time + "\"]], y=.data[[\"" + val + "\"]], group=.data[[\"" + cat + "\"]])) + ggplot2::geom_line(color=\"gray80\", size=1) + ggplot2::geom_point(color=\"black\", size=2) + ggplot2::theme_void()\n");
    var tit = getValue("slope_title"); if(tit) echo("p <- p + ggplot2::labs(title=\"" + tit + "\")\n");
    echo("p <- p " + getThemeCode("slope") + "\n");
  
}

function printout(is_preview){
	// read in variables from dialog


	// printout the results
	if(!is_preview) {
		new Header(i18n("Slopegraph results")).print();	
	}
        if (is_preview) {
            echo("print(p)\n");
        } else {
            var opts = [];
            opts.push("device.type=\"" + getValue("slope_dev_type") + "\"");
            opts.push("width=" + getValue("slope_dev_w"));
            opts.push("height=" + getValue("slope_dev_h"));
            opts.push("res=" + getValue("slope_dev_res"));
            opts.push("bg=\"" + getValue("slope_dev_bg") + "\"");
            echo("rk.graph.on(" + opts.join(", ") + ")\n");
            echo("print(p)\n");
            echo("rk.graph.off()\n");
            echo("p_slope <- p\n");
        }
      
	if(!is_preview) {
		//// save result object
		// read in saveobject variables
		var slopeSave = getValue("slope_save");
		var slopeSaveActive = getValue("slope_save.active");
		var slopeSaveParent = getValue("slope_save.parent");
		// assign object to chosen environment
		if(slopeSaveActive) {
			echo(".GlobalEnv$" + slopeSave + " <- p_slope\n");
		}	
	}

}

