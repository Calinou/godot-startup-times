#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

if ! command -v curl &> /dev/null; then
    echo "ERROR: curl is not installed and present in PATH, but it is required. Aborting."
    exit 1
fi

if ! command -v unzip &> /dev/null; then
    echo "ERROR: unzip is not installed and present in PATH, but it is required. Aborting."
    exit 1
fi

if ! command -v hyperfine &> /dev/null; then
    echo "ERROR: hyperfine is not installed and present in PATH, but it is required. Aborting."
    exit 1
fi

download-3.x-stable() {
    if [[ -f "Godot_v$1-stable_x11.64" ]]; then
        echo -e "\e[1m[*] 3.x stable already exists, skipping download: $1...\e[0m"
    else
        echo -e "\n\e[1m[*] Downloading 3.x stable: $1...\e[0m"
        curl -LO "https://downloads.tuxfamily.org/godotengine/$1/Godot_v$1-stable_x11.64.zip"
        unzip "Godot_v$1-stable_x11.64.zip"
        rm "Godot_v$1-stable_x11.64.zip"
    fi
}

download-3.x-prerelease() {
    # Prereleases use a different URL scheme than stable releases.
    if [[ -f "Godot_v$1-$2_x11.64" ]]; then
        echo -e "\e[1m[*] 3.x prerelease already exists, skipping download: $1 $2...\e[0m"
    else
        echo -e "\n\e[1m[*] Downloading 3.x prerelease: $1...\e[0m"
        curl -LO "https://downloads.tuxfamily.org/godotengine/$1/$2/Godot_v$1-$2_x11.64.zip"
        unzip "Godot_v$1-$2_x11.64.zip"
        rm "Godot_v$1-$2_x11.64.zip"
    fi
}

download-4.0-prealpha() {
    # 4.0 prealphas use a different URL scheme than 4.0 alphas.
    if [[ -f "Godot_v4.0-dev.$1_linux.64" ]]; then
        echo -e "\e[1m[*] 4.x prealpha already exists, skipping download: $1...\e[0m"
    else
        echo -e "\n\e[1m[*] Downloading 4.0 prealpha: $1...\e[0m"
        curl -LO "https://downloads.tuxfamily.org/godotengine/4.0/pre-alpha/4.0-dev.$1/Godot_v4.0-dev.$1_linux.64.zip"
        unzip "Godot_v4.0-dev.$1_linux.64.zip"
        rm "Godot_v4.0-dev.$1_linux.64.zip"
    fi
}

download-4.x-prerelease() {
    if [[ -f "Godot_v$1-$2_linux.64" ]]; then
        echo -e "\e[1m[*] 4.x prerelease already exists, skipping download: $1 $2...\e[0m"
    else
        echo -e "\n\e[1m[*] Downloading 4.x prerelease: $1 $2...\e[0m"
        curl -LO "https://downloads.tuxfamily.org/godotengine/$1/$2/Godot_v$1-$2_linux.64.zip"
        unzip "Godot_v$1-$2_linux.64.zip"
        rm "Godot_v$1-$2_linux.64.zip"
    fi
}

prepare-cold() {
    # Command to run before every iteration of the Hyperfine benchmark
    # (cold run testing).
    rm -rf "editor_data/" "/tmp/godot-startup-times/$1/"
    mkdir -p "/tmp/godot-startup-times/$1/"
    touch "/tmp/godot-startup-times/$1/project.godot"
}
export -f prepare-cold

prepare-warm() {
    # Command to run before every iteration of the Hyperfine benchmark
    # (warm run testing).
    mkdir -p "/tmp/godot-startup-times/$1/"
    touch "/tmp/godot-startup-times/$1/project.godot"
}
export -f prepare-warm

benchmark-project-manager() {
    # Command to run on every iteration of the Hyperfine benchmark.
    # Run Godot editor then quit after one frame was rendered.
    # Godot returns non-zero exit code in this case, so ignore that exit code
    # to prevent warnings in Hyperfine.
    "./$1" --quit || true
}
export -f benchmark-project-manager

benchmark-editor() {
    # Command to run on every iteration of the Hyperfine benchmark.
    # Run Godot editor then quit after one frame was rendered.
    # Godot returns non-zero exit code in this case, so ignore that exit code
    # to prevent warnings in Hyperfine.
    "./$1" "/tmp/godot-startup-times/$1/project.godot" --quit || true
}
export -f benchmark-editor

# Download official Godot binaries.

# 3.0 doesn't have a `--quit` CLI argument, only 3.0.1 and later do.
download-3.x-stable 3.0.1
download-3.x-stable 3.0.2
download-3.x-stable 3.0.3
download-3.x-stable 3.0.4
download-3.x-stable 3.0.5
download-3.x-stable 3.0.6
download-3.x-stable 3.1
download-3.x-stable 3.1.1
download-3.x-stable 3.1.2
download-3.x-stable 3.2
download-3.x-stable 3.2.1
download-3.x-stable 3.2.2
download-3.x-stable 3.2.3
download-3.x-stable 3.3
download-3.x-stable 3.3.1
download-3.x-stable 3.3.2
download-3.x-stable 3.3.3
download-3.x-stable 3.3.4
download-3.x-stable 3.4
download-3.x-stable 3.4.1
download-3.x-stable 3.4.2
download-3.x-stable 3.4.3
download-3.x-stable 3.4.4
download-3.x-prerelease 3.5 beta1
download-3.x-prerelease 3.5 beta2
download-3.x-prerelease 3.5 beta3
download-3.x-prerelease 3.5 beta4
download-3.x-prerelease 3.5 beta5
download-3.x-prerelease 3.5 rc1
download-3.x-prerelease 3.5 rc2
download-3.x-prerelease 3.5 rc3
download-3.x-prerelease 3.5 rc4

download-4.0-prealpha 20210727
download-4.0-prealpha 20210811
download-4.0-prealpha 20210820
download-4.0-prealpha 20210916
download-4.0-prealpha 20210924
download-4.0-prealpha 20211004
download-4.0-prealpha 20211015
download-4.0-prealpha 20211027
download-4.0-prealpha 20211108
download-4.0-prealpha 20211117
download-4.0-prealpha 20211210
download-4.0-prealpha 20220105
download-4.0-prealpha 20220118

download-4.x-prerelease 4.0 alpha1
download-4.x-prerelease 4.0 alpha2
download-4.x-prerelease 4.0 alpha3
download-4.x-prerelease 4.0 alpha4
download-4.x-prerelease 4.0 alpha5
download-4.x-prerelease 4.0 alpha6
download-4.x-prerelease 4.0 alpha7
download-4.x-prerelease 4.0 alpha8
download-4.x-prerelease 4.0 alpha9
download-4.x-prerelease 4.0 alpha10

# Clean up old files in case the benchmark was interrupted in the middle.
rm -rf "editor_data/" "/tmp/godot-startup-times/"

# Run benchmark.
# TODO: Benchmark headless mode, but in 4.0 only (there's no `--headless` switch in `3.x`).

commands_project_manager_cold=()
commands_project_manager_warm=()
commands_editor_cold=()
commands_editor_warm=()
for i in *.64; do
    echo "Adding to benchmark: $i"
    # Create list of commands to pass to Hyperfine.
    commands_project_manager_cold+=("--prepare" "prepare-cold $i" "benchmark-project-manager $i")
    commands_project_manager_warm+=("--prepare" "prepare-warm $i" "benchmark-project-manager $i")
    commands_editor_cold+=("--prepare" "prepare-cold $i" "benchmark-editor $i")
    commands_editor_warm+=("--prepare" "prepare-warm $i" "benchmark-editor $i")
done

# Number of runs to perform (must be greater than or equal to 2).
RUNS=25

# Remove `editor_data/` folder after every version run to make sure warm run results are scoped to every version.
hyperfine --warmup 1 --runs $RUNS "${commands_project_manager_cold[@]}" --cleanup "rm -rf editor_data/" --export-csv project_manager_cold.csv --export-json project_manager_cold.json --export-markdown project_manager_cold.md
hyperfine --warmup 1 --runs $RUNS "${commands_project_manager_warm[@]}" --cleanup "rm -rf editor_data/" --export-csv project_manager_warm.csv --export-json project_manager_warm.json --export-markdown project_manager_warm.md
hyperfine --warmup 1 --runs $RUNS "${commands_editor_cold[@]}" --cleanup "rm -rf editor_data/" --export-csv editor_cold.csv --export-json editor_cold.json --export-markdown editor_cold.md
hyperfine --warmup 1 --runs $RUNS "${commands_editor_warm[@]}" --cleanup "rm -rf editor_data/" --export-csv editor_warm.csv --export-json editor_warm.json --export-markdown editor_warm.md
