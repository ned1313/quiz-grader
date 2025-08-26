# AZ-104 Question Bank Management

This directory contains a comprehensive question bank for the Microsoft AZ-104 Azure Administrator certification exam.

## 📚 Question Bank Files

### Main Question Bank

- **`az104-question-bank.json`** - Comprehensive mixed questions covering all exam domains (20 questions)

### Domain-Specific Question Banks

- **`az104-storage-questions.json`** - Storage and data management questions (10 questions)
- **`az104-vm-questions.json`** - Virtual machines and compute questions (10 questions)  
- **`az104-networking-questions.json`** - Networking and security questions (10 questions)

### Advanced Domain-Specific Question Banks

- **`az104-identity-governance-advanced.json`** - Advanced Identity and Governance questions (15 questions)
- **`az104-storage-advanced.json`** - Advanced Storage management questions (15 questions)
- **`az104-compute-advanced.json`** - Advanced Compute and VM management questions (15 questions)
- **`az104-networking-advanced.json`** - Advanced Networking and security questions (15 questions)
- **`az104-monitoring-backup-advanced.json`** - Advanced Monitoring and Backup questions (15 questions)

### Sample Files

- **`sample-quiz.json`** - Basic sample for testing the quiz application

## 🎯 AZ-104 Exam Domains Covered

### 1. Manage Azure Identities and Governance (15-20%)

- Azure Active Directory
- Role-based access control (RBAC)
- Azure Policy and Blueprints
- Privileged Identity Management

### 2. Implement and Manage Storage (15-20%)

- Storage accounts and redundancy
- Azure Blob Storage and lifecycle management
- Azure Files and managed disks
- Data transfer and backup solutions

### 3. Deploy and Manage Azure Compute Resources (20-25%)

- Virtual machines and availability
- VM Scale Sets and containers
- Azure App Service and Functions
- Automation and configuration management

### 4. Configure and Manage Virtual Networking (25-30%)

- Virtual networks and subnets
- Network security groups and firewalls
- VPN and ExpressRoute connectivity
- Load balancing and traffic management

### 5. Monitor and Back Up Azure Resources (10-15%)

- Azure Monitor and Log Analytics
- Backup and Site Recovery
- Alerting and diagnostics
- Performance monitoring and troubleshooting

- Azure Monitor and Log Analytics
- Alerts and action groups
- Azure Backup and Site Recovery
- Performance monitoring

## 🚀 How to Use the Question Banks

### Using Individual Files

1. Load any individual JSON file into the quiz application
2. Select Practice or Exam mode
3. Complete the quiz and review results

### Combining Question Banks

To create a larger quiz combining multiple domains:

```bash
# Example PowerShell script to combine question banks
$questions = @()
$questions += (Get-Content "az104-storage-questions.json" | ConvertFrom-Json).questions
$questions += (Get-Content "az104-vm-questions.json" | ConvertFrom-Json).questions
$questions += (Get-Content "az104-networking-questions.json" | ConvertFrom-Json).questions

$combinedQuiz = @{
    title = "AZ-104 Combined Practice Exam"
    questions = $questions
}

$combinedQuiz | ConvertTo-Json -Depth 10 | Out-File "combined-practice-exam.json"
```

## 📝 Question Format

Each question follows this structure:

```json
{
  "question": "Question text here",
  "correct_answer": "The correct answer",
  "wrong_answers": ["Wrong 1", "Wrong 2", "Wrong 3", "Wrong 4"],
  "explanation": "Detailed explanation of why this is correct",
  "references": ["Documentation link", "Study guide reference"],
  "category": "Domain category"
}
```

## 📖 Study Tips

### Exam Preparation Strategy

1. **Start with domain-specific quizzes** to identify weak areas
2. **Use Practice Mode** to learn from immediate feedback
3. **Take full practice exams** in Exam Mode to simulate real conditions
4. **Review incorrect answers** thoroughly with explanations and references
5. **Focus on categories** where you score below 70%

### Key Study Areas

- **Hands-on Practice**: Use Azure portal, CLI, and PowerShell
- **Official Documentation**: Follow reference links in questions
- **Practice Labs**: Complete exercises for each domain
- **Community Resources**: Join Azure certification study groups

## 🎓 Certification Information

- **Exam Code**: AZ-104
- **Duration**: 120 minutes
- **Passing Score**: 700 out of 1000 points
- **Question Types**: Multiple choice, multiple response, drag-and-drop, case studies
- **Prerequisites**: Basic understanding of Azure services

## 🔄 Updating Question Banks

To add new questions:

1. Follow the JSON format above
2. Include detailed explanations
3. Add relevant documentation references
4. Categorize by exam domain
5. Test with the quiz application

## 🤖 AI Question Generation Prompt

Use this comprehensive prompt when generating new AZ-104 certification questions with AI tools:

### Prompt Template

```text
You are an expert Azure administrator and certification trainer creating high-quality AZ-104 practice questions. Generate [NUMBER] challenging questions for the [DOMAIN] domain of the AZ-104 certification exam.

**Requirements:**
- Target the AZ-104 Azure Administrator Associate certification level
- Focus on [SPECIFIC DOMAIN] which represents [PERCENTAGE]% of the exam
- Create scenario-based questions that test practical application, not just memorization
- Include real-world situations an Azure administrator would encounter
- Ensure questions test deep understanding of Azure concepts and best practices

**Question Format (JSON):**
```

```json
{
  "question": "Detailed scenario-based question (2-4 sentences)",
  "correct_answer": "Precise, actionable correct answer",
  "wrong_answers": ["Plausible but incorrect option", "Another realistic distractor", "Common misconception", "Related but wrong approach"],
  "explanation": "Comprehensive explanation (3-5 sentences) covering why the correct answer is right and why others are wrong. Include key concepts and best practices.",
  "references": ["https://learn.microsoft.com/... (official Microsoft Learn URL)", "https://docs.microsoft.com/... (official documentation URL)"],
  "category": "[Domain Name]"
}
```

```text
**Content Guidelines:**

- Use current Azure services and features (as of 2025)
- Include specific Azure resource names, settings, and configurations
- Test understanding of service limits, pricing tiers, and architectural decisions
- Cover troubleshooting scenarios and performance optimization
- Include security, compliance, and governance considerations
- Reference real Azure portal workflows and PowerShell/CLI commands

**Quality Standards:**

- Questions should require 2-3 levels of Azure knowledge to answer correctly
- Distractors should be realistic options an inexperienced admin might choose
- Explanations must reference official Microsoft documentation
- Each question should teach something valuable beyond just testing knowledge
- Avoid questions with obvious answers or trick questions

**Domain-Specific Focus Areas:**

**Identity and Governance (15-20%):**

- Azure AD user and group management, RBAC assignments
- Conditional Access policies and MFA configuration
- Azure Policy implementation and compliance monitoring
- Privileged Identity Management and access reviews

**Storage (15-20%):**

- Storage account configuration and security features
- Blob lifecycle management and access tiers
- Azure Files integration and hybrid scenarios
- Backup strategies and disaster recovery

**Compute (20-25%):**

- VM deployment, scaling, and availability options
- Container services and App Service configurations
- Automation scripts and configuration management
- Performance monitoring and troubleshooting

**Networking (25-30%):**

- Virtual network design and subnet planning
- Network security groups and application security groups
- VPN Gateway and ExpressRoute configurations
- Load balancer and Application Gateway scenarios

**Monitoring and Backup (10-15%):**

- Azure Monitor alerting and Log Analytics queries
- Backup policies and recovery scenarios
- Site Recovery planning and testing
- Performance diagnostics and optimization

Generate questions that an experienced Azure administrator would find challenging but fair, reflecting real-world scenarios they encounter in enterprise environments.
```

### Example Usage

Replace placeholders with specific values:

- `[NUMBER]`: 10, 15, 20, etc.
- `[DOMAIN]`: "Identity and Governance", "Storage", etc.
- `[SPECIFIC DOMAIN]`: More detailed focus area
- `[PERCENTAGE]`: Exam weight percentage

### Quality Validation

Before adding generated questions:

1. Verify all reference URLs are valid and current
2. Test questions with the quiz application
3. Ensure explanations are comprehensive and educational
4. Confirm difficulty level matches AZ-104 Associate level
5. Review for technical accuracy and current Azure features

## 📚 Additional Resources

- [Microsoft Learn AZ-104 Path](https://docs.microsoft.com/en-us/learn/certifications/exams/az-104)
- [Azure Documentation](https://docs.microsoft.com/en-us/azure/)
- [AZ-104 Exam Skills Outline](https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RE4pCWy)
- [Azure CLI Reference](https://docs.microsoft.com/en-us/cli/azure/)
- [Azure PowerShell Reference](https://docs.microsoft.com/en-us/powershell/azure/)

Good luck with your AZ-104 certification journey! 🎉
