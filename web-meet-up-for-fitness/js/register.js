function register_submit(){

            var formData = {
                "username": $('#signup-username').val(),
                "password": $('#signup-password').val(),
                "email"   : $('#signup-email').val(),
                "gender"  : "",
                "avatarURL": "",
                "description" : ""
            }
            // var formData = $('#register_id').serialize();
            console.log(formData);

            $.ajax({
                  "dataType" : "json",
                  "data":JSON.stringify(formData),
                  "async": true,
                  "crossDomain": true,
                  "url": "http://ec2-52-7-74-13.compute-1.amazonaws.com/auth/signup",
                  "method": "POST",
                  "headers": {
                    "content-type": "application/json",
                  },

                success: function(result){
                    // console.log('success');
                    // console.log(result);
                    $.alert({
                            title: 'Register Finished',
                            content: 'You Made the Registration',
                            animation: 'rotate',
                            closeAnimation: 'right',
                            buttons: {
                                close: function () {
                                    this.setCloseAnimation('rotate');
                                }
                            },
                            backgroundDismiss: function () {
                                return false;
                            },
                        });
                    },
                error: function(jqxhr, textStatus, errorThrown){
                         $.alert({
                            title: 'We are sorry',
                            type: 'red',
                            content: 'You did not pass the registration, please try again!'
                        });
                    }
            });
            return false;


        };

function login_submit() {
        var formdata = {
            "username": $('#signin-email').val(),
            "password": $('#signin-password').val()
        }
        console.log(formdata);
        $.ajax({
            "dataType" : "json",
            "data": JSON.stringify(formdata),
            "async" : true,
            "crossDomain": true,
            "url": "http://@ec2-52-7-74-13.compute-1.amazonaws.com/auth/login",
            "method": 'POST',
            "headers": {
                "content-type": "application/json",
            },
     
            success: function(result) {


                console.log(result);
                if(!result.userId){
                    $.alert({
                        title: 'Oh no',
                        type: 'red',
                        content: 'Something bad, bad happened. You did not register yet!'
                    });
                    return 0;
                } else {

                    window.location.href = 'activity.html?userId=' + result.userId;
                }
                //var json = jQuery.parseJSON(result);

            },
            error: function(xhr, txtstatus, errorthrown) {
                 console.log(xhr);
                 console.log(txtstatus);
                    $.alert({
                        title: 'Oh no',
                        type: 'red',
                        content: 'Something bad, bad happened.'
                    });
                // console.log(xhr);
                // console.log(txtstatus);
                //console.log("\n{\n\t\"username\":\"demo\",\n\t\"password\":\"123\"\n}");
            }
        });
        return false;


        };