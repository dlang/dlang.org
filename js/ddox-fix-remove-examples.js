/**
 * This script fixes the display of problematic examples in the DDOX-generated 
 * documentation for std.algorithm.mutation.remove
 */
$(document).ready(function() {
    // Only run on the remove page
    if (window.location.pathname.indexOf('std/algorithm/mutation/remove') === -1) {
        return;
    }

    // Find all code examples
    $('section h3:contains("Example") + p + pre.code').each(function() {
        const codeBlock = $(this);
        const codeText = codeBlock.text();
        
        // Check if this is one of the problematic examples
        if (codeText.includes('writeln([') && !codeText.includes('import std.stdio')) {
            // Create a warning notice
            const warningMsg = $('<div class="example-warning">')
                .html('<strong>Note:</strong> The examples below require additional imports to run. ' +
                      'At minimum, add <code>import std.stdio;</code> for <code>writeln</code>. ' +
                      'Additionally, remember that <code>remove</code> returns a new array but does not ' +
                      'change the length of the original array unless you reassign the result.');
            
            // Insert the warning before the code block
            codeBlock.before(warningMsg);
            
            // Fix the code display in the block for clarity
            const fixedCode = codeText.replace(/writeln\(\[/g, function(match) {
                // Explain the need for reassignment
                return 'int[] a = [4, 5, 6]; // Defined for example purposes\n' +
                       '// To modify the original array, you need to reassign: a = a.remove(...);\n' +
                       'writeln([';
            });
            
            // Update the displayed code
            codeBlock.find('code').html(fixedCode);
        }
    });
}); 