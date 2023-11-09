function populateDashboardOrderList(callback) {

    $('.item-loading').show();
    $.ajax({
        dataType: "json",
        url: '/Order/GetOnlineOrdersForDashboard',
        data: {},
        success: function (recordSet) {
            $('.item-loading').hide();
            var dataSet = [];
            if (recordSet.length > 0) {
                for (var i = 0; i < recordSet.length; i++) {
                    var record = [];
                    record.push(recordSet[i].Id);
                    record.push(recordSet[i].OrderCode);
                    record.push(siteCurrency() + recordSet[i].PayAmount.toFixed(2));
                    record.push(recordSet[i].OrderMode);
                    record.push(recordSet[i].OrderStatus);
                    record.push(recordSet[i].PaymentStatus);
                    record.push(recordSet[i].PaymentType);
                    record.push(recordSet[i].ActionDateString);

                    dataSet.push(record);
                }
            }

            callback(dataSet);
        },
        error: function (xhr) {
            $('.item-loading').hide();
        }
    });
}

function GetFeedbacks() {
    $("#feedback-table").DataTable().destroy();
    $.ajax({
        dataType: "json",
        url: '/ContactUS/GetFeedbacks',
        data: {},
        success: function (data) {
            if (data.IsSuccess) {
                let feedbacks = data.Data;
                let html = "";
                for (let i = 0; i < feedbacks.length; i++) {
                    html +=
                        "<tr>" +
                        "<td>" + feedbacks[i].Name + "</td>" +
                        "<td>" + feedbacks[i].Email + "</td>" +
                        "<td>" + feedbacks[i].Description + "</td>" +
                        "<td><button type='button' class='feedbackDelete btn btn-danger' data-id='" + feedbacks[i].Id + "'>Delete</button> <button type='button' class='sendMessage btn btn-info' data-id='" + feedbacks[i].Id + "'>Reply</button></td>" +


                        "</tr>"
                }
                $("#feedbackBody").html(html);


                $("#feedback-table").dataTable({
                    //"data": records,
                    "bLengthChange": false,
                    "bFilter": true,
                    "pageLength": 5,
                    "bDestroy": true,
                    "responsive": true
                })

            }

        },
        error: function (xhr) {
        }
    });
}


function GetOrderStatus(callback) {
    $.ajax({
        dataType: "json",
        url: '/Admin/GetOrderStatus',
        success: function (recordSet) {
            callback(recordSet);
        },
        error: function (xhr) {
        }
    });
}

function GetTotalItemValues(callback) {
    $.ajax({
        dataType: "json",
        url: '/Admin/GetTotalItemValues',
        success: function (recordSet) {
            callback(recordSet);
        },
        error: function (xhr) {
        }
    });
}

$(document).ready(function () {

    $("#menu-toggle").click(function (e) {
        e.preventDefault();
        $("#wrapper").toggleClass("toggled");
    });

    $(document).on("click", ".feedbackDelete", function (e) {

        let feedbackId = $(this).attr('data-id');

        bootbox.confirm("<h4>Are you sure to delete?</h4>",
            function (result) {
                if (result) {
                    $.ajax({
                        dataType: "json",
                        contentType: 'application/json',
                        url: '/ContactUS/DeleteFeed',
                        data: { feedbackId: feedbackId },
                        success: function (data) {
                            if (data.IsSuccess) {
                                bootbox.alert("<h4>Successful!</h4>");
                                GetFeedbacks();
                            }
                            else {
                                hideLoader();
                                bootbox.alert("<h4>Failed to delete this feedback!</h4>", function () { });
                            }
                            $('#updateStatus').html('');
                        },
                        error: function (xhr) {
                            hideLoader();
                            $('#updateStatus').html('');
                            bootbox.alert("<h4>Error occured while deleting this feedback!</h4>", function () { });
                        }
                    });

                }
            });
    })

});


app.factory('dashboardService', [
    '$http', function ($http) {

        return {

        };
    }
]);

app.controller('AdminDashboardCtrl', ['$rootScope', '$scope', '$http', '$filter', '$location', 'Enum', 'dashboardService', function ($rootScope, $scope, $http, $filter, $location, Enum, dashboardService) {

    GetOrderStatus(function (data) {
        if (data) {
            $('#storeSellCount').html(data[0].StoreSell);
            $('#onlineSellCount').html(data[0].OnlineSell);
            $('#phoneOrderCount').html(data[0].PhoneOrderSell);
            $('#pendingOrderCount').html(data[0].PhoneOrderSell);
            $('#deliveryOrdersCount').html(data[0].DeliveryOrders);
            $('#pickupOrdersCount').html(data[0].PickupOrders);
            $('#deliveryOrdersSell').html(data[0].DeliveryOrdersSell);
            $('#pickupOrdersSell').html(data[0].PickupOrdersSell);

            $("#dashboardTotalAmount").html(data[0].TotalAmount == null ? 0 : data[0].TotalAmount);
            $("#dashboardTotalCash").html(data[0].CashAmount == null ? 0 : data[0].CashAmount);
            $("#dashboardTotalEftos").html(data[0].OnlineAmount == null ? 0 : data[0].OnlineAmount);
        }
    });

    GetTotalItemValues(function (data) {
        if (data) {
            $('#totalItemPosted').html(data[0].TotalItemPosted);
            $('#totalItemValue').html(data[0].TotalItemValue);
        }
    });

    populateDashboardOrderList(function (records) {
        $('#admin-dashboard-orderlist').dataTable({
            "data": records,
            "bLengthChange": false,
            "bFilter": true,
            "pageLength": 50,
            "bDestroy": true,
            "responsive": true,
            "order": [[1, "desc"]],
            "columns": [
                { "title": "Order Id", "class": "center" },
                { "title": "Order No", "class": "center" },
                { "title": "Grand Total", "class": "right" },
                { "title": "Order Mode", "class": "center" },
                { "title": "Order Status", "class": "center" },
                { "title": "Payment Status", "class": "center" },
                { "title": "Payment Type", "class": "center" },
                { "title": "Order Date" },
                { "title": "Action", "class": "center" }
            ],
            "aoColumnDefs": [
                {
                    "aTargets": [0, 8],
                    "visible": false
                },
                {
                    "aTargets": [1],
                    "mRender": function (data, type, row) {
                        var text = '<a href=/Order/OrderDetails?orderId=' + row[0] + '>' + row[1] + '</a>';
                        return $("<div/>").append(text).html();
                    }
                },
                {
                    "aTargets": [4],
                    "mRender": function (data, type, row) {

                        var status = row[4];
                        var className = 'order-status-processing';

                        if (status === 'Completed') {
                            className = 'order-status-completed';
                        }
                        else if (status === 'Processing') {
                            className = 'order-status-processing';
                        }

                        var text = '<span class="' + className + '">' + status + '</span>';
                        return $("<div/>").append(text).html();
                    }
                },
                {
                    "aTargets": [8],
                    "mRender": function (data, type, row) {
                        var text = '<a id=' + row[0] + ' class="btn btn-success btn-order-complete">Complete</a>';
                        return $("<div/>").append(text).html();
                    }
                }
            ]
        });

    });

    $('.order-mode').click(function () {
        var orderStatus = getParam('orderStatus');
        var orderMode = $(this).attr('id');
        window.location.href = "/Order/OrderList?orderStatus=" + orderStatus + "&orderMode=" + orderMode;

    });

    GetFeedbacks();
}]);