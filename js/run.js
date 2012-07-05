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

function parseOutput(data)
{
    output = "";
    var json = jQuery.parseJSON(data);
    if (json == null)
    {
        output = "<h5>Temporarily unavaible</h5>";
        return output;
    }

    /* 
    * Escape html/script/etc
    */
    var cout = $('<div/>').text(json["compilation"]["stdout"]).html();
    var stdout = $('<div/>').text(json["runtime"]["stdout"]).html();
    var stderr = $('<div/>').text(json["runtime"]["stderr"]).html();

    if (json["compilation"]["status"] != 0)
    {
        output = '<b>Compilation failure: </b><br /><div class="outputWindow">'+ cout + "</div>";
    }
    else
    {
        if ( cout != "")
        {
            output = '<b>Compilation output: </b><br />'
                + '<div class="outputWindow">' + cout + "</div><br />";
        }
        output += (stdout == "" && stderr == "" ? 
            '<div class="outputWindow">-- No output --</div>' : '<div class="outputWindow">'+stdout);

        if (stderr != "") 
        {
            output += stderr;
        }

        output += "</div>";
    }

    return output.nl2br();
}

$(document).ready(function() 
{
    $('textarea[class=d_code]').each(function(index) {
        var thisObj = $(this);

        var p = thisObj.parent();
        var codeStr = thisObj.val();
        p.css("display", "block");
        var originalSource = thisObj.val();
        

        var editor = CodeMirror.fromTextArea(thisObj[0], {
                lineNumbers: false,
                tabSize: 4,
                indentUnit: 4,
                indentWithTabs: true,
                mode: "text/x-csharp",
                lineWrapping: true,
                theme: "eclipse",
                readOnly: false,
                onChange: function (editor, event) {
                   codeStr = editor.getValue();
                },
        });

        var runBtn = p.children("input.runButton");
        var editBtn = p.children("input.editButton");
        var inputBtn = p.children("input.inputButton");
        var resetBtn = p.children("input.resetButton");
        var argsBtn = p.children("input.argsButton");
        var stdinDiv = p.children("div.d_code_stdin");
        var argsDiv = p.children("div.d_code_args");
        var outputDiv = p.children("div.d_code_output_div");

        var code = $(editor.getWrapperElement());
        var output = outputDiv.children("div.d_code_output");
        var stdin = stdinDiv.children("textarea.d_code_stdin");
        var args = argsDiv.children("textarea.d_code_args");

        var hideAllWindows = function()
        {
            stdinDiv.css('display', 'none');
            argsDiv.css('display', 'none');
            outputDiv.css('display', 'none');
            code.css('display', 'none');

            inputBtn.removeClass('test');
            argsBtn.removeClass('test');
            runBtn.removeClass('test');
            editBtn.removeClass('test');
        };

        var originalStdin = stdin.val();
        var originalArgs = args.val();

        argsBtn.click(function(){
            hideAllWindows();
            argsDiv.css('display', 'block');
            $(this).addClass('test');
        });

        inputBtn.click(function(){
            hideAllWindows();
            stdinDiv.css('display', 'block');
            $(this).addClass('test');
        });
        editBtn.click(function(){
            hideAllWindows();
            code.css('display', 'block');
            $(this).addClass('test');
        });

        runBtn.click(function(){
            $(this).attr("disabled", true);
            hideAllWindows();
            outputDiv.css('display', 'block');
            output.html("Running...");

            $.ajax({
                type: 'POST',
                url: "/process.php",
                data: 
                {
                    'code' : encodeURIComponent(editor.getValue()), 
                    'stdin' : encodeURIComponent(stdin.val()), 
                    'args': encodeURIComponent(args.val())
                },
                success: function(data) 
                {
                    output.html(parseOutput(data));
                    runBtn.attr("disabled", false);
                },
                error: function() 
                {
                    output.html("<h5>Temporarily unavaible</h5>");
                    runBtn.attr("disabled", false);
                }
            });
        });
    });

    $("div.answer-nojs").each(function(index) {
        $(this).css("display", "none");
    });
});