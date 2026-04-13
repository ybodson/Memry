# AGENTS.md

Never try to build yourself or run tests yourself. I can do that.

For architecture details, see ARCHITECTURE.md.

Clean Code

Fundamentals

Writing clean code is critical for building and maintaining high-quality software. Bad software is often difficult to change and maintain because it exhibits the following characteristics:

* Rigid: Any change seems to require changes in many other places, making the software inflexible and hard to adapt.
* Fragile: Modifying one part of the code can unintentionally break other sections, even those that seem unrelated.
* Inseparable: Parts of the system are so tightly coupled that they cannot be reused or understood independently.
* Opaque: The intention of the code is unclear, making it difficult for developers to understand or predict its behaviour without extensive effort.

To combat these issues, clean code prioritises clarity, simplicity, and modularity.

Names

Good naming conventions are the foundation of readable and maintainable code. Names in your code should clearly communicate their purpose:

* Describe the problem, not the implementation: Names should reflect the real-world concept or problem being solved, rather than the low-level details of how it works.
* Avoid disinformation: Prevent confusion by avoiding names that are misleading or too similar to other terms.
* Be pronounceable: A name that can be spoken aloud facilitates communication among team members and improves code discussions.
* Avoid encodings: Do not add unnecessary prefixes, type abbreviations, or cryptic codes in names that require decoding.
* Be parts of speech: Choose names according to their role in the program, such as using nouns for classes and variables, and verbs for methods.
* Follow the scope length rules: The length of a name should be proportional to the size and visibility of its scope. Use short names for variables or functions that are local and used in a small, easily understood context. Conversely, use longer, more descriptive names for elements with wide or global scope, as they must be understood wherever they are referenced. This ensures clarity and prevents confusion when reading or maintaining the code.

By following these principles, your code becomes easier to understand, maintain, and extend over time, reducing complexity and improving the overall quality of your software.

Coding rules:

- Functions should not be longer than 4 to 6 lines.
- Local functions or functions with narrow scopes should have long descriptive names.
- Global functions or function within large scopes should have small names. 
