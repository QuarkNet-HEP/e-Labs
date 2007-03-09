<%
boolean error = false;  //set true if there's an error in the parameters
String str = "";    //error string, only output if there is an error

try{
    int binValue = Integer.parseInt(request.getParameter("freq_binValue"));
    if(binValue <= 0){
        error =  true;
        str += "Please enter a positive integer for the number of bins.<br>\n";
    }
}
catch (NumberFormatException e){
    error = true;
    str += "Please enter a positive integer for the number of bins.<br>\n";
}

if(error){
%>
    <font color="red"><%=str%></font>
<%
    return;
}
%>
