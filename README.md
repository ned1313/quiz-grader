# Technology Certification Quiz Grader

A comprehensive quiz application for studying technology certification exams with AI-generated practice questions.

## 📚 Project Structure

### Certification Folders

Each certification can have its own folder containing:

- **Question bank files** - JSON files with practice questions organized by domain
- **AI generation prompts** - Templates for creating new questions
- **Study guides** - Certification-specific preparation materials

I've deliberately added the question bank files to the gitignore. Use the prompt to make your own!

### Current Certifications

- **`AZ-104/`** - Microsoft Azure Administrator Associate certification
- **`sample-quiz.json`** - Basic sample for testing the quiz application

### Core Application Files

- **`index.html`** - Main quiz application interface
- **`script.js`** - Quiz logic and functionality
- **`Manage-QuestionBank.ps1`** - PowerShell utilities for question management
- **`Generate-PromptTemplate.ps1`** - Interactive PowerShell script for AI prompt generation
- **`generate-prompt-template.sh`** - Interactive bash script for AI prompt generation

## 🎯 Supported Question Types

For the moment, all questions will be multiple choice with one correct answer and three distractors. This is an area for possible improvment. Matching, fill in the blank, drop downs, and multi-select could be added. This would require updating the JSON structure and the `script.js` functionality.

## 🚀 How to Use the Quiz Application

If you don't already have question banks for your certification, us the interactive prompt generation scripts to develop a prompt.

### Getting Started

1. **Choose a certification folder** (e.g., AZ-104/)
2. **Load a question bank file** into the quiz application
3. **Select Practice or Exam mode** based on your study goals
4. **Complete the quiz** and review results with detailed explanations

### Combining Question Banks

To create larger practice exams combining multiple domains:

```bash
# Example PowerShell script to combine question banks
$questions = @()
$questions += (Get-Content "certification/domain1-questions.json" | ConvertFrom-Json).questions
$questions += (Get-Content "certification/domain2-questions.json" | ConvertFrom-Json).questions
$questions += (Get-Content "certification/domain3-questions.json" | ConvertFrom-Json).questions

$combinedQuiz = @{
    title = "Combined Practice Exam"
    questions = $questions
}

$combinedQuiz | ConvertTo-Json -Depth 10 | Out-File "combined-practice-exam.json"
```

## 🤖 Interactive Prompt Generation

### Quick Start with AI Question Generation

To quickly generate customized AI prompts for your certification:

**Windows (PowerShell):**

```powershell
.\Generate-PromptTemplate.ps1
```

**Linux/macOS/WSL (Bash):**

```bash
./generate-prompt-template.sh
```

These interactive scripts will guide you through creating a customized AI prompt based on your specific certification needs.

### Integrated Workflow

1. **Generate AI Prompt** using the prompt generation scripts
2. **Create Questions** using AI tools with the generated prompt
3. **Save JSON File** with the AI-generated questions
4. **Validate Questions** using the validation scripts
5. **Fix Any Issues** reported by the validation tool
6. **Deploy to Quiz** once validation passes

## 🎉 Get Started

1. **Clone the repository**
2. **Navigate to a certification folder** (e.g., AZ-104/)
3. **Open index.html** in your web browser
4. **Load a question bank file** and start practicing
5. **Track your progress** and focus on weak areas

Good luck with your certification journey! 🚀
