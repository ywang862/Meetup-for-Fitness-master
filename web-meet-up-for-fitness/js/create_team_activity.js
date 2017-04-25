$(document).ready(function() {
  document.getElementById ("submit_activity_id").addEventListener ("click", submit_new_activity, false);

    var select_id = document.getElementById("se-control");
    var option_fragment = document.createDocumentFragment();
    var userId = getQueryVariable("userId");
    var url_addr = "http://@ec2-52-7-74-13.compute-1.amazonaws.com/friends/" + userId;

    console.log('friends');
    $.ajax({
        "dataType" : "json",
        "async": false,
        "crossDomain": true,
        "url": url_addr,
        "method": "GET",

        success : function(data){
            //拿到数据
            console.log(data);
            console.log(data["Friends List"].length);
            var friends_array = data["Friends List"];
            var friens_num = friends_array.length;

            for (var i = 0; i < friens_num; i++) {
                var option = document.createElement('option');
                option.value = i;
                option.appendChild(document.createTextNode( friends_array[i]['username']));
                option_fragment.appendChild(option);
            }
            select_id.appendChild(option_fragment);
        },
        error: function(xhr, txtstatus, errorthrown) {
             console.log(xhr);
             console.log(txtstatus);
        }
    });

    var team_list = document.getElementById("team_name");
    var team_fragment = document.createDocumentFragment();
    var url_addr = "http://@ec2-52-7-74-13.compute-1.amazonaws.com/teams/" + userId;

    $.ajax({
        "dataType" : "json",
        "async": false,
        "crossDomain": true,
        "url": url_addr,
        "method": "GET",

        success : function(data){
            //拿到数据
            console.log(data);
            console.log(data["Team List"].length);
            var teams_array = data["Team List"];
            var teams_num = teams_array.length;

            for (var i = 0; i < teams_num; i++) {
                var team_option = document.createElement('option');
                team_option.value = i;
                team_option.appendChild(document.createTextNode( teams_array[i]['tname']));
                team_fragment.appendChild(team_option);
            }
            team_list.appendChild(team_fragment);
        },
        error: function(xhr, txtstatus, errorthrown) {
             console.log(xhr);
             console.log(txtstatus);
        }
    });

  $('#contact_form').bootstrapValidator({
      // To use feedback icons, ensure that you use Bootstrap v3.1.0 or later
      feedbackIcons: {
          valid: 'glyphicon glyphicon-ok',
          invalid: 'glyphicon glyphicon-remove',
          validating: 'glyphicon glyphicon-refresh'
      },
      fields: {
          first_name: {
              validators: {
                      stringLength: {
                      min: 2,
                  },
                      notEmpty: {
                      message: 'Please supply your first name'
                  }
              }
          },
           state: {
              validators: {

                  notEmpty: {
                      message: 'Please suupply the sports type'
                  }
              }
          },
          activity_name: {
              validators: {
                  notEmpty: {
                      message: 'Please supply your activity name '
                  }
              }
          },

          people: {
              validators: {
                  notEmpty: {
                      message: 'Please supply the maximum number of people of this activity'
                  }
              }
          },
          timefield: {
              validators: {
                  notEmpty: {
                      message: 'Please supply the time you want for the activity'
                  }
              }
          },
          address: {
              validators: {
                  notEmpty: {
                      message: 'Please supply your address'
                  }
              }
          },
          comment: {
              validators: {
                    stringLength: {
                      min: 10,
                      max: 200,
                      message:'Please enter at least 10 characters and no more than 200'
                  },
                  notEmpty: {
                      message: 'Please supply a description of your project'
                  }
                  }
              }
          }
      })
      .on('success.form.bv', function(e) {
          $('#success_message').slideDown({ opacity: "show" }, "slow") // Do something ...
              $('#contact_form').data('bootstrapValidator').resetForm();
          console.log('second');
          // Prevent form submission
          e.preventDefault();

          // Get the form instance
          var $form = $(e.target);

          // Get the BootstrapValidator instance
          var bv = $form.data('bootstrapValidator');


      });
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
function submit_new_activity()
{
          var userId = getQueryVariable("userId");

            var atime = $('#time-input').val();
            //atime = 21 April 2017, 11:01 am

            var vars = atime.split(",");

            var date = vars[0];


            var time = vars[1].split(" ")[1];

            var d = new Date(date);

            var days = ["Sun","Mon","Tue","Wed","Thur","Fri","Sat"];

            var dayOfWeek = days[d.getDay()];
            var newTime = dayOfWeek.concat(', ', date, ' ', time, ':00 EDT' );


            console.log(newTime);
            
          var formData = {
              "aName": $('#activity_name_input').val(),
              "sportsType": $('#sports-type option:selected').val(),
              "aTime"   : newTime,
              "friendList"  : $('#se-control option:selected').val(),
              "maxPeople": $('#maximum').val(),
              "teamId": $('#team_name option:selected').val(),
              "aInfo" : $('#activity_info').val(),
              "location" : $('#autocomplete').val()
          }
              if($.isEmptyObject(formData["aName"]) || $.isEmptyObject(formData["sportsType"]) 
                || $.isEmptyObject(formData["aTime"])
                || $.isEmptyObject(formData["maxPeople"]) || $.isEmptyObject(formData["location"])) {
                return false;
            }
            $.ajax({
                "dataType" : "json",
                "async": false,
                "crossDomain": true,
                "url": "http://@ec2-52-7-74-13.compute-1.amazonaws.com/friends/" + userId,
                "method": "GET",

                success : function(data){
                    
                },
                error: function(xhr, txtstatus, errorthrown) {
                     console.log("friend_empty");
                     formData['friendList'] = "-1";
                }
            });
                   
            $.ajax({
                "dataType" : "json",
                "async": false,
                "crossDomain": true,
                "url": "http://@ec2-52-7-74-13.compute-1.amazonaws.com/teams/" + userId,
                "method": "GET",

                success : function(data){
                    
                },
                error: function(xhr, txtstatus, errorthrown) {
                     console.log("team empty");
                     formData['teamId'] = "-1";
                }
            }); 
            console.log( JSON.stringify(formData) );

           $.ajax({
                      "data" : JSON.stringify(formData),
                      "async": false,
                      "crossDomain": true,
                      "url": "http://@ec2-52-7-74-13.compute-1.amazonaws.com/activity/add/allInfo/" + userId,
                      "method": "POST",
                      "headers": {
                          "content-type": "application/json; charset=utf-8",
                      },

                      "processData": false,

                      success : function(data){
                          window.parent.location.reload(true);

                          // console.log("success");
                          // console.log(data);
                      },

                      error: function(jqxhr, textStatus, errorThrown){
                          // console.log("error");
                          // console.log(textStatus);
                          // console.log(errorThrown);

                      }
              });
          return false;

}
