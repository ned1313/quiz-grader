# Technology Certification Quiz Grader

A comprehensive quiz application for studying technology certification exams with AI-generated practice questions.

## 📚 Project Structure

### Certification Folders

Each certification has its own folder containing:

- **Question bank files** - JSON files with practice questions organized by domain
- **AI generation prompts** - Templates for creating new questions
- **Study guides** - Certification-specific preparation materials

### Current Certifications

- **`AZ-104/`** - Microsoft Azure Administrator Associate certification
- **`sample-quiz.json`** - Basic sample for testing the quiz application

### Core Application Files

- **`index.html`** - Main quiz application interface
- **`script.js`** - Quiz logic and functionality
- **`Manage-QuestionBank.ps1`** - PowerShell utilities for question management
- **`Generate-PromptTemplate.ps1`** - Interactive PowerShell script for AI prompt generation
- **`generate-prompt-template.sh`** - Interactive bash script for AI prompt generation
- **`PROMPT-GENERATION.md`** - Documentation for the prompt generation scripts

## 🎯 Supported Question Types

The quiz application supports various question formats commonly found in technology certification exams:

- **Multiple choice** - Single correct answer from multiple options
- **Scenario-based** - Real-world situations testing practical application
- **Knowledge-based** - Direct testing of concepts, limits, and technical details
- **Mixed formats** - Combination of scenario and knowledge questions

## 🚀 How to Use the Quiz Application

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

These interactive scripts will guide you through creating a customized AI prompt based on your specific certification needs. See `PROMPT-GENERATION.md` for detailed usage instructions.

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

### Effective Study Strategy

1. **Start with domain-specific quizzes** to identify knowledge gaps
2. **Use Practice Mode** to learn from immediate feedback and explanations
3. **Take full practice exams** in Exam Mode to simulate real testing conditions
4. **Review incorrect answers** thoroughly with provided explanations and references
5. **Focus on weak areas** where you score below 70%
6. **Track progress** across multiple study sessions

### General Study Best Practices

- **Hands-on Practice**: Use the actual technology platform being tested
- **Official Documentation**: Follow reference links provided in question explanations
- **Practice Labs**: Complete hands-on exercises for each certification domain
- **Study Groups**: Join certification-specific communities and forums
- **Spaced Repetition**: Review questions multiple times over several weeks

## 🎓 Adding New Certifications

To add support for a new certification:

1. **Create a certification folder** with the exam code (e.g., `AWS-SAA/`, `GCP-ACE/`)
2. **Follow the standard JSON format** for question files
3. **Include detailed explanations** with official documentation references
4. **Organize by exam domains** with appropriate weightings
5. **Test questions** with the quiz application before publishing

## 🔄 Creating Question Banks

To add new questions to any certification:

1. **Follow the standard JSON format** shown below
2. **Include comprehensive explanations** that teach concepts
3. **Add relevant documentation references** from official sources
4. **Categorize by exam domain** or technology area
5. **Test with the quiz application** to ensure proper formatting

## 🤖 AI Question Generation Prompt

Use this comprehensive prompt template when generating new certification questions with AI tools:

### Universal Prompt Template

```text
You are an expert [TECHNOLOGY] professional and certification trainer creating high-quality [CERTIFICATION_NAME] practice questions. Generate [NUMBER] challenging questions for the [DOMAIN] domain of the [CERTIFICATION_NAME] certification exam.

**Requirements:**
- Target the [CERTIFICATION_NAME] certification level
- Focus on [SPECIFIC_DOMAIN] which represents [PERCENTAGE]% of the exam
- Create a mix of scenario-based questions that test practical application, and more straightforward questions that test knowledge
- Include real-world situations a [ROLE_TITLE] would encounter
- Ensure questions test deep understanding of [TECHNOLOGY] concepts and best practices

**Question Format (JSON):**
```

```json
{
  "question": "Detailed scenario-based question (2-4 sentences)",
  "correct_answer": "Precise, actionable correct answer",
  "wrong_answers": ["Plausible but incorrect option", "Another realistic distractor", "Common misconception", "Related but wrong approach"],
  "explanation": "Comprehensive explanation (3-5 sentences) covering why the correct answer is right and why others are wrong. Include key concepts and best practices. Also include single sentence explanations of why the distractors were incorrect.",
  "references": ["[OFFICIAL_DOCS_URL] (official documentation URL)", "[LEARNING_PLATFORM_URL] (official learning platform URL)"],
  "category": "[Domain Name]"
}
```

```text
**Content Guidelines:**

- Use current [TECHNOLOGY] services and features (as of 2025)
- Include specific [TECHNOLOGY] resource names, settings, and configurations
- Test understanding of service limits, pricing tiers, and architectural decisions
- Cover troubleshooting scenarios and performance optimization
- Include security, compliance, and governance considerations
- Reference real platform workflows and CLI/API commands

**Quality Standards:**

- Questions should require 2-3 levels of [TECHNOLOGY] knowledge to answer correctly
- Correct answers should vary in length and word choice
- Distractors should be realistic options an inexperienced professional might choose
- Distractors and correct answers should be of similar length
- Explanations must reference official [VENDOR] documentation
- Each question should teach something valuable beyond just testing knowledge
- Avoid questions with obvious answers or trick questions

**Domain-Specific Focus Areas:**

[EXAM_DOMAINS_PLACEHOLDER]

Generate questions that an experienced [ROLE_TITLE] would find challenging but fair, reflecting real-world scenarios they encounter in enterprise environments.
```

### Template Variables

Replace these placeholders with certification-specific values:

- **`[CERTIFICATION_NAME]`**: Full certification name (e.g., "AZ-104 Azure Administrator Associate")
- **`[TECHNOLOGY]`**: Primary technology (e.g., "Azure", "AWS", "Kubernetes")
- **`[VENDOR]`**: Technology vendor (e.g., "Microsoft", "Amazon", "Google")
- **`[ROLE_TITLE]`**: Professional role (e.g., "Azure Administrator", "Solutions Architect")
- **`[OFFICIAL_DOCS_URL]`**: Official documentation base URL
- **`[LEARNING_PLATFORM_URL]`**: Official learning platform URL
- **`[EXAM_DOMAINS_PLACEHOLDER]`**: Specific exam domains with percentages
- **`[NUMBER]`**: Number of questions to generate (10, 15, 20, etc.)
- **`[DOMAIN]`**: Specific domain name
- **`[SPECIFIC_DOMAIN]`**: More detailed focus area
- **`[PERCENTAGE]`**: Exam weight percentage

### Example Certifications

#### Microsoft Azure (AZ-104)

- **Certification**: AZ-104 Azure Administrator Associate
- **Technology**: Azure
- **Vendor**: Microsoft
- **Role**: Azure Administrator
- **Official Docs**: <https://learn.microsoft.com/en-us/azure/>
- **Learning Platform**: <https://learn.microsoft.com/>
- **Exam Guide**: <https://learn.microsoft.com/en-us/certifications/exams/az-104>

#### AWS (SAA-C03)

- **Certification**: AWS Certified Solutions Architect Associate
- **Technology**: AWS
- **Vendor**: Amazon
- **Role**: Solutions Architect
- **Official Docs**: <https://docs.aws.amazon.com/>
- **Learning Platform**: <https://aws.amazon.com/training/>
- **Exam Guide**: <https://aws.amazon.com/certification/certified-solutions-architect-associate/>

#### Google Cloud (ACE)

- **Certification**: Google Cloud Associate Cloud Engineer
- **Technology**: Google Cloud Platform
- **Vendor**: Google
- **Role**: Cloud Engineer
- **Official Docs**: <https://cloud.google.com/docs>
- **Learning Platform**: <https://cloud.google.com/training/>
- **Exam Guide**: <https://cloud.google.com/certification/cloud-engineer>

#### Kubernetes (CKA)

- **Certification**: Certified Kubernetes Administrator
- **Technology**: Kubernetes
- **Vendor**: Cloud Native Computing Foundation
- **Role**: Kubernetes Administrator
- **Official Docs**: <https://kubernetes.io/docs/>
- **Learning Platform**: <https://training.linuxfoundation.org/>
- **Exam Guide**: <https://www.cncf.io/certification/cka/>

### Quality Validation

Before adding generated questions to any certification:

1. **Verify all reference URLs** are valid and current
2. **Test questions** with the quiz application for proper formatting
3. **Ensure explanations** are comprehensive and educational
4. **Confirm difficulty level** matches the certification level
5. **Review for technical accuracy** and current technology features

## 📚 Contributing

We welcome contributions for new certifications and question improvements:

1. **Fork the repository** and create a feature branch
2. **Add new certification folders** following the established structure
3. **Include comprehensive question banks** with proper explanations
4. **Test thoroughly** with the quiz application
5. **Submit a pull request** with detailed documentation

### Supported Technologies

The quiz grader is designed to support any technology certification including:

- **Cloud Platforms**: Azure, AWS, Google Cloud, Oracle Cloud
- **Container Technologies**: Kubernetes, Docker, OpenShift
- **DevOps Tools**: Jenkins, GitLab, Terraform, Ansible
- **Programming Languages**: Java, Python, JavaScript, C#
- **Databases**: SQL Server, MySQL, PostgreSQL, MongoDB
- **Security**: CISSP, CEH, Security+, CISM
- **Project Management**: PMP, Scrum Master, ITIL

## 🎉 Get Started

1. **Clone the repository**
2. **Navigate to a certification folder** (e.g., AZ-104/)
3. **Open index.html** in your web browser
4. **Load a question bank file** and start practicing
5. **Track your progress** and focus on weak areas

Good luck with your certification journey! 🚀
