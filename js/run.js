/**
Runnable examples functionality

Copyright: Damian Ziemba 2012

License:   http://boost.org/LICENSE_1_0.txt, Boost License 1.0

Authors:   Andrei Alexandrescu, Damian Ziemba
*/
String.prototype.nl2br = function()
{      
    return this.replace(/\n/g, "<br />");     
}

function showHideAnswer(zis)
{
    var id = $(zis).attr('id').replace(/[^\d]/g,'');
    var obj= $("#a"+id);

    if (obj.css('display') == 'none')
    {
        $(zis).html('<span class="nobr">Hide example.</span>');
        obj.css('display', 'block');
    }
    else
    {
        $(zis).html('<span class="nobr">See example.</span>');
        obj.css('display', 'none');
    }
}

function parseOutput(data, o, oTitle)
{
    var xml = $(data);
    if (xml == null || xml.find("response") == null)
    {
        o.text("Temporarily unavaible");
        return;
    }

    var output = "";
    var cout = xml.find("response").find("compilation").find("stdout").text();
    var stdout = xml.find("response").find("runtime").find("stdout").text();
    var stderr = xml.find("response").find("runtime").find("stderr").text();
    var ctime = parseInt(xml.find("response").find("compilation").find("time").text());
    var rtime = parseInt(xml.find("response").find("runtime").find("time").text());
    var cstatus = parseInt(xml.find("response").find("compilation").find("status").text());
    var rstatus = parseInt(xml.find("response").find("runtime").find("status").text());
    var cerr = xml.find("response").find("compilation").find("err").text();
    var rerr = xml.find("response").find("runtime").find("err").text();

    if (cstatus != 0)
    {
        oTitle.text("Compilation output ("+cstatus+": "+cerr+")");
        if ($.browser.msie)
            o.html(cout.nl2br());
        else
            o.text(cout);
        
        return;
    }
    else
    {
        oTitle.text("Application output");// (compile "+ctime+"ms, run "+rtime+"ms)");
        if ( cout != "")
            output = 'Compilation output: \n' + cout + "\n";
        
        output += (stdout == "" && stderr == "" ? '-- No output --' : stdout);

        if (stderr != "") 
            output += stderr;

        if (rstatus != 0)
            oTitle.text("Application output ("+rstatus+": "+rerr+")");
    }

    if ($.browser.msie)
        o.html(output.nl2br());
    else
        o.text(output);
}

$(document).ready(function() 
{
    $('textarea[class=d_code]').each(function(index) {
        var thisObj = $(this);

        var parent = thisObj.parent();
        parent.css("display", "block");
        
        var editor = CodeMirror.fromTextArea(thisObj[0], {
            lineNumbers: false,
            tabSize: 4,
            indentUnit: 4,
            indentWithTabs: true,
            mode: "text/x-d",
            lineWrapping: true,
            theme: "eclipse",
            readOnly: false,
            matchBrackets: true
        });
        var height = function(diff) {
            return (parseInt(code.css('height')) - diff) + 'px';
        };
        if ($.browser.webkit)
            editor.setValue(parent.children("div.d_code_src").text());

        var runBtn = parent.children("input.runButton");
        var editBtn = parent.children("input.editButton");
        var inputBtn = parent.children("input.inputButton");
        var resetBtn = parent.children("input.resetButton");
        var argsBtn = parent.children("input.argsButton");
        var stdinDiv = parent.children("div.d_code_stdin");
        var argsDiv = parent.children("div.d_code_args");
        var outputDiv = parent.children("div.d_code_output");

        var code = $(editor.getWrapperElement());
        var output = outputDiv.children("textarea.d_code_output");
        var outputTitle = outputDiv.children("span.d_code_title");
        var stdin = stdinDiv.children("textarea.d_code_stdin");
        var args = argsDiv.children("textarea.d_code_args");

        var hideAllWindows = function()
        {
            stdinDiv.css('display', 'none');
            argsDiv.css('display', 'none');
            outputDiv.css('display', 'none');
            code.css('display', 'none');
        };

        argsBtn.click(function(){
            args.css('height', height(37));
            hideAllWindows();
            argsDiv.css('display', 'block');
            args.focus();
        });

        inputBtn.click(function(){
            stdin.css('height', height(37));
            hideAllWindows();
            stdinDiv.css('display', 'block');
            stdin.focus();
        });
        editBtn.click(function(){
            hideAllWindows();
            code.css('display', 'block');
            editor.focus();
        });

        runBtn.click(function(){
            $(this).attr("disabled", true);
            hideAllWindows();
            output.css('height', height(37));
            outputDiv.css('display', 'block');
            outputTitle.text("Application output");
            output.html("Running...");
            output.focus();
            
            $.ajax({
                type: 'POST',
                url: "/process.php",
                dataType: "xml",
                data: 
                {
                    'code' : encodeURIComponent(editor.getValue()), 
                    'stdin' : encodeURIComponent(stdin.val()), 
                    'args': encodeURIComponent(args.val())
                },
                success: function(data) 
                {
                    parseOutput(data, output, outputTitle);
                    runBtn.attr("disabled", false);
                },
                error: function() 
                {
                    output.html("Temporarily unavaible");
                    runBtn.attr("disabled", false);
                }
            });
        });
    });

    $("div.answer-nojs").each(function(index) {
        $(this).css("display", "none");
    });
});