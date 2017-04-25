  $(document).ready(function() {
    document.getElementById ("submit_friendrequest_id").addEventListener("click", submit_new_friend_request, false);

});

  function getQueryVariable(variable)
{
       var query = window.location.search.substring(1);
       var vars = query.split("&");
       for (var i=0;i<vars.length;i++) {
               var pair = vars[i].split("=");
               if(pair[0] == variable){return pair[1];}
       }
       return(false);
}

function submit_new_friend_request()
{

            var userId = getQueryVariable("userId");
            console.log( userId );
            var formData = {
                "uName": $("#friendidd").val(),
            }
            console.log(JSON.stringify(formData));

     $.ajax({
//                "dataType": "json",
                "data" : JSON.stringify(formData),
                "async": false,
                "crossDomain": true,
                "url": "http://@ec2-52-7-74-13.compute-1.amazonaws.com/friends/search",
                "method": "POST",
                "headers": {
                    "content-type": "application/json",
                },

                "processData": false,
                success: function(data){
                    console.log("success");
                    console.log(data.userNameList[0].userId);
                    for (var i = 0; i <data.userNameList.length; i++) {
                        var li = document.createElement('li');
                        //alert(list[i].username);
                      //  paragraph.appendChild(list[i].username);
                        var t = document.createTextNode(data.userNameList[i].username);
                        li.appendChild(t);
                        li.id = data.userNameList[0].userId;
                        document.getElementById("input").appendChild(li);
                    };
                },

                error: function(jqxhr, textStatus, errorThrown){
                    console.log("error");
                    console.log(textStatus);
                    console.log(errorThrown);

                }
        });
    return false;

}
