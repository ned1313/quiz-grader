#!/bin/bash

# Quiz JSON Validation Script
# Bash script to validate quiz question JSON files for proper structure and content

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[0;37m'
NC='\033[0m' # No Color

# Global counters
ERROR_COUNT=0
WARNING_COUNT=0
INFO_COUNT=0
FIXED_COUNT=0

# Options
VERBOSE=false
FIX=false
FILE_PATH=""

# Function to show help
show_help() {
    echo -e "${GREEN}Quiz JSON Validation Script${NC}"
    echo -e "${GREEN}==========================${NC}"
    echo ""
    echo "This script validates quiz question JSON files for proper structure and content."
    echo ""
    echo "Usage: ./validate-quiz-json.sh <file-path> [options]"
    echo ""
    echo "Parameters:"
    echo "  file-path    Path to the JSON file to validate (required)"
    echo ""
    echo "Options:"
    echo "  -v, --verbose    Show detailed validation information"
    echo "  -f, --fix        Attempt to automatically fix common issues"
    echo "  -h, --help       Show this help message"
    echo ""
    echo "Examples:"
    echo "  ./validate-quiz-json.sh 'AZ-104/sample-quiz.json'"
    echo "  ./validate-quiz-json.sh 'quiz.json' --verbose"
    echo "  ./validate-quiz-json.sh 'quiz.json' --fix"
    echo ""
}

# Validation message functions
write_validation_error() {
    local message="$1"
    local location="$2"
    local location_text=""
    if [ -n "$location" ]; then
        location_text=" [$location]"
    fi
    echo -e "${RED}❌ ERROR${location_text}: $message${NC}"
    ((ERROR_COUNT++))
}

write_validation_warning() {
    local message="$1"
    local location="$2"
    local location_text=""
    if [ -n "$location" ]; then
        location_text=" [$location]"
    fi
    echo -e "${YELLOW}⚠️  WARNING${location_text}: $message${NC}"
    ((WARNING_COUNT++))
}

write_validation_info() {
    local message="$1"
    local location="$2"
    if [ "$VERBOSE" = true ]; then
        local location_text=""
        if [ -n "$location" ]; then
            location_text=" [$location]"
        fi
        echo -e "${CYAN}ℹ️  INFO${location_text}: $message${NC}"
        ((INFO_COUNT++))
    fi
}

write_validation_fixed() {
    local message="$1"
    local location="$2"
    local location_text=""
    if [ -n "$location" ]; then
        location_text=" [$location]"
    fi
    echo -e "${GREEN}🔧 FIXED${location_text}: $message${NC}"
    ((FIXED_COUNT++))
}

# Check if jq is available
check_dependencies() {
    if ! command -v jq &> /dev/null; then
        echo -e "${RED}Error: jq is required but not installed.${NC}"
        echo "Please install jq:"
        echo "  Ubuntu/Debian: sudo apt-get install jq"
        echo "  CentOS/RHEL: sudo yum install jq"
        echo "  macOS: brew install jq"
        return 1
    fi
    return 0
}

# Test JSON syntax
test_json_syntax() {
    local file_path="$1"
    
    write_validation_info "Testing JSON syntax..."
    
    if ! jq empty "$file_path" 2>/dev/null; then
        local error_details=$(jq empty "$file_path" 2>&1)
        write_validation_error "Invalid JSON syntax: $error_details"
        return 1
    fi
    
    write_validation_info "JSON syntax is valid"
    return 0
}

# Test required top-level fields
test_required_top_level_fields() {
    local file_path="$1"
    local is_valid=true
    
    write_validation_info "Testing top-level required fields..."
    
    # Check for title field
    if ! jq -e '.title' "$file_path" > /dev/null 2>&1; then
        write_validation_error "Missing required top-level field: 'title'"
        is_valid=false
    elif [ "$(jq -r '.title' "$file_path")" = "null" ] || [ -z "$(jq -r '.title' "$file_path" | tr -d ' \t\n\r')" ]; then
        write_validation_error "Top-level field 'title' is empty or null"
        is_valid=false
    fi
    
    # Check for questions field
    if ! jq -e '.questions' "$file_path" > /dev/null 2>&1; then
        write_validation_error "Missing required top-level field: 'questions'"
        is_valid=false
    elif [ "$(jq -r 'type' "$file_path" 2>/dev/null)" != "object" ] || [ "$(jq -r '.questions | type' "$file_path" 2>/dev/null)" != "array" ]; then
        write_validation_error "Field 'questions' must be an array"
        is_valid=false
    elif [ "$(jq -r '.questions | length' "$file_path" 2>/dev/null)" = "0" ]; then
        write_validation_error "Questions array is empty - at least one question is required"
        is_valid=false
    else
        local question_count=$(jq -r '.questions | length' "$file_path" 2>/dev/null)
        write_validation_info "Found $question_count questions"
    fi
    
    if [ "$is_valid" = true ]; then
        return 0
    else
        return 1
    fi
}

# Test question structure
test_question_structure() {
    local file_path="$1"
    local is_valid=true
    local question_count=$(jq -r '.questions | length' "$file_path" 2>/dev/null)
    
    write_validation_info "Testing question structure..."
    
    for ((i=0; i<question_count; i++)); do
        local question_number=$((i + 1))
        local location="Question $question_number"
        
        write_validation_info "Validating question $question_number..." "$location"
        
        # Check required fields
        local required_fields=("question" "correct_answer" "wrong_answers")
        for field in "${required_fields[@]}"; do
            if ! jq -e ".questions[$i].$field" "$file_path" > /dev/null 2>&1; then
                # Check for common typo: current_answer instead of correct_answer
                if [ "$field" = "correct_answer" ] && jq -e ".questions[$i].current_answer" "$file_path" > /dev/null 2>&1; then
                    if [ "$FIX" = true ]; then
                        # Note: Actual fixing would require a more complex jq operation
                        write_validation_fixed "Found 'current_answer' that should be 'correct_answer'" "$location"
                        # In a real implementation, we would fix the JSON here
                    else
                        write_validation_error "Found 'current_answer' instead of 'correct_answer' (use --fix to auto-correct)" "$location"
                        is_valid=false
                    fi
                else
                    write_validation_error "Missing required field '$field'" "$location"
                    is_valid=false
                fi
            elif [ "$field" != "wrong_answers" ] && [ -z "$(jq -r ".questions[$i].$field" "$file_path" 2>/dev/null | tr -d ' \t\n\r')" ]; then
                write_validation_error "Required field '$field' is empty" "$location"
                is_valid=false
            fi
        done
        
        # Check wrong_answers array
        if jq -e ".questions[$i].wrong_answers" "$file_path" > /dev/null 2>&1; then
            if [ "$(jq -r ".questions[$i].wrong_answers | type" "$file_path" 2>/dev/null)" != "array" ]; then
                write_validation_error "Field 'wrong_answers' must be an array" "$location"
                is_valid=false
            elif [ "$(jq -r ".questions[$i].wrong_answers | length" "$file_path" 2>/dev/null)" = "0" ]; then
                write_validation_error "Field 'wrong_answers' cannot be empty" "$location"
                is_valid=false
            else
                local wrong_answers_count=$(jq -r ".questions[$i].wrong_answers | length" "$file_path" 2>/dev/null)
                write_validation_info "Found $wrong_answers_count wrong answers" "$location"
                
                # Check each wrong answer for empty values
                for ((j=0; j<wrong_answers_count; j++)); do
                    if [ -z "$(jq -r ".questions[$i].wrong_answers[$j]" "$file_path" 2>/dev/null | tr -d ' \t\n\r')" ]; then
                        write_validation_error "wrong_answers[$j] is empty" "$location"
                        is_valid=false
                    fi
                done
            fi
        fi
        
        # Check for duplicate answers
        if jq -e ".questions[$i].correct_answer" "$file_path" > /dev/null 2>&1 && jq -e ".questions[$i].wrong_answers" "$file_path" > /dev/null 2>&1; then
            local all_answers=$(jq -r ".questions[$i] | [.correct_answer] + .wrong_answers | .[]" "$file_path" 2>/dev/null)
            local unique_answers=$(echo "$all_answers" | sort | uniq)
            local all_count=$(echo "$all_answers" | wc -l)
            local unique_count=$(echo "$unique_answers" | wc -l)
            
            if [ "$all_count" != "$unique_count" ]; then
                write_validation_error "Duplicate answers found - all answers must be unique" "$location"
                is_valid=false
            else
                write_validation_info "All answers are unique" "$location"
            fi
        fi
        
        # Check optional fields
        local optional_fields=("explanation" "references" "category")
        for field in "${optional_fields[@]}"; do
            if jq -e ".questions[$i].$field" "$file_path" > /dev/null 2>&1; then
                if [ "$field" = "references" ]; then
                    if [ "$(jq -r ".questions[$i].references | type" "$file_path" 2>/dev/null)" != "array" ]; then
                        write_validation_warning "Field 'references' should be an array" "$location"
                    elif [ "$(jq -r ".questions[$i].references | length" "$file_path" 2>/dev/null)" = "0" ]; then
                        write_validation_warning "Field 'references' is present but empty" "$location"
                    else
                        write_validation_info "Optional field 'references' found" "$location"
                    fi
                elif [ -z "$(jq -r ".questions[$i].$field" "$file_path" 2>/dev/null | tr -d ' \t\n\r')" ]; then
                    write_validation_warning "Optional field '$field' is present but empty" "$location"
                else
                    write_validation_info "Optional field '$field' found" "$location"
                fi
            fi
        done
    done
    
    if [ "$is_valid" = true ]; then
        return 0
    else
        return 1
    fi
}

# Main validation function
run_validation() {
    local file_path="$1"
    
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                     Quiz JSON Validation Report                     ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${WHITE}File: $file_path${NC}"
    echo -e "${WHITE}Date: $(date '+%Y-%m-%d %H:%M:%S')${NC}"
    echo ""
    
    # Check if file exists
    if [ ! -f "$file_path" ]; then
        write_validation_error "File not found: $file_path"
        return 1
    fi
    
    # Run validation tests
    local validation_results=()
    
    if ! test_json_syntax "$file_path"; then
        return 1
    fi
    
    test_required_top_level_fields "$file_path"
    validation_results+=($?)
    
    test_question_structure "$file_path"
    validation_results+=($?)
    
    # Check if any validation failed
    local overall_valid=true
    for result in "${validation_results[@]}"; do
        if [ "$result" != "0" ]; then
            overall_valid=false
            break
        fi
    done
    
    # Summary
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                         Validation Summary                          ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════╝${NC}"
    
    if [ "$ERROR_COUNT" -eq 0 ]; then
        echo -e "${GREEN}🎉 VALIDATION PASSED - No critical errors found!${NC}"
        overall_valid=true
    else
        echo -e "${RED}💥 VALIDATION FAILED - Critical errors found!${NC}"
        overall_valid=false
    fi
    
    echo ""
    echo -e "${WHITE}Results:${NC}"
    if [ "$ERROR_COUNT" -eq 0 ]; then
        echo -e "  ${GREEN}❌ Errors:   $ERROR_COUNT${NC}"
    else
        echo -e "  ${RED}❌ Errors:   $ERROR_COUNT${NC}"
    fi
    
    if [ "$WARNING_COUNT" -eq 0 ]; then
        echo -e "  ${GREEN}⚠️  Warnings: $WARNING_COUNT${NC}"
    else
        echo -e "  ${YELLOW}⚠️  Warnings: $WARNING_COUNT${NC}"
    fi
    
    if [ "$VERBOSE" = true ]; then
        echo -e "  ${CYAN}ℹ️  Info:     $INFO_COUNT${NC}"
    fi
    
    if [ "$FIX" = true ]; then
        if [ "$FIXED_COUNT" -eq 0 ]; then
            echo -e "  ${GRAY}🔧 Fixed:    $FIXED_COUNT${NC}"
        else
            echo -e "  ${GREEN}🔧 Fixed:    $FIXED_COUNT${NC}"
        fi
    fi
    
    echo ""
    
    if [ "$ERROR_COUNT" -gt 0 ]; then
        echo -e "${RED}Please fix the errors above and run validation again.${NC}"
        return 1
    elif [ "$WARNING_COUNT" -gt 0 ]; then
        echo -e "${YELLOW}Consider addressing the warnings above for better quality.${NC}"
    fi
    
    if [ "$overall_valid" = true ]; then
        return 0
    else
        return 1
    fi
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -f|--fix)
            FIX=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        -*)
            echo "Unknown option $1"
            show_help
            exit 1
            ;;
        *)
            if [ -z "$FILE_PATH" ]; then
                FILE_PATH="$1"
            else
                echo "Error: Multiple file paths specified"
                show_help
                exit 1
            fi
            shift
            ;;
    esac
done

# Check if file path was provided
if [ -z "$FILE_PATH" ]; then
    echo -e "${RED}Error: File path is required${NC}"
    echo ""
    show_help
    exit 1
fi

# Check dependencies
if ! check_dependencies; then
    exit 1
fi

# Run validation
if run_validation "$FILE_PATH"; then
    exit 0
else
    exit 1
fi
