#!/bin/bash

# Function to bump the version
bump_version() {
    local chart_file="$1"
    local line_name="$2"
    local increment_type="$3"
    
    # Get current version
    local version_line=$(grep "^${line_name}" "${chart_file}")
    local current_version=$(echo "${version_line}" | awk '{print $2}')
    local major=$(echo "${current_version}" | cut -d '.' -f1)
    local minor=$(echo "${current_version}" | cut -d '.' -f2)
    local patch=$(echo "${current_version}" | cut -d '.' -f3)
    
    # Increment version based on type
    case "${increment_type}" in
        minor)
            ((minor++))
            patch=0  # Reset patch version to 0 after bumping minor version
            ;;
        major)
            ((major++))
            minor=0
            patch=0
            ;;
        patch)
            ((patch++))
            ;;
        *)
            echo "Invalid increment type"
            exit 1
            ;;
    esac

    new_version="${major}.${minor}.${patch}"
    sed -i "s/^${line_name} .*/${line_name} ${new_version}/" "${chart_file}"
}

# Function to display usage
usage() {
    echo "Usage: $0 <dependency1>:<increment_type1> <dependency2>:<increment_type2> ..."
    echo "Dependency names must match the folder names of the dependency charts."
    echo "Increment type options: patch, minor, major"
}

# Check if at least one argument is provided
if [ $# -eq 0 ]; then
    echo "Error: No arguments provided"
    usage
    exit 1
fi

# File path to the main Chart.yaml
main_chart_file="charts/workflows/Chart.yaml"

# Parse arguments
for arg in "$@"; do
    IFS=':' read -r -a parts <<< "$arg"
    if [ ${#parts[@]} -ne 2 ]; then
        echo "Error: Invalid argument format: $arg"
        usage
        exit 1
    fi
    dependency_name="${parts[0]}"
    increment_type="${parts[1]}"
    
    # Check if increment type is valid
    case "${increment_type}" in
        patch|minor|major)
            ;;
        *)
            echo "Error: Invalid increment type: ${increment_type}"
            usage
            exit 1
            ;;
    esac
    
    # Get the current version of the dependency
    dependency_version=$(grep "^ *- name: ${dependency_name}" "${main_chart_file}" | awk '/version:/{print $2}')

    # Bump the dependency version
    bump_version "charts/workflows/charts/${dependency_name}/Chart.yaml" "version:" "${increment_type}"

    # Update the dependency version in the main Chart.yaml
    sed -i "s|^ *- name: ${dependency_name}.*|  - name: ${dependency_name}\n    version: \"${dependency_version}\"|" "${main_chart_file}"
done

# Bump version in main Chart.yaml after updating dependencies
for arg in "$@"; do
    IFS=':' read -r -a parts <<< "$arg"
    dependency_name="${parts[0]}"
    increment_type="${parts[1]}"
    bump_version "${main_chart_file}" "version:" "${increment_type}"
    break
done

echo "Chart and dependency versions updated successfully."
