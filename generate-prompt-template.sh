#!/bin/bash

# Generate AI Question Prompt Template
# Bash script to create customized AI prompts for certification question generation

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[0;37m'
NC='\033[0m' # No Color

# Function to display help
show_help() {
    echo -e "${GREEN}Generate AI Question Prompt Template${NC}"
    echo -e "${GREEN}=====================================${NC}"
    echo ""
    echo "This script guides you through creating a customized AI prompt for generating"
    echo "certification practice questions based on the universal template."
    echo ""
    echo "Usage: ./generate-prompt-template.sh"
    echo ""
    echo "The script will ask you a series of questions and generate a ready-to-use"
    echo "AI prompt that you can copy and paste into ChatGPT, Claude, or other AI tools."
    echo ""
}

# Function to get user input with default value
get_user_input() {
    local prompt="$1"
    local default="$2"
    local example="$3"
    local user_input
    
    if [ -n "$example" ]; then
        echo -e "   ${GRAY}Example: $example${NC}"
    fi
    
    if [ -n "$default" ]; then
        prompt_text="$prompt [$default]: "
    else
        prompt_text="$prompt: "
    fi
    
    read -p "$prompt_text" user_input
    
    if [ -z "$user_input" ] && [ -n "$default" ]; then
        echo "$default"
    else
        echo "$user_input"
    fi
}

# Function to get multiple domains
get_exam_domains() {
    echo ""
    echo -e "${YELLOW}Enter exam domains with their percentages. Press Enter with empty domain to finish.${NC}"
    echo -e "${GRAY}Format: Domain Name - Percentage%${NC}"
    echo ""
    
    local domains=""
    local domain_number=1
    
    while true; do
        read -p "Domain $domain_number: " domain
        if [ -z "$domain" ]; then
            break
        fi
        if [ -n "$domains" ]; then
            domains="$domains\n- $domain"
        else
            domains="- $domain"
        fi
        ((domain_number++))
    done
    
    echo -e "$domains"
}

# Check for help flag
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    show_help
    exit 0
fi

# Display header
clear
echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║              AI Question Generation Prompt Builder                   ║${NC}"
echo -e "${CYAN}║              Technology Certification Quiz Grader                   ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}This script will help you create a customized AI prompt for generating${NC}"
echo -e "${YELLOW}practice questions for any technology certification.${NC}"
echo ""

# Collect information
echo -e "${GREEN}Please provide the following information:${NC}"
echo -e "${GREEN}=======================================${NC}"
echo ""

# Basic certification info
certification_name=$(get_user_input "Full certification name" "" "AZ-104 Azure Administrator Associate")
technology=$(get_user_input "Primary technology" "" "Azure, AWS, Kubernetes, etc.")
vendor=$(get_user_input "Technology vendor" "" "Microsoft, Amazon, Google, etc.")
role_title=$(get_user_input "Professional role title" "" "Azure Administrator, Solutions Architect, etc.")

echo ""

# Documentation URLs
official_docs_url=$(get_user_input "Official documentation URL" "" "https://learn.microsoft.com/en-us/azure/")
learning_platform_url=$(get_user_input "Learning platform URL" "" "https://learn.microsoft.com/")

echo ""

# Question specifics
number_of_questions=$(get_user_input "Number of questions to generate" "20" "10, 15, 20, etc.")
specific_domain=$(get_user_input "Specific domain/focus area" "" "Virtual Networking, Identity Management, etc.")
domain_percentage=$(get_user_input "Domain percentage of exam" "" "25-30%, 15-20%, etc.")

echo ""

# Exam domains
echo -e "${GREEN}Now, let's collect the exam domains:${NC}"
exam_domains=$(get_exam_domains)

# Generate the prompt
echo ""
echo -e "${GREEN}Generating your customized AI prompt...${NC}"
echo ""

prompt_template="You are an expert $technology professional and certification trainer creating high-quality $certification_name practice questions. Generate $number_of_questions challenging questions for the $specific_domain domain of the $certification_name certification exam.

**Requirements:**
- Target the $certification_name certification level
- Focus on $specific_domain which represents $domain_percentage of the exam
- Create a mix of scenario-based questions that test practical application, and more straightforward questions that test knowledge
- Include real-world situations a $role_title would encounter
- Ensure questions test deep understanding of $technology concepts and best practices
- Save the file using the naming convention: $technology-$specific_domain-YYYYMMDD.json
- Save the generated JSON file to the certification folder for $certification_name

**Question Format (JSON):**

\`\`\`json
{
  \"question\": \"Detailed scenario-based question (2-4 sentences)\",
  \"correct_answer\": \"Precise, actionable correct answer\",
  \"wrong_answers\": [\"Plausible but incorrect option\", \"Another realistic distractor\", \"Common misconception\", \"Related but wrong approach\"],
  \"explanation\": \"Comprehensive explanation (3-5 sentences) covering why the correct answer is right and why others are wrong. Include key concepts and best practices. Also include single sentence explanations of why the distractors were incorrect.\",
  \"references\": [\"$official_docs_url (official documentation URL)\", \"$learning_platform_url (official learning platform URL)\"],
  \"category\": \"$specific_domain\"
}
\`\`\`

**Content Guidelines:**

- Use current $technology services and features (as of 2025)
- Reference official $vendor documentation and learning resources from the URLs provided
- Include specific $technology resource names, settings, and configurations
- Test understanding of service limits, pricing tiers, and architectural decisions
- Cover troubleshooting scenarios and performance optimization
- Include security, compliance, and governance considerations
- Reference real platform workflows and CLI/API commands
- Use MCP servers or equivalent terminology where applicable to access resources

**Quality Standards:**

- Questions should require 2-3 levels of $technology knowledge to answer correctly
- Correct answers should vary in length and word choice
- Distractors should be realistic options an inexperienced professional might choose
- Distractors and correct answers should be of similar length
- Explanations must reference official $vendor documentation
- Each question should teach something valuable beyond just testing knowledge
- Avoid questions with obvious answers or trick questions

**Domain-Specific Focus Areas:**

$(echo -e "$exam_domains")

**IMPORTANT - Post-Generation Validation:**

After generating the JSON, it's critical to validate the output before use:
1. Save the generated JSON to a file with a descriptive name
2. Run validation using: ./validate-quiz-json.sh "your-file.json"
3. Fix any errors or warnings reported by the validation script
4. Re-validate until the script reports "VALIDATION PASSED"

The validation script checks for:
- JSON syntax correctness
- Required field presence and proper data types
- Answer uniqueness and quality
- Content structure and formatting
- Common issues like field naming errors

Generate questions that an experienced $role_title would find challenging but fair, reflecting real-world scenarios they encounter in enterprise environments."

# Display the generated prompt
echo -e "${GREEN}╔══════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                        Generated AI Prompt                          ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${WHITE}$prompt_template${NC}"
echo ""

# Save to file option
read -p "Would you like to save this prompt to a file? (y/N): " save_to_file
if [ "$save_to_file" = "y" ] || [ "$save_to_file" = "Y" ]; then
    timestamp=$(date +"%Y%m%d-%H%M%S")
    # Clean the technology and domain names for filename
    tech_clean=$(echo "$technology" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-zA-Z0-9]/-/g')
    domain_clean=$(echo "$specific_domain" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-zA-Z0-9]/-/g' | sed 's/--*/-/g')
    filename="ai-prompt-$tech_clean-$domain_clean-$timestamp.txt"
    
    # Create prompts directory if it doesn't exist
    prompts_dir="prompts"
    if [ ! -d "$prompts_dir" ]; then
        mkdir -p "$prompts_dir"
    fi
    
    full_path="$prompts_dir/$filename"
    echo "$prompt_template" > "$full_path"
    
    echo ""
    echo -e "${GREEN}Prompt saved to: $full_path${NC}"
fi

echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║                             Usage Tips                              ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}1. Copy the generated prompt above${NC}"
echo -e "${YELLOW}2. Paste it into your preferred AI tool (ChatGPT, Claude, etc.)${NC}"
echo -e "${YELLOW}3. The AI will generate questions in the correct JSON format${NC}"
echo -e "${YELLOW}4. Save the output as a .json file in your certification folder${NC}"
echo -e "${RED}5. VALIDATE the JSON before using it: ./validate-quiz-json.sh 'your-file.json'${NC}"
echo -e "${YELLOW}6. Fix any validation errors or warnings reported by the script${NC}"
echo -e "${YELLOW}7. Test the questions with the quiz application${NC}"
echo ""
echo -e "${RED}╔══════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${RED}║                        Validation Important!                        ║${NC}"
echo -e "${RED}╚══════════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${RED}⚠️  ALWAYS validate your generated JSON files before deployment!${NC}"
echo ""
echo -e "${WHITE}Validation script usage:${NC}"
echo -e "${CYAN}  ./validate-quiz-json.sh 'path/to/your/questions.json'${NC}"
echo -e "${CYAN}  ./validate-quiz-json.sh 'questions.json' --verbose${NC}"
echo -e "${CYAN}  ./validate-quiz-json.sh 'questions.json' --auto-fix${NC}"
echo ""
echo -e "${WHITE}The validation script will:${NC}"
echo -e "${GRAY}  • Check JSON syntax and structure${NC}"
echo -e "${GRAY}  • Validate required fields and data types${NC}"
echo -e "${GRAY}  • Check for content quality issues${NC}"
echo -e "${GRAY}  • Detect duplicate answers${NC}"
echo -e "${GRAY}  • Auto-fix common problems (with --auto-fix)${NC}"
echo ""
echo -e "${GREEN}Happy studying! 🚀${NC}"
