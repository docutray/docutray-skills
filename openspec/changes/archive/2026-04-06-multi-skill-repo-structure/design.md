## Context

The repo currently has only a `README.md` and `openspec/` directory. Issue #1 requires creating the multi-skill directory structure following the Agent Skills spec (agentskills.io). Each skill is a `SKILL.md` file with YAML frontmatter + Markdown body, published via `npx skills add docutray/docutray-skills`.

## Goals / Non-Goals

**Goals:**
- Establish the `skills/` directory with three skill subdirectories
- Create valid skeleton SKILL.md files with proper frontmatter
- Provide `references/` directories for future content expansion
- Update README.md with the complete skill table

**Non-Goals:**
- Writing actual skill content (separate issues per skill)
- Adding CLI examples, reference docs, or usage guides
- Implementing any tooling or automation

## Decisions

### 1. Three-skill split by use case

Split into `docutray-setup`, `docutray-platform`, and `docutray-advanced` rather than a single monolithic skill.

**Rationale**: Agents only load what's relevant. A setup skill is needed once; platform usage is the daily driver; advanced features are rare. Progressive disclosure keeps agent context lean.

**Alternative considered**: Single skill with sections — rejected because it forces agents to load all content regardless of task.

### 2. Skeleton-only SKILL.md files

Each SKILL.md gets valid frontmatter (`name`, `description`) and a minimal body with section headers. No actual content yet.

**Rationale**: Separates structure (this issue) from content (future issues). Validates that the directory layout and frontmatter are correct before investing in content.

### 3. References directories for all skills

Every skill gets a `references/` subdirectory even though they start empty.

**Rationale**: The Agent Skills spec recommends `references/` for detailed docs that exceed the 500-line SKILL.md limit. Creating them now avoids restructuring later.

### 4. Frontmatter description includes trigger phrases

Each `description` field includes phrases that help agents decide when to activate the skill (e.g., "install docutray", "convert document", "create document type").

**Rationale**: The Agent Skills spec uses `description` for agent activation matching. Including trigger phrases from the start ensures skills are discoverable.

## Risks / Trade-offs

- [Skill boundaries may shift] → Mitigated by keeping skeletons minimal; restructuring is cheap before content exists.
- [Empty references/ dirs may confuse contributors] → Mitigated by placeholder README or `.gitkeep` if needed; Git tracks empty dirs via convention.
