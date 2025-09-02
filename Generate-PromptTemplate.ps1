# Generate AI Question Prompt Template
# PowerShell script to create customized AI prompts for certification question generation

param(
    [switch]$Help
)

if ($Help) {
    Write-Host "Generate AI Question Prompt Template" -ForegroundColor Green
    Write-Host "=====================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "This script guides you through creating a customized AI prompt for generating"
    Write-Host "certification practice questions based on the universal template."
    Write-Host ""
    Write-Host "Usage: .\Generate-PromptTemplate.ps1"
    Write-Host ""
    Write-Host "The script will ask you a series of questions and generate a ready-to-use"
    Write-Host "AI prompt that you can copy and paste into ChatGPT, Claude, or other AI tools."
    Write-Host ""
    return
}

# Display header
Clear-Host
Write-Host "╔══════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║              AI Question Generation Prompt Builder                   ║" -ForegroundColor Cyan
Write-Host "║              Technology Certification Quiz Grader                   ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""
Write-Host "This script will help you create a customized AI prompt for generating" -ForegroundColor Yellow
Write-Host "practice questions for any technology certification." -ForegroundColor Yellow
Write-Host ""

# Function to get user input with default value
function Get-UserInput {
    param(
        [string]$Prompt,
        [string]$Default = "",
        [string]$Example = ""
    )
    
    if ($Default) {
        $promptText = "$Prompt [$Default]"
    } else {
        $promptText = $Prompt
    }
    
    if ($Example) {
        Write-Host "   Example: $Example" -ForegroundColor Gray
    }
    
    $userInput = Read-Host $promptText
    
    if ([string]::IsNullOrWhiteSpace($userInput) -and $Default) {
        return $Default
    }
    
    return $userInput
}

# Function to get multiple domains
function Get-ExamDomains {
    Write-Host ""
    Write-Host "Enter exam domains with their percentages. Press Enter with empty domain to finish." -ForegroundColor Yellow
    Write-Host "Format: Domain Name - Percentage%" -ForegroundColor Gray
    Write-Host ""
    
    $domains = @()
    $domainNumber = 1
    
    do {
        $domain = Read-Host "Domain $domainNumber"
        if (![string]::IsNullOrWhiteSpace($domain)) {
            $domains += "- $domain"
            $domainNumber++
        }
    } while (![string]::IsNullOrWhiteSpace($domain))
    
    return $domains -join "`n"
}

# Collect information
Write-Host "Please provide the following information:" -ForegroundColor Green
Write-Host "=======================================" -ForegroundColor Green
Write-Host ""

# Basic certification info
$certificationName = Get-UserInput "Full certification name" -Example "AZ-104 Azure Administrator Associate"
$technology = Get-UserInput "Primary technology" -Example "Azure, AWS, Kubernetes, etc."
$vendor = Get-UserInput "Technology vendor" -Example "Microsoft, Amazon, Google, etc."
$roleTitle = Get-UserInput "Professional role title" -Example "Azure Administrator, Solutions Architect, etc."

Write-Host ""

# Documentation URLs
$officialDocsUrl = Get-UserInput "Official documentation URL" -Example "https://learn.microsoft.com/en-us/azure/"
$learningPlatformUrl = Get-UserInput "Learning platform URL" -Example "https://learn.microsoft.com/"

Write-Host ""

# Question specifics
$numberOfQuestions = Get-UserInput "Number of questions to generate" "20" -Example "10, 15, 20, etc."
$specificDomain = Get-UserInput "Specific domain/focus area" -Example "Virtual Networking, Identity Management, etc."
$domainPercentage = Get-UserInput "Domain percentage of exam" -Example "25-30%, 15-20%, etc."

Write-Host ""

# Exam domains
Write-Host "Now, let's collect the exam domains:" -ForegroundColor Green
$examDomains = Get-ExamDomains

# Generate the prompt
Write-Host ""
Write-Host "Generating your customized AI prompt..." -ForegroundColor Green
Write-Host ""

$promptTemplate = @"
You are an expert $technology professional and certification trainer creating high-quality $certificationName practice questions. Generate $numberOfQuestions challenging questions for the $specificDomain domain of the $certificationName certification exam.

**Requirements:**
- Target the $certificationName certification level
- Focus on $specificDomain which represents $domainPercentage of the exam
- Create a mix of scenario-based questions that test practical application, and more straightforward questions that test knowledge
- Include real-world situations a $roleTitle would encounter
- Ensure questions test deep understanding of $technology concepts and best practices

**Question Format (JSON):**

```json
{
  "question": "Detailed scenario-based question (2-4 sentences)",
  "correct_answer": "Precise, actionable correct answer",
  "wrong_answers": ["Plausible but incorrect option", "Another realistic distractor", "Common misconception", "Related but wrong approach"],
  "explanation": "Comprehensive explanation (3-5 sentences) covering why the correct answer is right and why others are wrong. Include key concepts and best practices. Also include single sentence explanations of why the distractors were incorrect.",
  "references": ["$officialDocsUrl (official documentation URL)", "$learningPlatformUrl (official learning platform URL)"],
  "category": "$specificDomain"
}
```

**Content Guidelines:**

- Use current $technology services and features (as of 2025)
- Include specific $technology resource names, settings, and configurations
- Test understanding of service limits, pricing tiers, and architectural decisions
- Cover troubleshooting scenarios and performance optimization
- Include security, compliance, and governance considerations
- Reference real platform workflows and CLI/API commands

**Quality Standards:**

- Questions should require 2-3 levels of $technology knowledge to answer correctly
- Correct answers should vary in length and word choice
- Distractors should be realistic options an inexperienced professional might choose
- Distractors and correct answers should be of similar length
- Explanations must reference official $vendor documentation
- Each question should teach something valuable beyond just testing knowledge
- Avoid questions with obvious answers or trick questions

**Domain-Specific Focus Areas:**

$examDomains

Generate questions that an experienced $roleTitle would find challenging but fair, reflecting real-world scenarios they encounter in enterprise environments.
"@

# Display the generated prompt
Write-Host "╔══════════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                        Generated AI Prompt                          ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host $promptTemplate -ForegroundColor White
Write-Host ""

# Save to file option
$saveToFile = Read-Host "Would you like to save this prompt to a file? (y/N)"
if ($saveToFile -eq 'y' -or $saveToFile -eq 'Y') {
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $filename = "ai-prompt-$($technology.ToLower())-$($specificDomain -replace ' ','-' -replace '[^a-zA-Z0-9-]','').ToLower()-$timestamp.txt"
    
    # Create prompts directory if it doesn't exist
    $promptsDir = "prompts"
    if (!(Test-Path $promptsDir)) {
        New-Item -ItemType Directory -Path $promptsDir | Out-Null
    }
    
    $fullPath = Join-Path $promptsDir $filename
    $promptTemplate | Out-File -FilePath $fullPath -Encoding UTF8
    
    Write-Host ""
    Write-Host "Prompt saved to: $fullPath" -ForegroundColor Green
}

Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                             Usage Tips                              ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Copy the generated prompt above" -ForegroundColor Yellow
Write-Host "2. Paste it into your preferred AI tool (ChatGPT, Claude, etc.)" -ForegroundColor Yellow
Write-Host "3. The AI will generate questions in the correct JSON format" -ForegroundColor Yellow
Write-Host "4. Save the output as a .json file in your certification folder" -ForegroundColor Yellow
Write-Host "5. Test the questions with the quiz application" -ForegroundColor Yellow
Write-Host ""
Write-Host "Happy studying! 🚀" -ForegroundColor Green
