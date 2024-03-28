#!/bin/bash

# Function to bump the version
bump_version() {
    local current_version="$1"
    local increment_type="$2"

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

    echo "${major}.${minor}.${patch}"
}

# Function to display usage
usage() {
    echo "Usage: $0 <dependency1>:<increment_type1> <dependency2>:<increment_type2> ... <main_chart_increment>"
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

# Parse arguments for dependencies
dependencies_args="${@:1:$#-1}"
main_chart_increment="${@: -1}"

# Parse dependencies arguments
for arg in $dependencies_args; do
    IFS=':' read -r -a parts <<< "$arg"
    if [ ${#parts[@]} -ne 2 ]; then
        echo "ERROR: Invalid argument format: $arg"
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
            echo "ERROR: Invalid increment type for dependency ${dependency_name}: ${increment_type}"
            usage
            exit 1
            ;;
    esac

    # Get the current version of the dependency
    dependency_version=$(awk -v dep="$dependency_name" '
            /^ *- name: / { in_dep = ($3 == dep) }
            in_dep && /^ *version:/ { gsub(/"/, "", $2); print $2; exit }
            ' ${main_chart_file})

    # Get the value for the new dependency version
    new_dependency_version=$(bump_version "${dependency_version}" "${increment_type}")
    echo "INFO: Dependency ${dependency_name} with version ${dependency_version} is updated to ${new_dependency_version}"

    # Update the dependency version in the main Chart.yaml
    sed -i "/^ *- name: ${dependency_name}/,/^ *- /s/version: .*/version: \"${new_dependency_version}\"/" "${main_chart_file}"

    # Update the dependency version in the dependency Chart.yaml
    chart_file="charts/${dependency_name}/Chart.yaml"
    attribute_name="version:"
    sed -i "s/^${attribute_name} .*/${attribute_name} ${new_dependency_version}/" "${chart_file}"
done

# Bump version of the main chart
case "${main_chart_increment}" in
    patch|minor|major)
        ;;
    *)
        echo "ERROR: Invalid increment type for main chart: ${main_chart_increment}"
        usage
        exit 1
        ;;
esac

main_chart_version=$(grep "^version:" "${main_chart_file}" | awk '{print $2}')
new_main_chart_version=$(bump_version "${main_chart_version}" "${main_chart_increment}")
sed -i "s/^version: .*/version: ${new_main_chart_version}/" "${main_chart_file}"
echo "INFO: Main chart workflows with version ${main_chart_version} is updated to ${new_main_chart_version}"
echo

# Update the dependencies
helm dep update charts/workflows/

echo "Chart and dependency versions updated successfully."
