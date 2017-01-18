    function myFunction() {
        var students = document.getElementById("myInput").value;
var htmlString = "";
    for (i=0; i< parseInt(students); i++) {
    	htmlString += "<input type = \"text\" question = \"question[]\"><br>";
    }
    htmlString += "<input type = \"submit\">";
	document.getElementById("demo").innerHTML = htmlString;
        }