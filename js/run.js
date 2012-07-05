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
        output += "<b>Output: </b><br />" + (stdout == "" && stderr == "" ?
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
        p.css("display", "block");
        var originalSource = thisObj.val();
        var runBtn = p.children("input.runButton");
        var resetBtn = p.children("input.resetButton");
        var stdin = p.children("input.d_code_stdin").val();
        var args = p.children("input.d_code_args").val();
        var code = thisObj.val();

        var editor = CodeMirror.fromTextArea(thisObj[0], {
                lineNumbers: false,
                tabSize: 4,
                indentUnit: 4,
                indentWithTabs: true,
                mode: "text/x-csharp",
                lineWrapping: true,
               //onGutterClick: foldFunc,
                theme: "eclipse",
                readOnly: false,
                onChange: function (editor, event) {
                   code = editor.getValue();
                },
        });

        runBtn.click(function(){
            $(this).attr("disabled", true);
            $(this).val("Running...");

            if (p.children("p.outputWindow")[0] != null) {
                var outputWindow = p.children("p.outputWindow");
            }
            else {
                var outputWindow = $('<p class="outputWindow"/>');
                p.append(outputWindow);
            }
            outputWindow.html("");

            var output = "";

            $.ajax({
                type: 'POST',
                url: "/process.php",
                data: {'code' : encodeURIComponent(code), 'stdin' : encodeURIComponent(stdin), 'args': encodeURIComponent(args)},
                success: function(data)
                {
                    outputWindow.html(parseOutput(data));

                    runBtn.attr("disabled", false);
                    runBtn.val("Run");
                },
                error: function()
                {
                    outputWindow.html("<h5>Temporarily unavaible</h5>");

                    runBtn.attr("disabled", false);
                    runBtn.val("Run");
                }
            });
        });

        resetBtn.click(function(){
            editor.setValue(originalSource);
            var outputWindow = p.children("p.outputWindow");
            outputWindow.remove();
        });
    });

    $("div.answer-nojs").each(function(index) {
        $(this).css("display", "none");
    });
});