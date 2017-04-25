
function getWaterfall() {
        var page = 1;
        var initial = 1;
        var userId = 0;

        getJSONandRender(page, initial, userId);



        var lock = true;
        //监听滚动
        $(window).scroll(function(){
            if(!lock) return;
            var rate = $(window).scrollTop() / ($(document).height() - $(window).height());

            if(rate >= 70){
                page ++;
                getJSONandRender(page, initial, userId);
                lock = false;
            }
        });
}

function get_my_activity_waterfall(userId) {
        var page = 1;
        var initial = 0;
        $('#waterfall div').empty();
         getJSONandRender(page, initial, userId);



        var lock = true;
        //监听滚动
        $(window).scroll(function(){
            if(!lock) return;
            var rate = $(window).scrollTop() / ($(document).height() - $(window).height());

            if(rate >= 70){
                page ++;
                getJSONandRender(page, initial,userId);
                lock = false;
            }
        });
}
function getJSONandRender(page, initial, userId){
        if(initial == 1) {
            var url_addr = "http://ec2-52-7-74-13.compute-1.amazonaws.com/activity";
        }
        else {
            var url_addr = "http://ec2-52-7-74-13.compute-1.amazonaws.com/activity/" + userId;
            console.log( 'made it!');
        }

        var $waterfall = $("#waterfall");
        var templateString = $("#template").html();
        var compileFunction = _.template(templateString);
        var colHeight = [0,0,0];

        $.ajax({
            "dataType" : "json",
            "async": true,
            "crossDomain": true,
            "url": url_addr,
            "method": "GET",
            "success" : function(data){
                
                var dataArray = data.activities;
                console.log(dataArray);
                if(dataArray.length == 0){
                    return;
                }
                lock = true;

                $.each(dataArray,function(index, dictionary){
                    //add image
                    var image = new Image();
                        image.src = "../img/sports.jpg";
                    // console.log(dataArray[index]);
                    $(image).load(function(){
                        var domString = compileFunction(dictionary);
                        $grid = $(domString);
                        $waterfall.append($grid);

                        minValue = _.min(colHeight);
                        minIndex = _.indexOf(colHeight,minValue);
                        $grid.css({
                            "top" : minValue,
                            "left" : minIndex * 250
                        });
                        colHeight[minIndex] += $grid.outerHeight() + 20;
                        $waterfall.css("height",_.max(colHeight));
                    });
                });
            },
            error: function(xhr, txtstatus, errorthrown) {
             console.log(xhr);
             console.log(txtstatus);

            }
        });
    }
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
function my_activity_trigger()
{
    var userId = getQueryVariable("userId");
    if( !userId ) {

    }
    console.log( 'test' );
        console.log( userId );

    get_my_activity_waterfall(userId);
}
function team_activity_trigger()
{  
        var page = 1;
        var initial = 1;
        var userId = 0;
        $('#waterfall div').empty();

        getJSONandRender(page, initial, userId);



        var lock = true;
        //监听滚动
        $(window).scroll(function(){
            if(!lock) return;
            var rate = $(window).scrollTop() / ($(document).height() - $(window).height());

            if(rate >= 70){
                page ++;
                getJSONandRender(page, initial, userId);
                lock = false;
            }
        });
}
function attend_activity(aid) {
    var userId = getQueryVariable("userId");

    console.log(userId);
    console.log(aid);
    var formData = {
            "userId": userId,
            "aid": aid
        }
        // var formData = $('#register_id').serialize();
        console.log(formData);

        $.ajax({
            "data" : JSON.stringify(formData),
            "async": true,
            "crossDomain": true,
            "url": "http://@ec2-52-7-74-13.compute-1.amazonaws.com/activity/attend",
            "method": "POST",
            "headers": {
                "content-type": "application/json; charset=utf-8",
            },

            "processData": false,

            success : function(data){
                console.log("success");
                console.log(data);
            },

            error: function(jqxhr, textStatus, errorThrown){
                console.log("error");
                console.log(textStatus);
                console.log(errorThrown);

            }
        });
        return false;

}
