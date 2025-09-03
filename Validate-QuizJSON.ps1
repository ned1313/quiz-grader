# Quiz JSON Validation Script
# PowerShell script to validate quiz question JSON files for proper structure and content

param(
    [Parameter(Mandatory=$true)]
    [string]$FilePath,
    [switch]$VerboseOutput,
    [switch]$Fix,
    [switch]$Help
)

if ($Help) {
    Write-Host "Quiz JSON Validation Script" -ForegroundColor Green
    Write-Host "==========================" -ForegroundColor Green
    Write-Host ""
    Write-Host "This script validates quiz question JSON files for proper structure and content."
    Write-Host ""
    Write-Host "Usage: .\Validate-QuizJSON.ps1 -FilePath <path-to-json-file> [options]"
    Write-Host ""
    Write-Host "Parameters:"
    Write-Host "  -FilePath        Path to the JSON file to validate (required)"
    Write-Host "  -VerboseOutput   Show detailed validation information"
    Write-Host "  -Fix             Attempt to automatically fix common issues"
    Write-Host "  -Help            Show this help message"
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  .\Validate-QuizJSON.ps1 -FilePath 'AZ-104\sample-quiz.json'"
    Write-Host "  .\Validate-QuizJSON.ps1 -FilePath 'quiz.json' -VerboseOutput"
    Write-Host "  .\Validate-QuizJSON.ps1 -FilePath 'quiz.json' -Fix"
    Write-Host ""
    return
}

# Validation counters
$script:ErrorCount = 0
$script:WarningCount = 0
$script:InfoCount = 0
$script:FixedCount = 0

# Validation functions
function Write-ValidationError {
    param([string]$Message, [string]$Location = "")
    $locationText = if ($Location) { " [$Location]" } else { "" }
    Write-Host "❌ ERROR$locationText : $Message" -ForegroundColor Red
    $script:ErrorCount++
}

function Write-ValidationWarning {
    param([string]$Message, [string]$Location = "")
    $locationText = if ($Location) { " [$Location]" } else { "" }
    Write-Host "⚠️  WARNING$locationText : $Message" -ForegroundColor Yellow
    $script:WarningCount++
}

function Write-ValidationInfo {
    param([string]$Message, [string]$Location = "")
    if ($VerboseOutput) {
        $locationText = if ($Location) { " [$Location]" } else { "" }
        Write-Host "ℹ️  INFO$locationText : $Message" -ForegroundColor Cyan
        $script:InfoCount++
    }
}

function Write-ValidationFixed {
    param([string]$Message, [string]$Location = "")
    $locationText = if ($Location) { " [$Location]" } else { "" }
    Write-Host "🔧 FIXED$locationText : $Message" -ForegroundColor Green
    $script:FixedCount++
}

function Test-JsonSyntax {
    param([string]$FilePath)
    
    Write-ValidationInfo "Testing JSON syntax..."
    
    try {
        $content = Get-Content $FilePath -Raw -ErrorAction Stop
        $jsonData = $content | ConvertFrom-Json -ErrorAction Stop
        Write-ValidationInfo "JSON syntax is valid"
        return $jsonData
    }
    catch {
        Write-ValidationError "Invalid JSON syntax: $($_.Exception.Message)"
        return $null
    }
}

function Test-RequiredTopLevelFields {
    param([object]$JsonData)
    
    Write-ValidationInfo "Testing top-level required fields..."
    
    $requiredFields = @("title", "questions")
    $isValid = $true
    
    foreach ($field in $requiredFields) {
        if (-not $JsonData.PSObject.Properties.Name -contains $field) {
            Write-ValidationError "Missing required top-level field: '$field'"
            $isValid = $false
        }
        elseif ($field -eq "questions") {
            # Questions field validation handled separately below
            continue
        }
        elseif ([string]::IsNullOrWhiteSpace($JsonData.$field)) {
            Write-ValidationError "Top-level field '$field' is empty or null"
            $isValid = $false
        }
    }
    
    # Check if questions is an array
    if ($JsonData.PSObject.Properties.Name -contains "questions") {
        if ($JsonData.questions -isnot [Array]) {
            Write-ValidationError "Field 'questions' must be an array"
            $isValid = $false
        }
        elseif ($JsonData.questions.Count -eq 0) {
            Write-ValidationError "Questions array is empty - at least one question is required"
            $isValid = $false
        }
        else {
            Write-ValidationInfo "Found $($JsonData.questions.Count) questions"
        }
    }
    
    return $isValid
}

function Test-OptionalTopLevelFields {
    param([object]$JsonData)
    
    Write-ValidationInfo "Testing optional top-level fields..."
    
    $optionalFields = @("description", "exam_weight", "difficulty", "question_count", "created")
    
    foreach ($field in $optionalFields) {
        if ($JsonData.PSObject.Properties.Name -contains $field) {
            if ([string]::IsNullOrWhiteSpace($JsonData.$field)) {
                Write-ValidationWarning "Optional field '$field' is present but empty"
            }
            else {
                Write-ValidationInfo "Optional field '$field' found with value: $($JsonData.$field)"
            }
        }
    }
}

function Test-QuestionStructure {
    param([object]$JsonData)
    
    Write-ValidationInfo "Testing question structure..."
    
    $requiredQuestionFields = @("question", "correct_answer", "wrong_answers")
    $optionalQuestionFields = @("explanation", "references", "category")
    $isValid = $true
    
    for ($i = 0; $i -lt $JsonData.questions.Count; $i++) {
        $question = $JsonData.questions[$i]
        $questionNumber = $i + 1
        $location = "Question $questionNumber"
        
        Write-ValidationInfo "Validating question $questionNumber..." $location
        
        # Check if question is an object
        if ($question -isnot [PSCustomObject]) {
            Write-ValidationError "Question $questionNumber is not a valid object" $location
            $isValid = $false
            continue
        }
        
        # Check required fields
        foreach ($field in $requiredQuestionFields) {
            if (-not $question.PSObject.Properties.Name -contains $field) {
                if ($Fix -and $field -eq "correct_answer" -and $question.PSObject.Properties.Name -contains "current_answer") {
                    # Fix common typo: current_answer -> correct_answer
                    $question | Add-Member -NotePropertyName "correct_answer" -NotePropertyValue $question.current_answer -Force
                    $question.PSObject.Properties.Remove("current_answer")
                    Write-ValidationFixed "Renamed 'current_answer' to 'correct_answer'" $location
                }
                else {
                    Write-ValidationError "Missing required field '$field'" $location
                    $isValid = $false
                }
            }
            elseif ([string]::IsNullOrWhiteSpace($question.$field) -and $field -ne "wrong_answers") {
                Write-ValidationError "Required field '$field' is empty" $location
                $isValid = $false
            }
        }
        
        # Check wrong_answers array
        if ($question.PSObject.Properties.Name -contains "wrong_answers") {
            if ($question.wrong_answers -isnot [Array]) {
                Write-ValidationError "Field 'wrong_answers' must be an array" $location
                $isValid = $false
            }
            elseif ($question.wrong_answers.Count -eq 0) {
                Write-ValidationError "Field 'wrong_answers' cannot be empty" $location
                $isValid = $false
            }
            else {
                # Check each wrong answer
                for ($j = 0; $j -lt $question.wrong_answers.Count; $j++) {
                    if ([string]::IsNullOrWhiteSpace($question.wrong_answers[$j])) {
                        Write-ValidationError "wrong_answers[$j] is empty" $location
                        $isValid = $false
                    }
                }
                
                Write-ValidationInfo "Found $($question.wrong_answers.Count) wrong answers" $location
            }
        }
        
        # Check for duplicate answers
        if ($question.PSObject.Properties.Name -contains "correct_answer" -and 
            $question.PSObject.Properties.Name -contains "wrong_answers") {
            
            $allAnswers = @($question.correct_answer) + $question.wrong_answers
            $uniqueAnswers = $allAnswers | Select-Object -Unique
            
            if ($allAnswers.Count -ne $uniqueAnswers.Count) {
                Write-ValidationError "Duplicate answers found - all answers must be unique" $location
                $isValid = $false
            }
            else {
                Write-ValidationInfo "All answers are unique" $location
            }
        }
        
        # Check optional fields
        foreach ($field in $optionalQuestionFields) {
            if ($question.PSObject.Properties.Name -contains $field) {
                if ($field -eq "references") {
                    if ($question.references -isnot [Array]) {
                        Write-ValidationWarning "Field 'references' should be an array" $location
                    }
                    elseif ($question.references.Count -eq 0) {
                        Write-ValidationWarning "Field 'references' is present but empty" $location
                    }
                    else {
                        # Check each reference
                        for ($k = 0; $k -lt $question.references.Count; $k++) {
                            if ([string]::IsNullOrWhiteSpace($question.references[$k])) {
                                Write-ValidationWarning "references[$k] is empty" $location
                            }
                            elseif ($question.references[$k] -match "^https?://") {
                                Write-ValidationInfo "Valid URL reference found" $location
                            }
                        }
                    }
                }
                elseif ([string]::IsNullOrWhiteSpace($question.$field)) {
                    Write-ValidationWarning "Optional field '$field' is present but empty" $location
                }
                else {
                    Write-ValidationInfo "Optional field '$field' found" $location
                }
            }
        }
        
        # Check for unknown fields
        $knownFields = $requiredQuestionFields + $optionalQuestionFields + @("current_answer") # Include current_answer as it might be fixed
        foreach ($property in $question.PSObject.Properties.Name) {
            if ($property -notin $knownFields) {
                Write-ValidationWarning "Unknown field '$property' found" $location
            }
        }
    }
    
    return $isValid
}

function Test-ContentQuality {
    param([object]$JsonData)
    
    Write-ValidationInfo "Testing content quality..."
    
    for ($i = 0; $i -lt $JsonData.questions.Count; $i++) {
        $question = $JsonData.questions[$i]
        $questionNumber = $i + 1
        $location = "Question $questionNumber"
        
        # Check question length
        if ($question.PSObject.Properties.Name -contains "question") {
            $questionLength = $question.question.Length
            if ($questionLength -lt 10) {
                Write-ValidationWarning "Question text is very short ($questionLength characters)" $location
            }
            elseif ($questionLength -gt 1000) {
                Write-ValidationWarning "Question text is very long ($questionLength characters)" $location
            }
        }
        
        # Check answer consistency
        if ($question.PSObject.Properties.Name -contains "correct_answer" -and 
            $question.PSObject.Properties.Name -contains "wrong_answers") {
            
            $correctLength = $question.correct_answer.Length
            $wrongLengths = $question.wrong_answers | ForEach-Object { $_.Length }
            $avgWrongLength = ($wrongLengths | Measure-Object -Average).Average
            
            if ($correctLength -lt 5) {
                Write-ValidationWarning "Correct answer is very short ($correctLength characters)" $location
            }
            
            if ([Math]::Abs($correctLength - $avgWrongLength) -gt 200) {
                Write-ValidationWarning "Significant length difference between correct and wrong answers" $location
            }
        }
        
        # Check explanation length
        if ($question.PSObject.Properties.Name -contains "explanation") {
            $explanationLength = $question.explanation.Length
            if ($explanationLength -lt 50) {
                Write-ValidationWarning "Explanation is very short ($explanationLength characters)" $location
            }
            elseif ($explanationLength -gt 2000) {
                Write-ValidationWarning "Explanation is very long ($explanationLength characters)" $location
            }
        }
    }
}

# Main validation function
function Invoke-QuizValidation {
    param([string]$FilePath)
    
    Write-Host "╔══════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║                     Quiz JSON Validation Report                     ║" -ForegroundColor Cyan
    Write-Host "╚══════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "File: $FilePath" -ForegroundColor White
    Write-Host "Date: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor White
    Write-Host ""
    
    # Check if file exists
    if (-not (Test-Path $FilePath)) {
        Write-ValidationError "File not found: $FilePath"
        return $false
    }
    
    # Test JSON syntax
    $jsonData = Test-JsonSyntax -FilePath $FilePath
    if (-not $jsonData) {
        return $false
    }
    
    # Run validation tests
    $validationResults = @()
    $validationResults += Test-RequiredTopLevelFields -JsonData $jsonData
    Test-OptionalTopLevelFields -JsonData $jsonData
    $validationResults += Test-QuestionStructure -JsonData $jsonData
    Test-ContentQuality -JsonData $jsonData
    
    # Save fixed content if fixes were applied
    if ($Fix -and $script:FixedCount -gt 0) {
        try {
            $jsonData | ConvertTo-Json -Depth 10 | Set-Content $FilePath -Encoding UTF8
            Write-Host ""
            Write-Host "✅ File has been updated with fixes applied" -ForegroundColor Green
        }
        catch {
            Write-ValidationError "Failed to save fixed content: $($_.Exception.Message)"
        }
    }
    
    # Summary
    Write-Host ""
    Write-Host "╔══════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║                         Validation Summary                          ║" -ForegroundColor Cyan
    Write-Host "╚══════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    
    $overallValid = ($script:ErrorCount -eq 0)
    
    if ($overallValid) {
        Write-Host "🎉 VALIDATION PASSED - No critical errors found!" -ForegroundColor Green
    }
    else {
        Write-Host "💥 VALIDATION FAILED - Critical errors found!" -ForegroundColor Red
    }
    
    Write-Host ""
    Write-Host "Results:" -ForegroundColor White
    Write-Host "  ❌ Errors:   $script:ErrorCount" -ForegroundColor $(if ($script:ErrorCount -eq 0) { "Green" } else { "Red" })
    Write-Host "  ⚠️  Warnings: $script:WarningCount" -ForegroundColor $(if ($script:WarningCount -eq 0) { "Green" } else { "Yellow" })
    
    if ($VerboseOutput) {
        Write-Host "  ℹ️  Info:     $script:InfoCount" -ForegroundColor Cyan
    }
    
    if ($Fix) {
        Write-Host "  🔧 Fixed:    $script:FixedCount" -ForegroundColor $(if ($script:FixedCount -eq 0) { "Gray" } else { "Green" })
    }
    
    Write-Host ""
    
    if ($script:ErrorCount -gt 0) {
        Write-Host "Please fix the errors above and run validation again." -ForegroundColor Red
    }
    elseif ($script:WarningCount -gt 0) {
        Write-Host "Consider addressing the warnings above for better quality." -ForegroundColor Yellow
    }
    
    return $overallValid
}

# Run validation
try {
    $isValid = Invoke-QuizValidation -FilePath $FilePath
    
    if ($isValid) {
        exit 0
    } else {
        exit 1
    }
}
catch {
    Write-Host "❌ Validation script error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
