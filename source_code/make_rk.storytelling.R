local({
  # =========================================================================================
  # 1. Package Definition and Metadata
  # =========================================================================================
  require(rkwarddev)
  rkwarddev.required("0.08-1")

  plugin_name <- "rk.storytelling.data"
  plugin_ver <- "0.1.0"

  package_about <- rk.XML.about(
    name = plugin_name,
    author = person(
      given = "Alfonso",
      family = "Cano",
      email = "alfonso.cano@correo.buap.mx",
      role = c("aut", "cre")
    ),
    about = list(
      desc = "A collection of ggplot2 wrappers designed for 'Storytelling with Data' (SWD) principles.",
      version = plugin_ver,
      date = format(Sys.Date(), "%Y-%m-%d"),
      url = "https://github.com/AlfCano/rk.storytelling.data",
      license = "GPL (>= 3)"
    )
  )

   # =========================================================================================
  # 2. Shared Helpers
  # =========================================================================================

  js_common_helper <- '
    function getCol(id) {
        var raw = getValue(id);
        if (!raw) return "NULL";
        if (raw.indexOf("[[") > -1) {
            var match = raw.match(/\\[\\[\\"(.*?)\\"\\]\\]/);
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
        code += " + ggplot2::theme(plot.title.position = \\"plot\\", legend.position = \\"" + leg_pos + "\\", legend.justification = \\"left\\", panel.grid.minor = ggplot2::element_blank(), panel.grid.major.x = ggplot2::element_blank())";
        code += " + ggplot2::theme(axis.title.y = ggplot2::element_text(angle = " + y_t_ang + ", vjust = " + y_vjust + ", hjust = " + y_hjust + ", color = \\"gray40\\"), axis.title.x = ggplot2::element_text(angle = " + x_t_ang + ", hjust = 0, color = \\"gray40\\"))";
        code += " + ggplot2::theme(axis.text.x = ggplot2::element_text(angle = " + x_ang + "), axis.text.y = ggplot2::element_text(angle = " + y_ang + "))";
        return code;
    }

    function getSafeColor(id, defaultVal) {
        var c = getValue(id);
        if (!c || c === "") return defaultVal;
        return c;
    }
  '

  make_theme_tab <- function(prefix) {
    rk.XML.col(
      rk.XML.frame(label = "Text Labels",
        rk.XML.input(label = "Main Title", id.name = paste0(prefix, "_title")),
        rk.XML.input(label = "Subtitle", id.name = paste0(prefix, "_subtitle")),
        rk.XML.row(
          rk.XML.input(label = "X-Axis Label", id.name = paste0(prefix, "_xlab")),
          rk.XML.input(label = "Y-Axis Label", id.name = paste0(prefix, "_ylab"))
        ),
        rk.XML.input(label = "Caption", id.name = paste0(prefix, "_caption"))
      ),
      rk.XML.frame(label = "Axis Title Rotation",
        rk.XML.row(
          rk.XML.spinbox(label = "X-Label Angle", id.name = paste0(prefix, "_x_title_angle"), min = -90, max = 90, initial = 0),
          rk.XML.spinbox(label = "Y-Label Angle", id.name = paste0(prefix, "_y_title_angle"), min = -90, max = 90, initial = 0)
        )
      ),
      rk.XML.frame(label = "Axis Value Rotation",
        rk.XML.row(
          rk.XML.spinbox(label = "X-Values Angle", id.name = paste0(prefix, "_x_angle"), min = -90, max = 90, initial = 0),
          rk.XML.spinbox(label = "Y-Values Angle", id.name = paste0(prefix, "_y_angle"), min = -90, max = 90, initial = 0)
        )
      ),
      rk.XML.frame(label = "Legend & Colors",
        rk.XML.row(
          rk.XML.col(rk.XML.dropdown(label = "Focus Color", id.name = paste0(prefix, "_col_focus"), options = list(
              "SWD Red (#941100)" = list(val="#941100", chk=TRUE), "SWD Blue (#1F77B4)" = list(val="#1F77B4"),
              "SWD Orange (#FF7F0E)" = list(val="#FF7F0E"), "SWD Green (#2CA02C)" = list(val="#2CA02C"),
              "SWD Purple (#9467BD)" = list(val="#9467BD"), "SWD Teal (#17BECF)" = list(val="#17BECF"), "Black" = list(val="black")
          ))),
          rk.XML.col(rk.XML.dropdown(label = "Legend Position", id.name = paste0(prefix, "_legend_pos"), options = list(
              "Top" = list(val="top", chk=TRUE), "Bottom" = list(val="bottom"), "Left" = list(val="left"), "Right" = list(val="right"), "None" = list(val="none")
          )))
        )
      ),
      rk.XML.spinbox(label = "Base Text Size", id.name = paste0(prefix, "_txt_size"), min = 8, max = 30, initial = 12)
    )
  }

  make_device_tab <- function(prefix, initial_save) {
    rk.XML.col(
      rk.XML.frame(label = "Graphics Device",
          rk.XML.dropdown(label = "Device type", id.name = paste0(prefix, "_dev_type"), options = list("PNG" = list(val = "PNG", chk = TRUE), "SVG" = list(val = "SVG"), "JPG" = list(val = "JPG"))),
          rk.XML.row(
              rk.XML.spinbox(label = "Width (px)", id.name = paste0(prefix, "_dev_w"), min = 100, max = 4000, initial = 1024),
              rk.XML.spinbox(label = "Height (px)", id.name = paste0(prefix, "_dev_h"), min = 100, max = 4000, initial = 768)
          ),
          rk.XML.col(
             rk.XML.spinbox(label = "Resolution (ppi)", id.name = paste0(prefix, "_dev_res"), min = 50, max = 600, initial = 150),
             rk.XML.dropdown(label = "Background", id.name = paste0(prefix, "_dev_bg"), options = list("Transparent" = list(val = "transparent", chk = TRUE), "White" = list(val = "white")))
          )
      ),
      rk.XML.saveobj(label = "Save Plot Object", initial = initial_save, id.name = paste0(prefix, "_save"), chk = TRUE),
      rk.XML.preview(id.name = paste0(prefix, "_preview"))
    )
  }

  make_js_print <- function(prefix, initial_save) {
      paste0('
        if (is_preview) {
            echo("print(p)\\n");
        } else {
            var opts = [];
            opts.push("device.type=\\"" + getValue("', prefix, '_dev_type") + "\\"");
            opts.push("width=" + getValue("', prefix, '_dev_w"));
            opts.push("height=" + getValue("', prefix, '_dev_h"));
            opts.push("res=" + getValue("', prefix, '_dev_res"));
            opts.push("bg=\\"" + getValue("', prefix, '_dev_bg") + "\\"");
            echo("rk.graph.on(" + opts.join(", ") + ")\\n");
            echo("print(p)\\n");
            echo("rk.graph.off()\\n");
            echo("', initial_save, ' <- p\\n");
        }
      ')
  }

  # =========================================================================================
  # 3. Component: Focus Line Chart (Main)
  # =========================================================================================
  line_vs <- rk.XML.varselector(id.name = "line_vs")
  line_data <- rk.XML.varslot(label = "Data Frame", source = "line_vs", classes = "data.frame", required = TRUE, id.name = "line_data")
  line_x <- rk.XML.varslot(label = "X Axis", source = "line_vs", required = TRUE, id.name = "line_x")
  line_y <- rk.XML.varslot(label = "Y Axis", source = "line_vs", required = TRUE, id.name = "line_y")
  line_grp <- rk.XML.varslot(label = "Grouping Variable", source = "line_vs", required = TRUE, id.name = "line_grp")
  line_focus_txt <- rk.XML.input(label = "Focus Group(s)", id.name = "line_focus_groups")
  line_focus_top <- rk.XML.spinbox(label = "Or Highlight Top N", id.name = "line_top_n", min = 0, max = 20, initial = 0)

  dialog_line <- rk.XML.dialog(label = "SWD: Focus Line Chart", child = rk.XML.row(line_vs, rk.XML.col(rk.XML.tabbook(tabs = list(
        "Data" = rk.XML.col(line_data, line_x, line_y, line_grp, rk.XML.frame(line_focus_txt, line_focus_top)),
        "Theme" = make_theme_tab("line"),
        "Output & Export" = make_device_tab("line", "p_line_focus")
    )))))

  js_calc_line <- paste0(js_common_helper, '
    var df = getValue("line_data"); var x = getCol("line_x"); var y = getCol("line_y"); var grp = getCol("line_grp");
    var f_txt = getValue("line_focus_groups"); var f_n = getValue("line_top_n");
    echo("plot_data <- " + df + "\\n");
    echo("focus_col <- \\"" + getSafeColor("line_col_focus", "#941100") + "\\"\\n");
    echo("ctx_col <- \\"" + getSafeColor("line_col_context", "#D9D9D9") + "\\"\\n");
    echo("plot_data <- plot_data %>% dplyr::mutate(story_focus = FALSE)\\n");
    if (f_n > 0) {
        echo("top_groups <- plot_data %>% dplyr::group_by(across(all_of(\\\"" + grp + "\\\"))) %>% dplyr::summarise(max_val = max(across(all_of(\\\"" + y + "\\\")), na.rm=TRUE)) %>% dplyr::slice_max(max_val, n=" + f_n + ") %>% dplyr::pull(\\\"" + grp + "\\\")\\n");
        echo("plot_data <- plot_data %>% dplyr::mutate(story_focus = (" + grp + " %in% top_groups))\\n");
    } else if (f_txt != "") {
        var manual_list = f_txt.split(",").map(function(s){ return "\\"" + s.trim() + "\\""; }).join(", ");
        echo("plot_data <- plot_data %>% dplyr::mutate(story_focus = (" + grp + " %in% c(" + manual_list + ")) )\\n");
    }
    echo("p <- ggplot2::ggplot(plot_data, ggplot2::aes(x = .data[[\\"" + x + "\\"]], y = .data[[\\"" + y + "\\"]], group = .data[[\\"" + grp + "\\"]])) +\\n");
    echo("  ggplot2::geom_line(data = . %>% dplyr::filter(!story_focus), color = ctx_col, size = 0.5) +\\n");
    echo("  ggplot2::geom_line(data = . %>% dplyr::filter(story_focus), color = focus_col, size = 1.2)\\n");
    echo("p <- p + ggrepel::geom_text_repel(data = . %>% dplyr::filter(story_focus) %>% dplyr::filter(.data[[\\"" + x + "\\"]] == max(.data[[\\"" + x + "\\"]])), ggplot2::aes(label = .data[[\\"" + grp + "\\"]]), color = focus_col, nudge_x = 0.5, direction = \\"y\\", hjust = 0, size = 4, fontface = \\"bold\\")\\n");
    var tit = getValue("line_title"); if(tit) echo("p <- p + ggplot2::labs(title = \\"" + tit + "\\")\\n");
    echo("p <- p " + getThemeCode("line") + "\\n");
  ')

  # =========================================================================================
  # 4. Component: Focus Scatter Plot (FocusScatterPlot)
  # =========================================================================================
  scat_vs <- rk.XML.varselector(id.name = "scat_vs")
  scat_data <- rk.XML.varslot(label = "Data Frame", source = "scat_vs", classes = "data.frame", required = TRUE, id.name = "scat_data")
  scat_x <- rk.XML.varslot(label = "X Axis", source = "scat_vs", required = TRUE, id.name = "scat_x")
  scat_y <- rk.XML.varslot(label = "Y Axis", source = "scat_vs", required = TRUE, id.name = "scat_y")
  scat_lbl <- rk.XML.varslot(label = "Label Variable", source = "scat_vs", required = TRUE, id.name = "scat_lbl")

  scat_avg_x <- rk.XML.cbox(label = "Show Average X Line", value = "1", chk = FALSE, id.name = "scat_avg_x")
  scat_avg_y <- rk.XML.cbox(label = "Show Average Y Line", value = "1", chk = FALSE, id.name = "scat_avg_y")
  scat_avg_cross <- rk.XML.cbox(label = "Show Average Intersection Dot", value = "1", chk = TRUE, id.name = "scat_avg_cross")
  scat_capped <- rk.XML.cbox(label = "Use Capped Axes (SWD Style)", value = "1", chk = TRUE, id.name = "scat_capped")
  scat_focus <- rk.XML.input(label = "Focus Group(s)", id.name = "scat_focus_list")

  dialog_scat <- rk.XML.dialog(label = "SWD: Focus Scatter Plot", child = rk.XML.row(scat_vs, rk.XML.col(rk.XML.tabbook(tabs = list(
        "Data" = rk.XML.col(scat_data, scat_x, scat_y, scat_lbl, rk.XML.frame(label="Averages", scat_avg_x, scat_avg_y, scat_avg_cross), scat_focus),
        "Theme" = rk.XML.col(make_theme_tab("scat"), rk.XML.frame(label="Layout", scat_capped)),
        "Output & Export" = make_device_tab("scat", "p_scatter_focus")
    )))))

  js_calc_scat <- paste0(js_common_helper, '
    var df = getValue("scat_data"); var x = getCol("scat_x"); var y = getCol("scat_y");
    var lbl = getCol("scat_lbl"); var f_txt = getValue("scat_focus_list");
    echo("plot_data <- " + df + "\\n");
    echo("focus_col <- \\"" + getSafeColor("scat_col_focus", "#941100") + "\\"\\n");
    echo("ctx_col <- \\"" + getSafeColor("scat_col_context", "#D9D9D9") + "\\"\\n");
    if (f_txt != "") {
        var manual_list = f_txt.split(",").map(function(s){ return "\\"" + s.trim() + "\\""; }).join(", ");
        echo("plot_data <- plot_data %>% dplyr::mutate(story_focus = (.data[[\\"" + lbl + "\\"]] %in% c(" + manual_list + ")) )\\n");
    } else {
        echo("plot_data$story_focus <- FALSE\\n");
    }
    echo("avg_x <- mean(plot_data[[\\"" + x + "\\"]], na.rm=TRUE)\\n");
    echo("avg_y <- mean(plot_data[[\\"" + y + "\\"]], na.rm=TRUE)\\n");
    echo("p <- ggplot2::ggplot(plot_data, ggplot2::aes(x = .data[[\\"" + x + "\\"]], y = .data[[\\"" + y + "\\"]])) +\\n");
    echo("  ggplot2::geom_point(ggplot2::aes(color = story_focus), size = 3) +\\n");
    echo("  ggplot2::scale_color_manual(values = c(\\"FALSE\\" = ctx_col, \\"TRUE\\" = focus_col))\\n");
    if (getValue("scat_avg_x") == "1") {
        echo("p <- p + ggplot2::geom_vline(xintercept = avg_x, linetype = \\"dashed\\", color = \\"gray60\\") + ");
        echo("ggplot2::annotate(\\"text\\", x = avg_x, y = max(plot_data[[\\"" + y + "\\"]], na.rm=TRUE), label = \\"AVG\\", angle = 90, color = \\"gray60\\", vjust = -0.5)\\n");
    }
    if (getValue("scat_avg_y") == "1") {
        echo("p <- p + ggplot2::geom_hline(yintercept = avg_y, linetype = \\"dashed\\", color = \\"gray60\\") + ");
        echo("ggplot2::annotate(\\"text\\", x = max(plot_data[[\\"" + x + "\\"]], na.rm=TRUE), y = avg_y, label = \\"AVG\\", color = \\"gray60\\", vjust = -0.5)\\n");
    }
    if (getValue("scat_avg_cross") == "1") {
        echo("p <- p + ggplot2::geom_point(ggplot2::aes(x = avg_x, y = avg_y), size = 4, color = \\"black\\") + ");
        echo("ggplot2::geom_label(ggplot2::aes(x = avg_x, y = avg_y, label = \\"AVG\\"), hjust = 1.25, label.size = 0, fill = \\"white\\", alpha = 0.7)\\n");
    }
    echo("p <- p + ggrepel::geom_text_repel(data = . %>% dplyr::filter(story_focus), ggplot2::aes(label = .data[[\\"" + lbl + "\\"]]), color = focus_col, fontface = \\"bold\\")\\n");
    var tit = getValue("scat_title"); if(tit) echo("p <- p + ggplot2::labs(title = \\"" + tit + "\\")\\n");
    echo("p <- p " + getThemeCode("scat") + "\\n");
    if (getValue("scat_capped") == "1") {
        echo("p <- p + ggplot2::theme(axis.line = ggplot2::element_line(color=\\"black\\")) + lemon::coord_capped_cart(bottom=\\"right\\", left=\\"top\\")\\n");
    }
  ')

  comp_scat <- rk.plugin.component("Focus Scatter Plot", xml=list(dialog=dialog_scat), js=list(require=c("ggplot2","dplyr","ggrepel","lemon"), calculate=js_calc_scat, printout=make_js_print("scat", "p_scatter_focus")), hierarchy=list("plots", "Storytelling with Data"))

  # =========================================================================================
  # 5. Component: Advanced Bar Chart (Advanced Bar Chart)
  # =========================================================================================
  bar_vs <- rk.XML.varselector(id.name = "bar_vs")
  bar_data <- rk.XML.varslot(label = "Data Frame", source = "bar_vs", classes = "data.frame", required = TRUE, id.name = "bar_data")
  bar_cat <- rk.XML.varslot(label = "X Axis (Category)", source = "bar_vs", required = TRUE, id.name = "bar_cat")
  bar_val <- rk.XML.varslot(label = "Value (Numeric)", source = "bar_vs", required = TRUE, id.name = "bar_val")
  bar_fill <- rk.XML.varslot(label = "Stack/Fill Variable", source = "bar_vs", id.name = "bar_fill")
  bar_facet <- rk.XML.varslot(label = "Facet Variable", source = "bar_vs", id.name = "bar_facet")

  bar_freq_type <- rk.XML.dropdown(label = "Frequency Type", id.name = "bar_freq_type", options = list(
      "Absolute (Counts/Sum)" = list(val = "abs", chk = TRUE),
      "Relative (100% Stacked)" = list(val = "rel")
  ))

  bar_order <- rk.XML.dropdown(label = "X-Axis Ordering", id.name = "bar_order", options = list(
      "Default (Alphabetical/Factor)" = list(val = "default", chk = TRUE),
      "By Frequency (Descending)" = list(val = "freq_desc"),
      "By Frequency (Ascending)" = list(val = "freq_asc")
  ))

  bar_rule <- rk.XML.dropdown(label = "Highlight Rule", id.name = "bar_rule", options = list(
      "None" = list(val = "none", chk = TRUE),
      "Specific Name (in Stacks or X)" = list(val = "manual")
  ))
  bar_man_val <- rk.XML.input(label = "Name to highlight", id.name = "bar_man_val")
  bar_flip_check <- rk.XML.cbox(label = "Flip Coordinates", value = "1", chk = FALSE, id.name = "bar_flip")

  bar_label_tab <- rk.XML.col(
      rk.XML.cbox(label = "Show Value Labels", value = "1", chk = TRUE, id.name = "bar_show_labels"),
      rk.XML.row(
          rk.XML.spinbox(label = "Font Size", id.name = "bar_lbl_size", min = 1, max = 15, initial = 4),
          rk.XML.dropdown(label = "Label Color", id.name = "bar_lbl_col", options = list("Black"=list(val="black", chk=TRUE), "White"=list(val="white"), "Gray"=list(val="gray40")))
      ),
      rk.XML.frame(label = "Position Adjustment",
          rk.XML.row(
              rk.XML.spinbox(label = "Vertical Adj (vjust)", id.name = "bar_lbl_vjust", min = -5, max = 5, initial = 0.5, real = TRUE),
              rk.XML.spinbox(label = "Horizontal Adj (hjust)", id.name = "bar_lbl_hjust", min = -5, max = 5, initial = 0.5, real = TRUE)
          )
      )
  )

  dialog_bar <- rk.XML.dialog(label = "SWD: Advanced Bar Chart", child = rk.XML.row(bar_vs, rk.XML.col(rk.XML.tabbook(tabs = list(
        "Data" = rk.XML.col(bar_data, bar_cat, bar_val, bar_fill, bar_facet, rk.XML.frame(label="Freq & Order", bar_freq_type, bar_order, bar_flip_check)),
        "Highlight" = rk.XML.col(rk.XML.frame(label="Rules", bar_rule, bar_man_val)),
        "Value Labels" = bar_label_tab,
        "Theme" = make_theme_tab("bar"),
        "Output & Export" = make_device_tab("bar", "p_bar_adv")
    )))))

  js_calc_bar <- paste0(js_common_helper, '
    var df = getValue("bar_data"); var x = getCol("bar_cat"); var y = getCol("bar_val");
    var fill = getCol("bar_fill"); var facet = getCol("bar_facet");
    var freq = getValue("bar_freq_type"); var order = getValue("bar_order");
    var rule = getValue("bar_rule"); var man = getValue("bar_man_val");

    echo("plot_data <- " + df + "\\n");
    echo("focus_col <- \\"" + getSafeColor("bar_col_focus", "#941100") + "\\"\\n");
    echo("ctx_col <- \\"" + getSafeColor("bar_col_context", "#D9D9D9") + "\\"\\n");

    if (freq == "rel") {
        echo("plot_data <- plot_data %>% dplyr::group_by(across(all_of(\\\"" + x + "\\\")), across(all_of(if(\\\"" + facet + "\\" != \\"NULL\\") \\"" + facet + "\\" else NULL))) %>% dplyr::mutate(PlotValue = " + y + " / sum(" + y + ", na.rm=TRUE)) %>% dplyr::ungroup()\\n");
    } else {
        echo("plot_data <- plot_data %>% dplyr::mutate(PlotValue = " + y + ")\\n");
    }

    var focus_target = (fill != "NULL") ? fill : x;
    if(rule == "manual") {
        echo("plot_data <- plot_data %>% dplyr::mutate(story_focus = (.data[[\\"" + focus_target + "\\"]] == \\"" + man + "\\"))\\n");
    } else {
        echo("plot_data$story_focus <- FALSE\\n");
    }

    var x_aes = ".data[[\\"" + x + "\\"]]";
    if (order == "freq_desc") { x_aes = "reorder(.data[[\\"" + x + "\\"]], -PlotValue)"; }
    else if (order == "freq_asc") { x_aes = "reorder(.data[[\\"" + x + "\\"]], PlotValue)"; }

    var pos = (freq == "rel") ? "fill" : "stack";
    echo("p <- ggplot2::ggplot(plot_data, ggplot2::aes(x = " + x_aes + ", y = PlotValue");
    if (fill != "NULL") { echo(", fill = .data[[\\"" + fill + "\\"]]"); } else { echo(", fill = story_focus"); }
    echo(")) + ggplot2::geom_col(position = \\"" + pos + "\\", width = 0.7, color = \\"white\\")\\n");

    if (fill != "NULL") {
        echo("lvls <- unique(as.character(plot_data[[\\"" + fill + "\\"]]))\\n");
        echo("fill_cols <- setNames(rep(ctx_col, length(lvls)), lvls)\\n");
        echo("if(\\"" + man + "\\" %in% lvls) fill_cols[\\"" + man + "\\"] <- focus_col\\n");
        echo("p <- p + ggplot2::scale_fill_manual(values = fill_cols)\\n");
    } else {
        echo("p <- p + ggplot2::scale_fill_manual(values = c(\\"FALSE\\" = ctx_col, \\"TRUE\\" = focus_col))\\n");
    }

    if (getValue("bar_show_labels") == "1") {
        var label_fmt = (freq == "rel") ? "scales::percent(PlotValue, accuracy=1)" : "round(PlotValue, 1)";
        var lbl_size = getValue("bar_lbl_size");
        var lbl_col = getValue("bar_lbl_col");
        var vjust = getValue("bar_lbl_vjust");
        var hjust = getValue("bar_lbl_hjust");
        echo("p <- p + ggplot2::geom_text(ggplot2::aes(label = " + label_fmt + "), position = ggplot2::position_" + pos + "(vjust = " + vjust + "), hjust = " + hjust + ", color = \\"" + lbl_col + "\\", size = " + lbl_size + ")\\n");
    }

    if (facet != "NULL") {
        echo("p <- p + ggplot2::facet_grid(~.data[[\\"" + facet + "\\"]], switch = \\"both\\") + ggplot2::theme(strip.placement = \\"outside\\", strip.background = ggplot2::element_blank())\\n");
    }

    var xlab = getValue("bar_xlab"); if(xlab) echo("p <- p + ggplot2::xlab(\\"" + xlab + "\\")\\n");
    var ylab = getValue("bar_ylab"); if(ylab) echo("p <- p + ggplot2::ylab(\\"" + ylab + "\\")\\n");
    var tit = getValue("bar_title"); if(tit) echo("p <- p + ggplot2::labs(title = \\"" + tit + "\\")\\n");
    var sub = getValue("bar_subtitle"); if(sub) echo("p <- p + ggplot2::labs(subtitle = \\"" + sub + "\\")\\n");
    var cap = getValue("bar_caption"); if(cap) echo("p <- p + ggplot2::labs(caption = \\"" + cap + "\\")\\n");

    echo("p <- p " + getThemeCode("bar") + "\\n");

    var y_fmt = (freq == "rel") ? "scales::percent_format()" : "ggplot2::waiver()";
    echo("p <- p + ggplot2::theme(axis.line = ggplot2::element_line(color=\\"gray40\\")) + ggplot2::scale_y_continuous(labels = " + y_fmt + ", expand = c(0,0))\\n");

    if (getValue("bar_flip") == "1") {
        echo("p <- p + lemon::coord_capped_flip(left = \\"top\\", bottom = \\"right\\")\\n");
    } else {
        echo("p <- p + lemon::coord_capped_cart(left = \\"top\\")\\n");
    }
  ')

  comp_bar <- rk.plugin.component("Advanced Bar Chart", xml=list(dialog=dialog_bar), js=list(require=c("ggplot2","dplyr","lemon","scales"), calculate=js_calc_bar, printout=make_js_print("bar", "p_bar_adv")), hierarchy=list("plots", "Storytelling with Data"))

  # =========================================================================================
  # 6. Component: Slopegraph
  # =========================================================================================
  slope_vs <- rk.XML.varselector(id.name="slope_vs")
  slope_data <- rk.XML.varslot(label="Data Frame", source="slope_vs", classes="data.frame", required=TRUE, id.name="slope_data")
  slope_cat <- rk.XML.varslot(label="Entity Variable", source="slope_vs", required=TRUE, id.name="slope_cat")
  slope_time <- rk.XML.varslot(label="Time (2 levels)", source="slope_vs", required=TRUE, id.name="slope_time")
  slope_val <- rk.XML.varslot(label="Value", source="slope_vs", required=TRUE, id.name="slope_val")

  dialog_slope <- rk.XML.dialog(label="SWD: Slopegraph", child=rk.XML.row(slope_vs, rk.XML.col(rk.XML.tabbook(tabs=list("Data"=rk.XML.col(slope_data, slope_cat, slope_time, slope_val), "Theme"=make_theme_tab("slope"), "Output & Export"=make_device_tab("slope", "p_slope"))))))

  js_calc_slope <- paste0(js_common_helper, '
    var df=getValue("slope_data"); var cat=getCol("slope_cat"); var time=getCol("slope_time"); var val=getCol("slope_val");
    echo("plot_data <- " + df + "\\n");
    echo("focus_col <- \\"" + getSafeColor("slope_col_focus", "#941100") + "\\"\\n");
    echo("p <- ggplot2::ggplot(plot_data, ggplot2::aes(x=.data[[\\"" + time + "\\"]], y=.data[[\\"" + val + "\\"]], group=.data[[\\"" + cat + "\\"]])) + ggplot2::geom_line(color=\\"gray80\\", size=1) + ggplot2::geom_point(color=\\"black\\", size=2) + ggplot2::theme_void()\\n");
    var tit = getValue("slope_title"); if(tit) echo("p <- p + ggplot2::labs(title=\\"" + tit + "\\")\\n");
    echo("p <- p " + getThemeCode("slope") + "\\n");
  ')

  comp_slope <- rk.plugin.component("Slopegraph", xml=list(dialog=dialog_slope), js=list(require=c("ggplot2","dplyr","tidyr"), calculate=js_calc_slope, printout=make_js_print("slope", "p_slope")), hierarchy=list("plots", "Storytelling with Data"))

  # =========================================================================================
  # 7. Component: Dumbbell Plot
  # =========================================================================================
  dumb_vs <- rk.XML.varselector(id.name="dumb_vs")
  dumb_data <- rk.XML.varslot(label="Data Frame", source="dumb_vs", classes="data.frame", required=TRUE, id.name="dumb_data")
  dumb_cat <- rk.XML.varslot(label="Category", source="dumb_vs", required=TRUE, id.name="dumb_cat")
  dumb_v1 <- rk.XML.varslot(label="Start Value", source="dumb_vs", required=TRUE, id.name="dumb_v1")
  dumb_v2 <- rk.XML.varslot(label="End Value", source="dumb_vs", required=TRUE, id.name="dumb_v2")

  dialog_dumb <- rk.XML.dialog(label="SWD: Dumbbell Plot", child=rk.XML.row(dumb_vs, rk.XML.col(rk.XML.tabbook(tabs=list("Data"=rk.XML.col(dumb_data, dumb_cat, dumb_v1, dumb_v2), "Theme"=make_theme_tab("dumb"), "Output & Export"=make_device_tab("dumb", "p_dumbbell"))))))

  js_calc_dumb <- paste0(js_common_helper, '
    var df=getValue("dumb_data"); var cat=getCol("dumb_cat"); var v1=getCol("dumb_v1"); var v2=getCol("dumb_v2");
    echo("plot_data <- " + df + "\\n");
    echo("focus_col <- \\"" + getSafeColor("dumb_col_focus", "#941100") + "\\"\\n");
    echo("p <- ggplot2::ggplot(plot_data) + ggplot2::geom_segment(ggplot2::aes(x=.data[[\\"" + v1 + "\\"]], xend=.data[[\\"" + v2 + "\\"]], y=reorder(.data[[\\"" + cat + "\\"]], .data[[\\"" + v2 + "\\"]]), yend=.data[[\\"" + cat + "\\"]]), color=\\"gray80\\", size=1.5) + ggplot2::geom_point(ggplot2::aes(x=.data[[\\"" + v1 + "\\"]], y=.data[[\\"" + cat + "\\"]]), color=\\"gray80\\", size=3) + ggplot2::geom_point(ggplot2::aes(x=.data[[\\"" + v2 + "\\"]], y=.data[[\\"" + cat + "\\"]]), color=focus_col, size=3)\\n");
    var tit = getValue("dumb_title"); if(tit) echo("p <- p + ggplot2::labs(title=\\"" + tit + "\\")\\n");
    echo("p <- p " + getThemeCode("dumb") + "\\n");
  ')

  comp_dumb <- rk.plugin.component("Dumbbell Plot", xml=list(dialog=dialog_dumb), js=list(require=c("ggplot2","dplyr"), calculate=js_calc_dumb, printout=make_js_print("dumb", "p_dumbbell")), hierarchy=list("plots", "Storytelling with Data"))

  # =========================================================================================
  # 8. Component: Big Number Summary
  # =========================================================================================
bn_val <- rk.XML.input(label = "Large Value", initial = "91%", id.name = "bn_val")
  bn_text <- rk.XML.input(label = "Context Text", initial = "summary text here", id.name = "bn_text")

  # Simplified Theme Tab for Big Number (No Axis Rotation)
  bn_theme_tab <- rk.XML.col(
      rk.XML.frame(label = "Text Labels",
        rk.XML.input(label = "Main Title", id.name = "bn_title"),
        rk.XML.input(label = "Subtitle", id.name = "bn_subtitle")
      ),
      rk.XML.frame(label = "Colors",
             rk.XML.dropdown(label = "Focus Color", id.name = "bn_col_focus", options = list(
              "SWD Red (#941100)" = list(val="#941100", chk=TRUE), "SWD Blue (#1F77B4)" = list(val="#1F77B4"),
              "SWD Orange (#FF7F0E)" = list(val="#FF7F0E"), "SWD Green (#2CA02C)" = list(val="#2CA02C"),
              "SWD Purple (#9467BD)" = list(val="#9467BD"), "SWD Teal (#17BECF)" = list(val="#17BECF"), "Black" = list(val="black")
              ))
      ),
      rk.XML.spinbox(label = "Base Text Size", id.name = "bn_txt_size", min = 8, max = 30, initial = 12)
  )

  dialog_bn <- rk.XML.dialog(label = "SWD: Big Number Summary", child = rk.XML.row(rk.XML.col(rk.XML.tabbook(tabs = list(
        "Content" = rk.XML.col(bn_val, bn_text),
        "Theme" = bn_theme_tab,
        "Output & Export" = make_device_tab("bn", "p_big_number")
    )))))

  js_calc_bn <- paste0(js_common_helper, '
    var val = getValue("bn_val"); var txt = getValue("bn_text");
    var focus_col = getSafeColor("bn_col_focus", "#FF7F0E");

    echo("p <- ggplot2::ggplot() + ");
    echo("ggplot2::annotate(\\"text\\", x = 0, y = 0.2, label = \\"" + val + "\\", size = 40, fontface = \\"bold\\", color = \\"" + focus_col + "\\") + ");
    echo("ggplot2::annotate(\\"text\\", x = 0, y = -0.1, label = \\"" + txt + "\\", size = 8, color = \\"gray40\\") + ");
    echo("ggplot2::xlim(-1, 1) + ggplot2::ylim(-0.5, 0.5)\\n");

    var tit = getValue("bn_title"); if(tit) echo("p <- p + ggplot2::labs(title = \\"" + tit + "\\")\\n");
    var sub = getValue("bn_subtitle"); if(sub) echo("p <- p + ggplot2::labs(subtitle = \\"" + sub + "\\")\\n");

    echo("p <- p + ggplot2::theme_void(base_size = " + getValue("bn_txt_size") + ") + ");
    echo("ggplot2::theme(plot.title.position = \\"plot\\", ");
    echo("plot.title = ggplot2::element_text(hjust = 0, color = \\"gray40\\", face = \\"bold\\"), ");
    echo("plot.subtitle = ggplot2::element_text(hjust = 0, color = \\"gray40\\"))\\n");
  ')

   comp_bn <- rk.plugin.component("Big Number Summary", xml=list(dialog=dialog_bn), js=list(require=c("ggplot2"), calculate=js_calc_bn, printout=make_js_print("bn", "p_big_number")), hierarchy=list("plots", "Storytelling with Data"))

  # =========================================================================================
  # 9. Assembly
  # =========================================================================================
  component_list <- list(comp_scat, comp_bar, comp_slope, comp_dumb, comp_bn)

  rk.plugin.skeleton(
    about = package_about,
    path = ".",
    xml = list(dialog = dialog_line),
    js = list(
        require = c("ggplot2", "dplyr", "ggrepel", "lemon", "tidyr", "scales"),
        calculate = js_calc_line,
        printout = make_js_print("line", "p_line_focus")
    ),
    components = component_list,
    pluginmap = list(
        name = "Focus Line Chart",
        hierarchy = list("plots", "Storytelling with Data")
       ),
    create = c("pmap", "xml", "js", "desc", "rkh"),
    load = TRUE, overwrite = TRUE, show = FALSE
  )
cat("\nPlugin 'rk.storytelling.data' (v0.1.0) created successfully.\n")
})
