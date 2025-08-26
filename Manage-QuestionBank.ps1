# AZ-104 Question Bank Manager
# PowerShell script to combine and manage quiz files

param(
    [Parameter(Mandatory=$false)]
    [string]$Action = "help",
    
    [Parameter(Mandatory=$false)]
    [string[]]$Files = @(),
    
    [Parameter(Mandatory=$false)]
    [string]$OutputFile = "combined-quiz.json",
    
    [Parameter(Mandatory=$false)]
    [string]$Category = "",
    
    [Parameter(Mandatory=$false)]
    [int]$QuestionCount = 0
)

function Show-Help {
    Write-Host "AZ-104 Question Bank Manager" -ForegroundColor Green
    Write-Host "=============================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Usage:" -ForegroundColor Yellow
    Write-Host "  .\Manage-QuestionBank.ps1 -Action <action> [parameters]" -ForegroundColor White
    Write-Host ""
    Write-Host "Actions:" -ForegroundColor Yellow
    Write-Host "  combine     - Combine multiple question bank files"
    Write-Host "  filter      - Filter questions by category"
    Write-Host "  sample      - Create a sample quiz with specified number of questions"
    Write-Host "  stats       - Show statistics about question banks"
    Write-Host "  validate    - Validate question bank JSON format"
    Write-Host ""
    Write-Host "Examples:" -ForegroundColor Yellow
    Write-Host "  # Combine all domain-specific question banks"
    Write-Host "  .\Manage-QuestionBank.ps1 -Action combine -Files 'az104-storage-questions.json','az104-vm-questions.json','az104-networking-questions.json'"
    Write-Host ""
    Write-Host "  # Create a practice quiz with 15 random questions"
    Write-Host "  .\Manage-QuestionBank.ps1 -Action sample -Files 'az104-question-bank.json' -QuestionCount 15"
    Write-Host ""
    Write-Host "  # Filter questions by category"
    Write-Host "  .\Manage-QuestionBank.ps1 -Action filter -Files 'az104-question-bank.json' -Category 'Storage'"
    Write-Host ""
    Write-Host "  # Show statistics for all question banks"
    Write-Host "  .\Manage-QuestionBank.ps1 -Action stats"
}

function Combine-QuestionBanks {
    param([string[]]$InputFiles, [string]$Output)
    
    if ($InputFiles.Count -eq 0) {
        Write-Error "No input files specified. Use -Files parameter."
        return
    }
    
    $allQuestions = @()
    $totalFiles = 0
    
    foreach ($file in $InputFiles) {
        if (Test-Path $file) {
            try {
                $content = Get-Content $file -Raw | ConvertFrom-Json
                $allQuestions += $content.questions
                $totalFiles++
                Write-Host "Added $($content.questions.Count) questions from $file" -ForegroundColor Green
            }
            catch {
                Write-Error "Error reading $file : $($_.Exception.Message)"
            }
        }
        else {
            Write-Warning "File not found: $file"
        }
    }
    
    if ($allQuestions.Count -gt 0) {
        $combinedQuiz = @{
            title = "AZ-104 Combined Practice Exam"
            description = "Combined questions from $totalFiles question banks"
            questions = $allQuestions
        }
        
        $combinedQuiz | ConvertTo-Json -Depth 10 | Out-File $Output -Encoding UTF8
        Write-Host "Created combined quiz with $($allQuestions.Count) questions: $Output" -ForegroundColor Green
    }
    else {
        Write-Error "No questions found to combine."
    }
}

function Filter-QuestionsByCategory {
    param([string[]]$InputFiles, [string]$CategoryFilter, [string]$Output)
    
    if ($InputFiles.Count -eq 0) {
        Write-Error "No input files specified. Use -Files parameter."
        return
    }
    
    if ([string]::IsNullOrEmpty($CategoryFilter)) {
        Write-Error "No category specified. Use -Category parameter."
        return
    }
    
    $filteredQuestions = @()
    
    foreach ($file in $InputFiles) {
        if (Test-Path $file) {
            try {
                $content = Get-Content $file -Raw | ConvertFrom-Json
                $categoryQuestions = $content.questions | Where-Object { $_.category -like "*$CategoryFilter*" }
                $filteredQuestions += $categoryQuestions
                Write-Host "Found $($categoryQuestions.Count) questions in category '$CategoryFilter' from $file" -ForegroundColor Green
            }
            catch {
                Write-Error "Error reading $file : $($_.Exception.Message)"
            }
        }
    }
    
    if ($filteredQuestions.Count -gt 0) {
        $filteredQuiz = @{
            title = "AZ-104 $CategoryFilter Questions"
            description = "Questions filtered by category: $CategoryFilter"
            questions = $filteredQuestions
        }
        
        $filteredQuiz | ConvertTo-Json -Depth 10 | Out-File $Output -Encoding UTF8
        Write-Host "Created filtered quiz with $($filteredQuestions.Count) questions: $Output" -ForegroundColor Green
    }
    else {
        Write-Warning "No questions found for category: $CategoryFilter"
    }
}

function Create-SampleQuiz {
    param([string[]]$InputFiles, [int]$Count, [string]$Output)
    
    if ($InputFiles.Count -eq 0) {
        Write-Error "No input files specified. Use -Files parameter."
        return
    }
    
    if ($Count -le 0) {
        Write-Error "Question count must be greater than 0. Use -QuestionCount parameter."
        return
    }
    
    $allQuestions = @()
    
    foreach ($file in $InputFiles) {
        if (Test-Path $file) {
            try {
                $content = Get-Content $file -Raw | ConvertFrom-Json
                $allQuestions += $content.questions
            }
            catch {
                Write-Error "Error reading $file : $($_.Exception.Message)"
            }
        }
    }
    
    if ($allQuestions.Count -eq 0) {
        Write-Error "No questions found in input files."
        return
    }
    
    $requestedCount = [Math]::Min($Count, $allQuestions.Count)
    $selectedQuestions = $allQuestions | Get-Random -Count $requestedCount
    
    $sampleQuiz = @{
        title = "AZ-104 Practice Quiz ($requestedCount Questions)"
        description = "Random sample of $requestedCount questions for practice"
        questions = $selectedQuestions
    }
    
    $sampleQuiz | ConvertTo-Json -Depth 10 | Out-File $Output -Encoding UTF8
    Write-Host "Created sample quiz with $requestedCount questions: $Output" -ForegroundColor Green
}

function Show-Statistics {
    $questionFiles = Get-ChildItem -Filter "*questions*.json" | Where-Object { $_.Name -ne "combined-quiz.json" }
    
    if ($questionFiles.Count -eq 0) {
        Write-Warning "No question bank files found."
        return
    }
    
    Write-Host "AZ-104 Question Bank Statistics" -ForegroundColor Green
    Write-Host "===============================" -ForegroundColor Green
    Write-Host ""
    
    $totalQuestions = 0
    $categoryStats = @{}
    
    foreach ($file in $questionFiles) {
        try {
            $content = Get-Content $file.FullName -Raw | ConvertFrom-Json
            $questionCount = $content.questions.Count
            $totalQuestions += $questionCount
            
            Write-Host "$($file.Name): $questionCount questions" -ForegroundColor Yellow
            
            # Category breakdown
            foreach ($question in $content.questions) {
                if ($question.category) {
                    if ($categoryStats.ContainsKey($question.category)) {
                        $categoryStats[$question.category]++
                    }
                    else {
                        $categoryStats[$question.category] = 1
                    }
                }
            }
        }
        catch {
            Write-Error "Error reading $($file.Name): $($_.Exception.Message)"
        }
    }
    
    Write-Host ""
    Write-Host "Total Questions: $totalQuestions" -ForegroundColor Green
    Write-Host ""
    Write-Host "Questions by Category:" -ForegroundColor Yellow
    
    $categoryStats.GetEnumerator() | Sort-Object Name | ForEach-Object {
        Write-Host "  $($_.Key): $($_.Value) questions" -ForegroundColor White
    }
}

function Validate-QuestionBanks {
    param([string[]]$InputFiles)
    
    if ($InputFiles.Count -eq 0) {
        $InputFiles = (Get-ChildItem -Filter "*questions*.json").Name
    }
    
    $validationErrors = @()
    $validFiles = 0
    
    foreach ($file in $InputFiles) {
        if (-not (Test-Path $file)) {
            $validationErrors += "File not found: $file"
            continue
        }
        
        try {
            $content = Get-Content $file -Raw | ConvertFrom-Json
            
            # Validate structure
            if (-not $content.title) {
                $validationErrors += "$file : Missing 'title' field"
            }
            
            if (-not $content.questions -or $content.questions.Count -eq 0) {
                $validationErrors += "$file : Missing or empty 'questions' array"
                continue
            }
            
            # Validate each question
            for ($i = 0; $i -lt $content.questions.Count; $i++) {
                $question = $content.questions[$i]
                $prefix = "$file : Question $($i + 1)"
                
                if (-not $question.question) {
                    $validationErrors += "$prefix : Missing 'question' field"
                }
                
                if (-not $question.correct_answer) {
                    $validationErrors += "$prefix : Missing 'correct_answer' field"
                }
                
                if (-not $question.wrong_answers -or $question.wrong_answers.Count -eq 0) {
                    $validationErrors += "$prefix : Missing or empty 'wrong_answers' array"
                }
                
                if (-not $question.category) {
                    $validationErrors += "$prefix : Missing 'category' field"
                }
            }
            
            if ($validationErrors.Count -eq 0) {
                $validFiles++
                Write-Host "$file : Valid ✓" -ForegroundColor Green
            }
        }
        catch {
            $validationErrors += "$file : Invalid JSON format - $($_.Exception.Message)"
        }
    }
    
    Write-Host ""
    if ($validationErrors.Count -gt 0) {
        Write-Host "Validation Errors:" -ForegroundColor Red
        foreach ($error in $validationErrors) {
            Write-Host "  $error" -ForegroundColor Red
        }
    }
    else {
        Write-Host "All files are valid! ✓" -ForegroundColor Green
    }
    
    Write-Host "Valid files: $validFiles / $($InputFiles.Count)" -ForegroundColor Yellow
}

# Main execution
switch ($Action.ToLower()) {
    "combine" {
        Combine-QuestionBanks -InputFiles $Files -Output $OutputFile
    }
    "filter" {
        Filter-QuestionsByCategory -InputFiles $Files -CategoryFilter $Category -Output $OutputFile
    }
    "sample" {
        Create-SampleQuiz -InputFiles $Files -Count $QuestionCount -Output $OutputFile
    }
    "stats" {
        Show-Statistics
    }
    "validate" {
        Validate-QuestionBanks -InputFiles $Files
    }
    default {
        Show-Help
    }
}
