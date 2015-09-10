//= require store/spree_core

$(document).ready(function () {
    $("input#apply_credit").on('click',function(){
        requestUri = $(this).data('uri')
        value = $(this).is(':checked')
        $.ajax({
            url: requestUri,
            data: { credit: value},
            type: 'PUT'
        })
    });
});
