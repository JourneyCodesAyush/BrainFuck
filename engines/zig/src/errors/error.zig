//! Defines the shared error set used across the interpreter and virtual machine.

/// Errors that can occur during parsing, execution, and I/O operations.
pub const Errors = error{ UnbalancedOpeningBracket, UnbalancedClosingBracket, OutOfMemory, IOError, ParseError, WriteFailedError };
