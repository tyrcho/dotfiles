---
allowed-tools: Bash, Read, Write, Edit, Glob, Grep
---

> Source: [deslop.md](https://github.com/Theta-Tech-AI/llm-public-utils/blob/production/slash_commands/deslop.md)

## The Code Review Command

You are a code quality analyzer. Your task is to identify "slop" - code that violates established coding principles - and suggest concrete improvements.

At the end, figure out what you should actually change in the code and ask the user if you should make the changes. Then make the changes if the user affirms.

### Target

Analyze: $ARGUMENTS

If no argument provided, operate on the current folder or current code base.

### Process

1. **Read all coding principles** from this document to understand what good code looks like.
2. **Detect language(s) in the target.** Inspect file extensions (`.py`, `.ts`/`.tsx`/`.mts`/`.cts`, `.go`) and config files (`pyproject.toml`, `requirements.txt`, `setup.py`, `tsconfig.json`, `package.json`, `go.mod`). A project may use more than one — include every detected language.
3. **Read the language-specific principles.** For each detected language, `Read` every `.md` file under `~/.claude/commands/code-review/Languages/<Language>/`. Apply them **in addition to** the general principles, not as a replacement. Skip languages that are not present in the target — don't waste context loading them.
4. **Read the target file(s)** using the Read tool.
5. **Reread relevant coding principles** (general and language-specific) based on what violations you observe.
6. **Identify violations** organized by principle. Tag each violation as general or language-specific so the user knows which is which.
7. **Suggest concrete fixes** with before/after examples in the target language.

### Output Format

#### Summary

Brief overview of code health (1-2 sentences).

#### Violations Found

For each violation:

    ##### [Principle Name] - [Specific Issue]

    **Location**: `file.py:line_number`

    **Problem**: [Description of what's wrong]

    **Before**:
    ```python
    # problematic code
    ```

    **After**:
    ```python
    # improved code
    ```

    **Why**: [Brief explanation referencing the principle]

#### Recommendations

Prioritized list of changes, most impactful first.

Then, ask the user if they'd like to implement some or all of the changes.

If they affirm, then implement them next. When implementing them, consider if some of the changes could be implemented in parallel with async agents for efficiency.

### Important Notes

- **Don't over-engineer**: Suggesting abstractions for single-use code violates YAGNI/KISS
- **Context matters**: Test code has different standards (DAMP over DRY)
- **Rule of Three**: Don't suggest abstracting until pattern proven with 3+ occurrences
- **Incidental similarity is not duplication**: Don't merge code that happens to look similar but represents different concepts
- **Be specific**: Reference exact line numbers and provide concrete before/after code

### Priority Matrix

*Prioritize fixes by impact and effort.*

| Priority | Type | Examples | Fix When |
|----------|------|----------|----------|
| **P0: Critical** | Security, data loss | SQL injection, unvalidated input, race conditions | Immediately |
| **P1: High** | Bugs waiting to happen | Missing error handling, silent failures, unclear ownership | This PR |
| **P2: Medium** | Maintainability | DRY violations (3+), god classes, deep nesting | When touching file |
| **P3: Low** | Polish | Magic numbers, naming, minor duplication | If time permits |
| **P4: Optional** | Style | Formatting, comment cleanup, minor refactors | Boy Scout Rule |

**Effort modifiers:**
- **Quick win** (< 5 min): Bump up one priority level
- **Risky change** (no tests): Bump down one level, suggest adding tests first
- **Requires coordination**: Note in recommendations, may need team discussion

---

## Coding Principles Reference

### Quick Diagnostic Guide

*See a symptom? Jump to the relevant principle.*

| Symptom | Likely Principle | Quick Fix |
|---------|------------------|-----------|
| Function > 50 lines | Small Functions | Extract named helpers |
| Deep nesting (3+ levels) | Guard Clauses, Cognitive Load | Early returns |
| Copy-pasted code (3+ times) | DRY | Extract shared function |
| Magic numbers/strings | Self-Documenting Code | Named constants |
| Class doing many things | SOLID (SRP), Separation of Concerns | Split by responsibility |
| Long parameter lists (5+) | Encapsulation | Parameter object |
| `a.b().c().d()` chains | Law of Demeter | Delegate to intermediate |
| Speculative features | YAGNI | Delete until needed |
| Comments explaining "what" | Self-Documenting Code | Rename to be obvious |
| Stale/wrong comments | Documentation Discipline | Delete or fix |
| Same data in multiple tables | Single Source of Truth | Designate authoritative source |
| Tests require complex setup | Dependency Injection | Inject dependencies |
| Inheritance hierarchy > 2 deep | Composition Over Inheritance | Compose objects |
| Boolean parameters | Small Functions, KISS | Separate functions |
| Inconsistent error handling | Fail-Fast | Validate at entry |
| Silent failures | Fail-Fast, Observability | Fail loudly, log |
| Getters exposing internals | Encapsulation | Tell, don't ask |
| Enumerable list in arbitrary order | Alphabetical Ordering | Sort it; let tooling enforce |
| Duplicates hidden in a long list | Alphabetical Ordering | Sort — duplicates become visually adjacent |

### Language-Specific Diagnostics

*Surface for the language(s) detected in step 2. Full guidance lives in the per-language files under `Languages/`.*

| Language | Symptom | Likely File |
|----------|---------|-------------|
| Python | `except:` or `except Exception:` swallowing all errors | `Python/Error Handling and Resources` |
| Python | `for i in range(len(xs))` / `if len(xs) > 0` | `Python/Pythonic Idioms` |
| Python | `def f(items=[])` mutable default | `Python/Data Structures` |
| Python | `List[int]` / `Optional[X]` on Python 3.10+ | `Python/Type Hints` |
| TypeScript | `: any` or `as any` outside narrow shims | `TypeScript/Type System Discipline` |
| TypeScript | Promise chain that could be `await` | `TypeScript/Modern Syntax and Async` |
| TypeScript | `\|\|` used for defaults (loses `0`, `""`, `false`) | `TypeScript/Modern Syntax and Async` |
| TypeScript | `IUser` / `IRepository` interface naming | `TypeScript/Naming and Style` |
| Go | `fmt.Errorf("...: %v", err)` losing the chain | `Go/Error Handling` |
| Go | `panic` in library / handler code | `Go/Error Handling` |
| Go | >3 params, especially same-typed booleans | `Go/Interfaces and APIs` |
| Go | Returning an interface from a constructor | `Go/Interfaces and APIs` |
| Go | `mu.Lock()` without immediate `defer mu.Unlock()` | `Go/Concurrency` |
| Go | Test without `t.Parallel()` or as `testify.Suite` | `Go/Testing` |

### Principle Tensions

*Principles sometimes conflict. Here's how to resolve common tensions.*

| Tension | Resolution |
|---------|------------|
| **DRY vs. Coupling** | Duplication is cheaper than wrong abstraction. Wait for Rule of Three. If abstracting requires parameters/conditionals to handle differences, keep separate. |
| **YAGNI vs. Extensibility** | Build for today, but keep code malleable. Don't add extension points; ensure code is easy to modify when needed. |
| **KISS vs. DRY** | Three lines of obvious code beats one line of clever abstraction. Optimize for reader comprehension. |
| **Fail-Fast vs. Resilience** | Fail fast for bugs (programmer errors). Retry/degrade for operational failures (network, disk). |
| **Encapsulation vs. Testing** | Prefer testing through public interface. If you need to test internals, the design may need work. |
| **Postel's Law vs. Fail-Fast** | Be liberal on input *format* (accept trailing whitespace), but strict on *required data* (reject missing fields). |
| **Small Functions vs. Cognitive Load** | Too many tiny functions forces readers to jump around. Balance: functions should do one thing, but that "thing" can be substantial. |
| **DRY vs. Decoupling** | Shared code creates coupling. If two teams/services share code, changes affect both. Sometimes copy-paste is correct for independence. |
| **Convention vs. Explicitness** | Conventions reduce boilerplate but hide behavior. Document conventions; allow overrides. |

### Anti-Pattern Quick Reference

*Fast detection of common code smells.*

| Anti-Pattern | Symptoms | Violates |
|--------------|----------|----------|
| **God Class** | 500+ lines, "Manager"/"Handler" suffix, does everything | SRP, Modularity |
| **Feature Envy** | Method uses another class's data more than its own | Encapsulation |
| **Shotgun Surgery** | One change requires edits in 10+ files | Separation of Concerns |
| **Primitive Obsession** | Passing `(str, str, int)` instead of `User` object | Encapsulation |
| **Data Clumps** | Same 3-4 params always passed together | Encapsulation |
| **Long Method** | Function > 50 lines, multiple levels of abstraction | Small Functions |
| **Speculative Generality** | Unused interfaces, "for future use" code | YAGNI |
| **Dead Code** | Unreachable code, unused functions | YAGNI, Boy Scout |
| **Magic Numbers** | `if x > 86400` instead of `SECONDS_PER_DAY` | Self-Documenting |
| **Inappropriate Intimacy** | Class accesses another's private details | Encapsulation, LoD |
| **Message Chains** | `a.getB().getC().getD()` | Law of Demeter |
| **Middle Man** | Class delegates everything, adds no value | KISS |
| **Refused Bequest** | Subclass doesn't use inherited methods | Liskov, Composition |
| **Comments as Deodorant** | Comments explaining bad code instead of fixing it | Self-Documenting |
| **Cargo Cult** | Patterns used without understanding why | KISS, YAGNI |

---

### Part I: Clean Code

#### Simplicity & Minimalism

- [KISS](./code-review/Clean%20Code/Simplicity%20and%20Minimalism/KISS.md)
- [YAGNI](./code-review/Clean%20Code/Simplicity%20and%20Minimalism/YAGNI.md)
- [Small Functions](./code-review/Clean%20Code/Simplicity%20and%20Minimalism/Small%20Functions.md)
- [Guard Clauses](./code-review/Clean%20Code/Simplicity%20and%20Minimalism/Guard%20Clauses.md)

@~/.claude/commands/code-review/Clean Code/Simplicity and Minimalism/KISS.md
@~/.claude/commands/code-review/Clean Code/Simplicity and Minimalism/YAGNI.md
@~/.claude/commands/code-review/Clean Code/Simplicity and Minimalism/Small Functions.md
@~/.claude/commands/code-review/Clean Code/Simplicity and Minimalism/Guard Clauses.md

#### Clarity & Readability

- [Cognitive Load](./code-review/Clean%20Code/Clarity%20and%20Readability/Cognitive%20Load.md)
- [Single Level of Abstraction (SLAP)](./code-review/Clean%20Code/Clarity%20and%20Readability/SLAP.md)
- [Self-Documenting Code](./code-review/Clean%20Code/Clarity%20and%20Readability/Self-Documenting%20Code.md)
- [Documentation Discipline](./code-review/Clean%20Code/Clarity%20and%20Readability/Documentation%20Discipline.md)
- [Elegance](./code-review/Clean%20Code/Clarity%20and%20Readability/Elegance.md)
- [Least Surprise](./code-review/Clean%20Code/Clarity%20and%20Readability/Least%20Surprise.md)

@~/.claude/commands/code-review/Clean Code/Clarity and Readability/Cognitive Load.md
@~/.claude/commands/code-review/Clean Code/Clarity and Readability/SLAP.md
@~/.claude/commands/code-review/Clean Code/Clarity and Readability/Self-Documenting Code.md
@~/.claude/commands/code-review/Clean Code/Clarity and Readability/Documentation Discipline.md
@~/.claude/commands/code-review/Clean Code/Clarity and Readability/Elegance.md
@~/.claude/commands/code-review/Clean Code/Clarity and Readability/Least Surprise.md

### Part II: Architecture

#### Organization & Structure

- [DRY](./code-review/Architecture/Organization%20and%20Structure/DRY.md)
- [Single Source of Truth](./code-review/Architecture/Organization%20and%20Structure/Single%20Source%20of%20Truth.md)
- [Separation of Concerns](./code-review/Architecture/Organization%20and%20Structure/Separation%20of%20Concerns.md)
- [Modularity](./code-review/Architecture/Organization%20and%20Structure/Modularity.md)

@~/.claude/commands/code-review/Architecture/Organization and Structure/DRY.md
@~/.claude/commands/code-review/Architecture/Organization and Structure/Single Source of Truth.md
@~/.claude/commands/code-review/Architecture/Organization and Structure/Separation of Concerns.md
@~/.claude/commands/code-review/Architecture/Organization and Structure/Modularity.md

#### Coupling & Dependencies

- [Encapsulation](./code-review/Architecture/Coupling%20and%20Dependencies/Encapsulation.md)
- [Law of Demeter](./code-review/Architecture/Coupling%20and%20Dependencies/Law%20of%20Demeter.md)
- [Orthogonality](./code-review/Architecture/Coupling%20and%20Dependencies/Orthogonality.md)
- [Dependency Injection](./code-review/Architecture/Coupling%20and%20Dependencies/Dependency%20Injection.md)
- [Composition Over Inheritance](./code-review/Architecture/Coupling%20and%20Dependencies/Composition%20Over%20Inheritance.md)

@~/.claude/commands/code-review/Architecture/Coupling and Dependencies/Encapsulation.md
@~/.claude/commands/code-review/Architecture/Coupling and Dependencies/Law of Demeter.md
@~/.claude/commands/code-review/Architecture/Coupling and Dependencies/Orthogonality.md
@~/.claude/commands/code-review/Architecture/Coupling and Dependencies/Dependency Injection.md
@~/.claude/commands/code-review/Architecture/Coupling and Dependencies/Composition Over Inheritance.md

#### Design Patterns & Conventions

- [SOLID](./code-review/Architecture/Design%20Patterns%20and%20Conventions/SOLID.md)
- [Convention Over Configuration](./code-review/Architecture/Design%20Patterns%20and%20Conventions/Convention%20Over%20Configuration.md)
- [Command-Query Separation](./code-review/Architecture/Design%20Patterns%20and%20Conventions/Command-Query%20Separation.md)
- [Code Reusability](./code-review/Architecture/Design%20Patterns%20and%20Conventions/Code%20Reusability.md)

@~/.claude/commands/code-review/Architecture/Design Patterns and Conventions/SOLID.md
@~/.claude/commands/code-review/Architecture/Design Patterns and Conventions/Convention Over Configuration.md
@~/.claude/commands/code-review/Architecture/Design Patterns and Conventions/Command-Query Separation.md
@~/.claude/commands/code-review/Architecture/Design Patterns and Conventions/Code Reusability.md

#### Data & State

- [Parse, Don't Validate](./code-review/Architecture/Data%20and%20State/Parse%20Dont%20Validate.md)
- [Immutability](./code-review/Architecture/Data%20and%20State/Immutability.md)
- [Idempotency](./code-review/Architecture/Data%20and%20State/Idempotency.md)

@~/.claude/commands/code-review/Architecture/Data and State/Parse Dont Validate.md
@~/.claude/commands/code-review/Architecture/Data and State/Immutability.md
@~/.claude/commands/code-review/Architecture/Data and State/Idempotency.md

### Part III: Reliability

#### Robustness & Safety

- [Fail-Fast](./code-review/Reliability/Robustness%20and%20Safety/Fail-Fast.md)
- [Design by Contract](./code-review/Reliability/Robustness%20and%20Safety/Design%20by%20Contract.md)
- [Postel's Law](./code-review/Reliability/Robustness%20and%20Safety/Postels%20Law.md)
- [Resilience](./code-review/Reliability/Robustness%20and%20Safety/Resilience.md)
- [Least Privilege](./code-review/Reliability/Robustness%20and%20Safety/Least%20Privilege.md)

@~/.claude/commands/code-review/Reliability/Robustness and Safety/Fail-Fast.md
@~/.claude/commands/code-review/Reliability/Robustness and Safety/Design by Contract.md
@~/.claude/commands/code-review/Reliability/Robustness and Safety/Postels Law.md
@~/.claude/commands/code-review/Reliability/Robustness and Safety/Resilience.md
@~/.claude/commands/code-review/Reliability/Robustness and Safety/Least Privilege.md

#### Maintainability & Operations

- [Boy Scout Rule](./code-review/Reliability/Maintainability%20and%20Operations/Boy%20Scout%20Rule.md)
- [Observability](./code-review/Reliability/Maintainability%20and%20Operations/Observability.md)
- [Alphabetical Ordering](./code-review/Reliability/Maintainability%20and%20Operations/Alphabetical%20Ordering.md)

@~/.claude/commands/code-review/Reliability/Maintainability and Operations/Boy Scout Rule.md
@~/.claude/commands/code-review/Reliability/Maintainability and Operations/Observability.md
@~/.claude/commands/code-review/Reliability/Maintainability and Operations/Alphabetical Ordering.md

### Part IV: Language-Specific Practices

*Loaded on demand by `/code-review` after the language-detection step. Not inlined with `@` — `Read` only the subfolders that match languages detected in the target.*

#### Python

- [Pythonic Idioms](./code-review/Languages/Python/Pythonic%20Idioms.md)
- [Style and Naming](./code-review/Languages/Python/Style%20and%20Naming.md)
- [Type Hints](./code-review/Languages/Python/Type%20Hints.md)
- [Error Handling and Resources](./code-review/Languages/Python/Error%20Handling%20and%20Resources.md)
- [Data Structures](./code-review/Languages/Python/Data%20Structures.md)

#### TypeScript

- [Strict Mode and Compiler Flags](./code-review/Languages/TypeScript/Strict%20Mode%20and%20Compiler%20Flags.md)
- [Type System Discipline](./code-review/Languages/TypeScript/Type%20System%20Discipline.md)
- [Modern Syntax and Async](./code-review/Languages/TypeScript/Modern%20Syntax%20and%20Async.md)
- [Type Definitions](./code-review/Languages/TypeScript/Type%20Definitions.md)
- [Naming and Style](./code-review/Languages/TypeScript/Naming%20and%20Style.md)

#### Go

- [Code Style and Formatting](./code-review/Languages/Go/Code%20Style%20and%20Formatting.md)
- [Error Handling](./code-review/Languages/Go/Error%20Handling.md)
- [Interfaces and APIs](./code-review/Languages/Go/Interfaces%20and%20APIs.md)
- [Concurrency](./code-review/Languages/Go/Concurrency.md)
- [Testing](./code-review/Languages/Go/Testing.md)

---

## When to Relax Rules

*Over-applying principles causes as much harm as ignoring them. Know when to make exceptions.*

| Context | Relaxed Principles | Why |
|---------|-------------------|-----|
| **Prototypes/Spikes** | All | Exploring, not building. Throw it away. |
| **Test Code** | DRY | DAMP (Descriptive And Meaningful Phrases) > DRY. Readability trumps deduplication. |
| **Performance-Critical** | Abstractions, DI | Hot paths may need inlining. Profile first. |
| **Scripts < 100 lines** | Modularity, SRP | Overhead exceeds benefit. Keep it simple. |
| **Glue Code** | Most patterns | Thin integration layers don't need architecture. |
| **Generated Code** | All | Don't hand-edit generated code. Fix the generator. |
| **Legacy Migration** | Boy Scout | Large refactors need dedicated effort, not incremental changes. |
| **Data Transfer Objects** | Encapsulation | DTOs are meant to expose data. That's their job. |
| **Configuration** | YAGNI | Config flexibility is often worth it—cheaper than redeployment. |
| **Security Boundaries** | Postel's Law | Be paranoid, not liberal. Validate everything strictly. |

### The Meta-Principle

> **"Rules are for the guidance of wise men and the obedience of fools."** — Douglas Bader

Principles are heuristics, not laws. Understand WHY before applying. If following makes code worse, don't.

---

## References

### Foundational Texts

Essential books that shaped modern software design thinking.

| Book | Author(s) | Key Contribution |
|------|-----------|------------------|
| *The Pragmatic Programmer* | Andy Hunt & Dave Thomas | Practical heuristics including DRY, orthogonality, tracer bullets, and "Tell Don't Ask" |
| *Clean Code* | Robert C. Martin | Function size, naming, and the Single Responsibility Principle |
| *A Philosophy of Software Design* | John Ousterhout | Deep vs. shallow modules, complexity as the root problem, strategic vs. tactical programming |
| *Design Patterns* | Gang of Four (Gamma, Helm, Johnson, Vlissides) | 23 reusable OO patterns; established patterns vocabulary |
| *Object-Oriented Software Construction* | Bertrand Meyer | Design by Contract, Command-Query Separation, Open-Closed Principle |
| *Refactoring* | Martin Fowler | Systematic code improvement techniques; code smells catalog |
| *Working Effectively with Legacy Code* | Michael Feathers | Seams, characterization tests, safely changing untested code |
| *Domain-Driven Design* | Eric Evans | Ubiquitous language, bounded contexts, strategic design |

### Seminal Articles & Essays

Influential writings that introduced or crystallized important concepts.

| Article | Author | Year | Key Idea |
|---------|--------|------|----------|
| [Parse, Don't Validate](https://lexi-lambda.github.io/blog/2019/11/05/parse-don-t-validate/) | Alexis King | 2019 | Transform unstructured data into types that prove validity; let the type system enforce invariants |
| [The Wrong Abstraction](https://sandimetz.com/blog/2016/1/20/the-wrong-abstraction) | Sandi Metz | 2016 | "Duplication is far cheaper than the wrong abstraction"; prefer inline code over premature DRY |
| [Cognitive Load is What Matters](https://github.com/zakirullin/cognitive-load) | Artem Zakirullin | 2023 | Minimize mental effort required to understand code; endorsed by Rob Pike, Andrej Karpathy |
| [Tell Don't Ask](https://martinfowler.com/bliki/TellDontAsk.html) | Martin Fowler | 2013 | Tell objects what to do rather than asking for data and acting on it |
| [Four Rules of Simple Design](https://martinfowler.com/bliki/BeckDesignRules.html) | Kent Beck | ~1990s | (1) Passes tests, (2) Reveals intention, (3) No duplication, (4) Fewest elements |
| [Law of Demeter](https://www2.ccs.neu.edu/research/demeter/papers/law-of-demeter/oopsla88-law-of-demeter.pdf) | Karl Lieberherr et al. | 1987 | Only talk to your immediate friends; minimize coupling chains |

### Online Resources

Living references for patterns, principles, and refactoring techniques.

- [Martin Fowler's Bliki](https://martinfowler.com/bliki/) — Authoritative essays on patterns, refactoring, and architecture
- [Refactoring Guru](https://refactoring.guru/) — Visual catalog of design patterns and refactoring techniques
- [DevIQ Principles](https://deviq.com/principles/) — Concise summaries of software development principles
- [c2 Wiki (Cunningham & Cunningham)](http://wiki.c2.com/) — The original patterns wiki; historical discussions on OO design
- [Source Making](https://sourcemaking.com/) — Design patterns, anti-patterns, and refactoring catalog

### Concept Attribution

Origins of specific principles referenced in this document.

| Concept | Origin |
|---------|--------|
| **KISS** | U.S. Navy, 1960s; popularized by Kelly Johnson (Lockheed Skunk Works) |
| **YAGNI** | Extreme Programming (Kent Beck, Ron Jeffries), late 1990s |
| **DRY** | *The Pragmatic Programmer* (Hunt & Thomas), 1999 |
| **SOLID** | Robert C. Martin, early 2000s (acronym coined by Michael Feathers) |
| **Separation of Concerns** | Edsger Dijkstra, 1974 |
| **Design by Contract** | Bertrand Meyer, 1986 (Eiffel language) |
| **Postel's Law** | Jon Postel, RFC 761 (TCP), 1980 |
| **Deep Modules** | John Ousterhout, *A Philosophy of Software Design*, 2018 |
| **Rule of Three** | Folk wisdom; formalized in *Refactoring* (Fowler) |
| **Cognitive Load** | Psychology (John Sweller, 1988); applied to code by Zakirullin, 2023 |
