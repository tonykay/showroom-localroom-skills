# Workshop Plan: Getting Started with Skills

## Status

- [x] index.adoc -- learner landing page
- [x] assets/sample-logs/mixed-errors.log -- sample error data for exercises
- [x] 01-overview.adoc -- business scenario and learning objectives
- [x] 02-details.adoc -- technical requirements and setup
- [x] 03-module-01-what-are-skills.adoc
- [x] 04-module-02-anatomy-of-a-skill.adoc
- [x] 05-module-03-build-error-classifier.adoc
- [x] 06-module-04-build-sre-linux.adoc
- [x] 07-module-05-build-sre-kubernetes.adoc
- [x] 08-module-06-distribution-and-portability.adoc
- [x] 09-conclusion.adoc -- resources and next steps
- [x] nav.adoc -- update navigation

## Decisions Made

- **Title**: Getting Started with Skills
- **Slug**: getting-started-with-skills
- **Duration**: 90 minutes
- **Audience**: Intermediate -- already using Claude Code, haven't built skills
- **Environment**: Local only -- Claude Code + Localroom (no cloud/clusters)
- **Business scenario**: DevCorp's SRE team is drowning in mixed error logs from hybrid infrastructure (Linux VMs + Kubernetes clusters + Ansible automation). They need to triage faster. They build a skill pipeline: classify the error source, then route to specialized diagnostic skills.
- **Company**: DevCorp

## Module Breakdown

### Module 1: What are skills? (10 min) -- 03-module-01-what-are-skills.adoc

- What are agent skills -- markdown files that give Claude specialized capabilities
- Skills are an **open standard** -- not locked to Claude Code, portable to other agentic harnesses (Claude Agents SDK, LangChain, etc.)
- The "skills first" mindset -- when to reach for a skill vs MCP server vs /slash command
- Compare/contrast table: skills vs MCP servers vs /slash commands
  - Skills: declarative, portable, no server process, markdown-based
  - MCP servers: runtime services, bidirectional, heavier infrastructure
  - /slash commands: repo-scoped shortcuts, simpler but less portable
- Exercise: explore existing skills (`ls ~/.claude/commands/`, look at example-skills)
- DevCorp story intro: "Your SRE team gets paged at 3am with a wall of mixed errors..."

### Module 2: Anatomy of a skill (10 min) -- 04-module-02-anatomy-of-a-skill.adoc

- Skill file structure: frontmatter (name, description, triggers) + body (instructions)
- Simple skill: just a markdown file with instructions
- Intermediate skill: frontmatter with trigger conditions, arguments, model hints
- Complex skill: multi-step workflow, references to other files, agent orchestration
- Exercise: read and dissect an existing skill file (`tree` output, annotate sections)
- Show the progression: simple -> intermediate -> complex with real examples
- DevCorp story: "Before building, let's understand the blueprint..."

### Module 3: Build error-classifier (20 min) -- 05-module-03-build-error-classifier.adoc

- First hands-on skill build
- Create `error-classifier` skill that reads a log file and classifies each error as Linux, Ansible, or Kubernetes
- Walk through writing the skill markdown file step by step
- Use the sample `mixed-errors.log` from `assets/sample-logs/`
- Test it with Claude Code: invoke the skill, verify classification output
- Verification: run against known log, check accuracy
- DevCorp story: "First step in the triage pipeline -- know what you're dealing with"

### Module 4: Build sre-linux (20 min) -- 06-module-04-build-sre-linux.adoc

- Intermediate skill -- deeper diagnosis of Linux-specific errors
- Handles: user/permission errors, dnf/package management, SELinux denials, systemd failures
- Builds on error-classifier output -- receives pre-classified Linux errors
- Introduce skill arguments and more sophisticated prompt engineering
- Exercise: create the skill, test against Linux errors from the sample log
- Capture tribal knowledge: "What would your senior SRE check first for an SELinux denial?"
- DevCorp story: "Now the Linux specialist on the team shares their expertise..."

### Module 5: Build sre-kubernetes (15 min) -- 07-module-05-build-sre-kubernetes.adoc

- Builds on the established pattern from sre-linux
- Handles: pod failures (CrashLoopBackOff, ImagePull), node issues, YAML validation errors
- Learners should be faster now -- pattern is established
- Exercise: create the skill, test against Kubernetes errors from the sample log
- DevCorp story: "The Kubernetes team contributes their diagnostic playbook..."

### Module 6: Distribution and portability (15 min) -- 08-module-06-distribution-and-portability.adoc

- **Scope**: where skills live
  - `~/.claude/commands/` -- personal skills
  - `.claude/commands/` -- repo-scoped skills
  - Project-level vs global scope
- **Shadow skills**: when Tony and Burr both have a `foo` skill -- who wins?
- **Marketplaces**: the emerging ecosystem for sharing skills (agenticskills.dev)
- **In-repo skills**: when to embed vs when to distribute
  - Yes: if upstream repo is single point of truth
  - No: if a template -- skills will atrophy
- **Portability as an open standard**: skills work beyond Claude Code
  - Claude Agents SDK
  - LangChain Deep Agents
  - Other agentic frameworks adopting the standard
- Exercise: move the error-classifier skill between scopes, share with a teammate's repo
- DevCorp story: "Time to share the triage pipeline across all SRE teams..."

### Module 7: Resources and next steps -- 09-conclusion.adoc

- Consolidated references from all modules
- Key resources:
  - link:https://resources.anthropic.com/hubfs/The-Complete-Guide-to-Building-Skill-for-Claude.pdf?hsLang=en%20(2)[Complete Guide to Building Skills for Claude^]
  - link:https://agenticskills.dev/[Agentic Skills^]
  - Anthropic Agent Skills home page
- Learning outcomes checkpoint (recap what was built)
- Next steps: build more skills, contribute to marketplaces, explore complex multi-skill workflows
- DevCorp story conclusion: "From 3am panic to automated triage -- the SRE team sleeps better"

## Sample Error Log

Already created at `assets/sample-logs/mixed-errors.log`. Contains 15 mixed errors:
- 4 Linux errors (dnf, selinux, systemd, user auth)
- 4 Kubernetes errors (pod sync, crashloop, node not found, YAML validation)
- 3 Ansible errors (package not found, unreachable host, sudo password)
- Mixed timestamps, realistic format

## Template Patterns to Follow

- Use second-person narrative ("You")
- Business scenario woven through each module (DevCorp SRE team)
- Progressive exercises with verification checkpoints
- Code blocks use `[source,role="execute"]` for copyable commands
- Images use `link=self,window=blank` format
- External links use `^` caret for new tab
- Module summary at end with "What you accomplished" + "Business impact" + "Next steps"
- All files in `content/modules/ROOT/pages/`

## Navigation (nav.adoc)

```asciidoc
* xref:index.adoc[Getting Started with Skills]
** xref:01-overview.adoc[Workshop overview]
** xref:02-details.adoc[Workshop details]
** xref:03-module-01-what-are-skills.adoc[Module 1: What are skills?]
** xref:04-module-02-anatomy-of-a-skill.adoc[Module 2: Anatomy of a skill]
** xref:05-module-03-build-error-classifier.adoc[Module 3: Build error-classifier]
** xref:06-module-04-build-sre-linux.adoc[Module 4: Build sre-linux]
** xref:07-module-05-build-sre-kubernetes.adoc[Module 5: Build sre-kubernetes]
** xref:08-module-06-distribution-and-portability.adoc[Module 6: Distribution and portability]
** xref:09-conclusion.adoc[Resources and next steps]
```

## Resume Instructions

To continue generating modules, run:
```
Continue generating the workshop modules from WORKSHOP-PLAN.md -- pick up where we left off. All decisions are captured in the plan. Use the templates in examples/workshop/ as structural reference. Generate each remaining file using the Write tool.
```
