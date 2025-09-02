# AI Prompt Generation Scripts

This directory contains interactive scripts to help you generate customized AI prompts for creating certification practice questions.

## Available Scripts

### PowerShell Script (Windows)

- **File**: `Generate-PromptTemplate.ps1`
- **Usage**: `.\Generate-PromptTemplate.ps1`
- **Help**: `.\Generate-PromptTemplate.ps1 -Help`

### Bash Script (Linux/macOS/WSL)

- **File**: `generate-prompt-template.sh`
- **Usage**: `./generate-prompt-template.sh`
- **Help**: `./generate-prompt-template.sh --help`

## How It Works

Both scripts will guide you through an interactive questionnaire to collect:

1. **Certification Details**
   - Full certification name (e.g., "AZ-104 Azure Administrator Associate")
   - Primary technology (e.g., "Azure", "AWS", "Kubernetes")
   - Technology vendor (e.g., "Microsoft", "Amazon", "Google")
   - Professional role title (e.g., "Azure Administrator", "Solutions Architect")

2. **Documentation URLs**
   - Official documentation URL
   - Learning platform URL

3. **Question Parameters**
   - Number of questions to generate
   - Specific domain/focus area
   - Domain percentage of the exam

4. **Exam Domains**
   - List of exam domains with percentages

## Output

The scripts will generate a customized AI prompt that you can:

- Copy and paste into ChatGPT, Claude, or other AI tools
- Optionally save to a timestamped file in the `prompts/` directory

## Usage Example

### Running the PowerShell Script

```powershell
# Navigate to the quiz-grader directory
cd c:\gh\quiz-grader

# Run the script
.\Generate-PromptTemplate.ps1
```

### Running the Bash Script

```bash
# Navigate to the quiz-grader directory
cd /path/to/quiz-grader

# Make the script executable (Linux/macOS only)
chmod +x generate-prompt-template.sh

# Run the script
./generate-prompt-template.sh
```

### Sample Interaction

```
Full certification name: AZ-104 Azure Administrator Associate
Primary technology: Azure
Technology vendor: Microsoft
Professional role title: Azure Administrator
Official documentation URL: https://learn.microsoft.com/en-us/azure/
Learning platform URL: https://learn.microsoft.com/
Number of questions to generate [20]: 15
Specific domain/focus area: Virtual Networking
Domain percentage of exam: 25-30%

Now, let's collect the exam domains:
Domain 1: Manage Azure identities and governance - 15-20%
Domain 2: Implement and manage storage - 15-20%
Domain 3: Deploy and manage Azure compute resources - 20-25%
Domain 4: Configure and manage virtual networking - 25-30%
Domain 5: Monitor and back up Azure resources - 10-15%
Domain 6: (Press Enter to finish)

```text
Generated AI Prompt

## Generated Files

When you choose to save the prompt, it will be saved in the `prompts/` directory with a filename like:

- `ai-prompt-azure-virtual-networking-20250902-143052.txt`

## Tips for Best Results

1. **Be Specific**: Provide detailed, specific information for better AI prompts
2. **Use Official URLs**: Always use the official documentation and learning platform URLs
3. **Test Generated Questions**: Always test the AI-generated questions with the quiz application
4. **Review for Accuracy**: Verify that generated questions are technically accurate and current

## Troubleshooting

### PowerShell Execution Policy (Windows)
If you get an execution policy error, run:
```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

### Bash Permissions (Linux/macOS)

If you get a permission denied error:

```bash
chmod +x generate-prompt-template.sh
```

### WSL (Windows Subsystem for Linux)

You can use the bash script in WSL:

```bash
cd /mnt/c/gh/quiz-grader
./generate-prompt-template.sh
```

## Support

These scripts are designed to work with the universal prompt template in the main README.md file. For questions or issues, please refer to the main project documentation.
