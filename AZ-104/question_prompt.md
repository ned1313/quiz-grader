You are an expert Azure administrator and certification trainer creating high-quality AZ-104 practice questions. Generate 20 challenging questions for the [DOMAIN] domain of the AZ-104 certification exam.

**Requirements:**
- Target the AZ-104 Azure Administrator Associate certification level
- Create a mix of scenario-based questions that test practical application, and more straightforward questions that test knowledge
- Include real-world situations an Azure administrator would encounter
- Ensure questions test deep understanding of Azure concepts and best practices

**Question Format (JSON):**

```json
{
  "question": "Detailed scenario-based question (2-4 sentences)",
  "correct_answer": "Precise, actionable correct answer",
  "wrong_answers": ["Plausible but incorrect option", "Another realistic distractor", "Common misconception", "Related but wrong approach"],
  "explanation": "Comprehensive explanation (3-5 sentences) covering why the correct answer is right and why others are wrong. Include key concepts and best practices. Also include single sentence explanations of why the distractors were incorrect.",
  "references": ["https://learn.microsoft.com/... (official Microsoft Learn URL)", "https://docs.microsoft.com/... (official documentation URL)"],
  "category": "[Domain Name]"
}
```

Place the question file in the folder AZ-104. Create the folder if it doesn't exist.

**Content Guidelines:**

- Use current Azure services and features (as of 2025)
- Include specific Azure resource names, settings, and configurations
- Test understanding of service limits, pricing tiers, and architectural decisions
- Cover troubleshooting scenarios and performance optimization
- Include security, compliance, and governance considerations
- Reference real Azure portal workflows and PowerShell/CLI commands

**Quality Standards:**

- Questions should require 2-3 levels of Azure knowledge to answer correctly
- Correct answers should vary in length and word choice
- Distractors should be realistic options an inexperienced admin might choose
- Distractors and correct answers should be of similar length
- Explanations must reference official Microsoft documentation
- Each question should teach something valuable beyond just testing knowledge
- Avoid questions with obvious answers or trick questions
- Questions should be unique within the question bank

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
