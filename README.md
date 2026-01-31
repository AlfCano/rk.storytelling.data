# rk.storytelling.data: High-Impact Visualization for RKWard

![Version](https://img.shields.io/badge/Version-0.1.0-blue.svg)
![License](https://img.shields.io/badge/License-GPLv3-blue.svg)
![RKWard](https://img.shields.io/badge/Platform-RKWard-green)
[![R Linter](https://github.com/AlfCano/rk.storytelling.data/actions/workflows/lintr.yml/badge.svg)](https://github.com/AlfCano/rk.storytelling.data/actions/workflows/lintr.yml)

**rk.storytelling.data** brings the principles of Cole Nussbaumer Knaflic's *"Storytelling with Data" (SWD)* to the RKWard GUI. It provides a specialized collection of `ggplot2` wrappers designed to reduce cognitive load, eliminate clutter, and use color strategically to highlight the most important parts of your data.

## 🚀 What's New in Version 0.1.0

This is the initial release of the storytelling suite, featuring:

*   **SWD Formatting Engine:** All plots automatically implement professional storytelling standards: horizontal Y-axis titles positioned at the top-left, clean minimal grids, and "capped" axes (via the `lemon` package) that stop exactly at the data limits.
*   **Focus Logic:** Integrated highlighting rules (Max, Min, or Manual) across multiple chart types to draw the audience's eye instantly to the "so-what" of the visualization.
*   **High-Fidelity Components:** Includes six specialized plugins ranging from Advanced Bar Charts to "Big Number" impact cards.

## ✨ Features

### 1. Advanced Bar Chart
*   **Dual Frequency Modes:** Toggle between Absolute (Sum/Counts) and Relative (100% Stacked) bars.
*   **Highlighting:** Automatically turn a specific category (e.g., "Missed Goals") a focus color while keeping others in context gray.
*   **Chronological Faceting:** Group data by Year or Category with labels placed outside the axes for a clean look.
*   **Value Labels:** Precision control over font size, color, and position (`vjust`/`hjust`) for on-bar percentages.

### 2. Focus Scatter Plot
*   **Average Intersections:** Automatically calculate and draw dashed "AVG" lines for X and Y axes, including a labeled intersection point.
*   **Outlier Labeling:** Uses `ggrepel` to ensure labels for focused points never overlap.
*   **Capped Axes:** Implements the signature SWD look where axis lines are clipped to the plot area.

### 3. Focus Line Chart
*   **Series Highlighting:** Highlight one or more specific lines (e.g., "Company Performance") against a background of context lines (e.g., "Market Average").
*   **Auto-labeling:** Automatically places the series label at the end of the focus line for immediate identification.

### 4. Slopegraph & Dumbbell Plots
*   **Slopegraph:** Perfect for showing relative increases and decreases between two points in time.
*   **Dumbbell Plot:** Visualizes the "gap" between two groups (e.g., Gender Pay Gap) using a clean line-and-dot aesthetic.

### 5. Big Number Summary
*   **Impact Cards:** Create text-based "Big Number" visualizations for dashboards.
*   **Contextual Text:** Pair a large focus value (e.g., "91%") with descriptive context text in a clean, void-theme layout.

### 🛡️ Universal Features
*   **Professional Palette:** Choose from curated SWD colors (SWD Red, Blue, Orange, Green, Purple) and context grays.
*   **Live Preview:** Verify your storytelling adjustments—like axis rotation or label placement—instantly via the plot preview.
*   **Internationalization:** Fully localized interface available in:
    *   🇺🇸 English (Default)
    *   🇪🇸 Spanish (`es`)
    *   🇫🇷 French (`fr`)
    *   🇩🇪 German (`de`)
    *   🇧🇷 Portuguese (Brazil) (`pt_BR`)

## 📦 Installation

This plugin is not yet on CRAN. To install it, use the `remotes` or `devtools` package in RKWard.

1.  **Open RKWard**.
2.  **Run the following command** in the R Console:

    ```R
    # If you don't have devtools installed:
    # install.packages("devtools")
    
    local({
      require(devtools)
      install_github("AlfCano/rk.storytelling.data", force = TRUE)
    })
    ```
3.  **Restart RKWard** to load the new menu entries.

## 💻 Usage

Once installed, the tools are organized under:

**`Plots` -> `Storytelling with Data`**

## 🎓 Learning Exercises

Follow these step-by-step examples to master the storytelling tools.

### 1. Focus Line Chart
**Scenario:** Visualizing the growth of different orange trees over time. We want to highlight **Tree #1** to tell its specific growth story against the background of the others.

**A. Data Preparation (Run in Console):**
```R
# Load built-in dataset
data("Orange")
# Ensure the grouping variable is a factor or character
Orange$Tree <- as.character(Orange$Tree)
```

**B. Plugin Settings:**
*   **Data Frame:** `Orange`
*   **X Axis:** `age`
*   **Y Axis:** `circumference`
*   **Grouping Variable:** `Tree`
*   **Focus Group(s):** `1`
*   **Theme Tab:**
    *   *Title:* "Growth of Tree #1"
    *   *Focus Color:* "SWD Orange"

---

### 2. Focus Bar Chart
**Scenario:** Comparing the average body mass of penguin species. We want to automatically highlight the **heaviest** species to draw the eye immediately to the maximum value.

**A. Data Preparation (Run in Console):**
```R
library(dplyr)
# install.packages("palmerpenguins")
library(palmerpenguins)

# We need a summarized dataframe for a Bar Chart
penguin_summary <- penguins %>%
  group_by(species) %>%
  summarise(avg_mass = mean(body_mass, na.rm = TRUE))
```

**B. Plugin Settings (Advanced Bar Chart):**
*   **Data Frame:** `penguin_summary`
*   **Category (X):** `species`
*   **Value (Y):** `avg_mass`
*   **Highlight Rule:** `Max Value`
*   **Flip Coordinates:** `Checked`
*   **Theme Tab:**
    *   *Title:* "Gentoo Penguins are the Heaviest"
    *   *Focus Color:* "SWD Blue"

---

### 3. Slopegraph
**Scenario:** Comparing student test scores before and after a training program. We want to see how individual students progressed between exactly two points in time.

**A. Data Preparation (Run in Console):**
```R
# Constructing a dataset with exactly 2 time points
slope_data <- data.frame(
  Student = c("Alice", "Bob", "Charlie", "Dave", "Eve"),
  Stage = rep(c("Pre-Test", "Post-Test"), each = 5),
  Score = c(55, 45, 60, 50, 40,   # Pre scores
            85, 42, 90, 55, 75)   # Post scores
)
```

**B. Plugin Settings:**
*   **Data Frame:** `slope_data`
*   **Category:** `Student`
*   **Time:** `Stage`
*   **Value:** `Score`
*   **Theme Tab:**
    *   *Title:* "Impact of Training Program"
    *   *Focus Color:* "SWD Blue"

---

### 4. Dumbbell Plot
**Scenario:** Comparing the average body mass between Male and Female penguins within each species. This effectively visualizes the sexual dimorphism (gap) per species.

**A. Data Preparation (Run in Console):**
```R
library(tidyr)
library(dplyr)
library(palmerpenguins)

# Transform to Wide Format
dumbbell_data <- penguins %>%
  filter(!is.na(sex)) %>%
  group_by(species, sex) %>%
  summarise(mass = mean(body_mass), .groups = "drop") %>%
  pivot_wider(names_from = sex, values_from = mass)
```

**B. Plugin Settings:**
*   **Data Frame:** `dumbbell_data`
*   **Category (Y Axis):** `species`
*   **Start Value:** `female`
*   **End Value:** `male`
*   **Theme Tab:*
    *   *Title:* "Sexual Dimorphism in Penguins"
    *   *Focus Color:* "SWD Orange"

---

### 5. Big Number Summary
**Scenario:** Highlight a single, high-impact metric from a survey to replicate the "91% of kids" finding.

**A. Data Preparation (Optional):**
```R
# No specific data frame needed as we input values manually
```

**B. Plugin Settings:**
*   **Tab: Content**
    *   **Large Value:** `91%`
    *   **Context Text:** `of kids have a higher interest in science after the pilot`
*   **Tab: Theme**
    *   **Main Title:** `Pilot Program Success`
    *   **Focus Color:** `SWD Blue`

---

### 6. Focus Scatter Plot
**Scenario:** Visualizing the relationship between Miles per Gallon (mpg) and Horsepower (hp) for outliers.

**A. Data Preparation (Run in Console):**
```R
# Prepare mtcars: convert row names to a column for labeling
my_cars <- mtcars
my_cars$model <- rownames(mtcars)
```

**B. Plugin Settings:**
*   **Tab: Data**
    *   **Data Frame:** `my_cars`
    *   **X Axis:** `hp`
    *   **Y Axis:** `mpg`
    *   **Label Variable:** `model`
    *   **Focus Group(s):** `Toyota Corolla, Maserati Bora`
*   **Tab: Theme**
    *   **Main Title:* "Efficiency vs. Horsepower"
    *   **Focus Color:* "SWD Red"

---

### 7. Advanced Bar Chart: Goal Attainment
**Scenario:** Replicating FIG 0603 from SWD. Tracking project performance over three years (100% Stacked).

**A. Data Preparation (Run in Console):**
```R
# Create a synthetic dataset matching the SWD style
set.seed(42)
goals_data <- expand.grid(
  Quarter = c("Q1", "Q2", "Q3", "Q4"),
  Year = c("2013", "2014", "2015"),
  Status = c("Exceed", "Meet", "Miss")
)
goals_data$ProjectCount <- sample(10:50, nrow(goals_data), replace = TRUE)
goals_data$Year <- as.factor(goals_data$Year)
```

**B. Plugin Settings:**
*   **Tab: Data**
    *   **X Axis:** `Quarter`, **Value:** `ProjectCount`
    *   **Stack:** `Status`, **Facet:** `Year`
    *   **Frequency Type:** `Relative (100% Stacked)`
*   **Tab: Highlight**
    *   **Highlight Rule:** `Specific Name`, **Value:** `Miss`
*   **Tab: Theme**
    *   **Main Title:** `Goal attainment over time`
    *   **Focus Color:** `SWD Red`

## 🛠️ Dependencies

This plugin relies on the following R packages:
*   `ggplot2`, `dplyr`, `tidyr`, `ggrepel`, `lemon`, `scales`

#### Troubleshooting: Errors installing `devtools` or missing binary dependencies (Windows)

If you encounter errors mentioning "non-zero exit status", "namespace is already loaded", or requirements for compilation (compiling from source) when installing packages, it is likely because the R version bundled with RKWard is older than the current CRAN standard.

**Workaround:**
Until a new, more recent version of R (current bundled version is 4.3.3) is packaged into the RKWard executable, these issues will persist. To fix this:

1.  Download and install the latest version of R (e.g., 4.5.2 or newer) from [CRAN](https://cloud.r-project.org/).
2.  Open RKWard and go to the **Settings** menu.
3.  Run the **"Installation Checker"**.
4.  Point RKWard to the newly installed R version.

## ✍️ Author & License

*   **Author:** Alfonso Cano (<alfonso.cano@correo.buap.mx>)
*   **Assisted by:** Gemini, a large language model from Google.
*   **License:** GPL (>= 3)
