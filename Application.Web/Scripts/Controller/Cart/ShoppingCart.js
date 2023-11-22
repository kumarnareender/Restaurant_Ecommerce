$(document).ready(function () {



    //let appType = $("#appType").val();
    //if (appType == "Restaurant") {
    //$("#shopping-cart").hide();
    //$("#cart-amount-calculation").hide();
    $(".desiDiv").hide();
    $("#restaurant-div").show();
    $(".btnRestaurant").show();
    //$("#btnCompleteRestOrder").hide();
    //}


    var tableNumber = getParam('tableNumber');

    if (tableNumber != null && tableNumber != "") {
        localStorage.setItem("tableNumber", tableNumber);
        GetOrderByTableNumber(tableNumber);
        $(".hideDiv").hide();
    }

    let localTableNumber = localStorage.getItem("tableNumber");
    if (localTableNumber != null && localTableNumber != "" && (tableNumber == null || tableNumber == "")) {
        GetOrderByTableNumber(localTableNumber);

        $(".hideDiv").hide();
    }
    $("#cart-text").text("Table Number: " + localTableNumber);


    getUserInformation();
    //builtShoppingCartItems();

    //confirmOrderList();


    //$("#div-place-order").hide();

    showStep();

    function showStep() {
        var param = getParam('step');
        if (param === 'confirm-order') {
            $('#div-confirm-order').show();
            $('#div-place-order').hide();
        }
    }

    $(document).on('click', '.delete-shopping-cart-item', function () {
        var id = $(this).attr('id');

        removeCartItem(id)

        var currentTr = $(this).closest("tr");
        $(currentTr).remove();

        builtShoppingCartItems();
    });

    //let productIds = [];


    function clearCartByProductIds() {
        let productIds = window.localStorage.getItem("productIds");
        if (productIds != null && productIds != '') {
            productIds = productIds.split(",");
            for (let i = 0; i < productIds.length; i++) {
                removeCartItem(productIds[i]);
            }
        }
        //builtShoppingCartItems();

    }

    $(document).on('click', '.tables-click', function () {
        $("._tables").prop("checked", false);
        /*        var id = $("._tables:checked").val();*/
        var dataid = $(this).attr('data-id');
        //if (!$("#_table" + dataid).is(":checked")) {
        $("#_table" + dataid).prop("checked", true);
        //    //return;
        //}
        $("#cart-text").text("Table Number: " + dataid);
        $("#myModal").modal('hide');
        //GetOrderByTableNumber(dataid);


        //console.log("CheckboxId: ", id);
        //console.log("CheckboxId-dataid: ", dataid);
    });

    function GetOrderByTableNumber(dataid) {

        $.ajax({
            dataType: "json",
            url: '/RestaurantTables/GetOrderDetailsByTableNumber',
            data: { tableId: dataid },
            success: function (recordSet) {

                clearCartByProductIds();
                let productIds = [];

                if (recordSet.OrderItems != null) {
                    if (recordSet.OrderItems.length > 0) {
                        for (let i = 0; i < recordSet.OrderItems.length; i++) {
                            productIds.push(recordSet.OrderItems[i].ProductId);
                            addToCart(recordSet.OrderItems[i].ProductId, recordSet.OrderItems[i].ProductName, recordSet.OrderItems[i].Quantity, recordSet.OrderItems[i].Price, recordSet.OrderItems[i].ImageUrl, 0, 0, '', '',
                                recordSet.OrderItems[i].Description != null ? recordSet.OrderItems[i].Description : '', recordSet.OrderItems[i].Options);
                        }

                    }
                }
                $("#orderNotes").val(recordSet.Notes);
                window.localStorage.setItem("productIds", productIds);
                console.log(recordSet);
                builtShoppingCartItems();
                $("#myModal").modal('hide');
            },
            error: function (xhr) {
                $('.item-loading').hide();
            }
        });
    }

    $('#btnClearCart').click(function () {

        bootbox.confirm("<h3 class='text-danger'>Clear Cart Items</h3> " +
            "<br/><h4 class='text-info'> Are you sure to clear the cart?</h4>",
            function (result) {
                if (result) {
                    clearCart();
                    localStorage.setItem("tableNumber", "");
                    $(".hideDiv").show();
                    builtShoppingCartItems();

                }
            });

    });

    $('#btnUpdateCart').click(function () {

        var cart = getCart();
        for (var i = 0; i < cart.length; i++) {
            var quantityInputBoxId = 'txtQty_' + cart[i].Id + '_' + i;
            cart[i].Quantity = $('#' + quantityInputBoxId).val();
        }

        updateCart(cart);
        builtShoppingCartItems();
        confirmOrderList();
    });
    //$(document).on("change", "#order-type-shopping-cart", function () {

    //    let grandTotal = +$('#grandTotal').val();
    //    let shippingCharges = +$("#shippingAmount").val();

    //    let newGrandTotal = grandTotal;

    //    if ($(this).val() == 'Wholesale') {
    //        $("#wholesale-customer-div").removeClass('hide');//addClass("d-none");
    //        $("#purchase-supplier-div").addClass('hide');
    //        $("#btnPlaceOrder").removeClass('hide');
    //        $("#btnPurchaseOrder").addClass('hide');
    //        $(".p-order").removeClass('hide');
    //        newGrandTotal = grandTotal + shippingCharges;
    //    }
    //    else if ($(this).val() == 'Purchase') {
    //        $("#wholesale-customer-div").addClass('hide');//remvoeClass("d-none");
    //        $("#purchase-supplier-div").removeClass('hide');
    //        $("#btnPlaceOrder").addClass('hide');
    //        $("#btnPurchaseOrder").removeClass('hide');
    //        $(".p-order").addClass('hide');
    //        //$("#shippingAmount").val(0);
    //        $("#btnUpdateAddress").addClass('hide');

    //    } else {
    //        $("#wholesale-customer-div").addClass('hide');//remvoeClass("d-none");
    //        $("#purchase-supplier-div").addClass('hide');

    //        $("#btnPlaceOrder").removeClass('hide');
    //        $("#btnPurchaseOrder").addClass('hide');
    //        $(".p-order").removeClass('hide');
    //        newGrandTotal = grandTotal + shippingCharges;
    //    }
    //    $(".checkout-grandTotal").html(siteCurrency() + newGrandTotal);

    //})

    $(document).on("change", "#wholesale-customer, #purchase-supplier", function () {
        let zipCode = $('option:selected', this).attr('postal-code');
        let firstName = $('option:selected', this).attr('name');
        let address = $('option:selected', this).attr('address');
        let mobile = $('option:selected', this).attr('mobile');
        let country = $('option:selected', this).attr('country');
        let city = $('option:selected', this).attr('city');

        $('#firstName').val(firstName);
        $('#mobile').val(mobile);
        $('#address').val(address);
        $('#zip').val(zipCode);
        $('#city').val(city);
        $('#state').val(country);
        //$('#email').val(email);

        // Show in confirm order section
        $('#showFirstName').html(firstName);
        $('#showMobile').html(mobile);
        $('#showAddress').html(address);
        $('#showZipCode').html(zipCode);
        $('#showCity').html(city);
        $('#showState').html(country);

    })

    function showLoader() {
        $('#order-loader').show();
        $('#btnBack').show();
        $("#btnConfirmOrder").prop("disabled", true);
        $("#btnBack").prop("disabled", true);
    }

    function hideLoader() {
        $('#order-loader').hide();
        $('#btnBack').hide();
        $("#btnConfirmOrder").prop("disabled", false);
        $("#btnBack").prop("disabled", false);
    }

    function isCodPayment() {

        // COD or Card payment
        var isCod = false;
        if ($("#rbCod").is(":checked")) {
            isCod = true;
        }

        return isCod;
    }

    function getPaymentType() {
        return document.querySelector('input[name="paymentBy"]:checked').value;
    }

    // Here order records are save
    $('#btnConfirmOrder').click(function () {
        var userStatus = getUserStatus();
        if (!userStatus.isLoggedIn) {
            window.location.href = '/Security/Login/?returnUrl=/cart';
            return;
        }

        // COD or Card
        var paymentType = getPaymentType();//isCodPayment();

        var order = {};
        order.OrderItems = [];

        var cart = getCart();
        var totalAmount = 0;
        var vatAmount = 0;
        var val = 0;
        var shippingAmount = +$("#shippingAmount").val();
        var grandTotal = 0;

        for (var i = 0; i < cart.length; i++) {

            var orderItem = {};

            var price = parseFloat(cart[i].OnlinePrice, 10);
            var quantity = parseInt(cart[i].Quantity, 10);

            orderItem.ProductId = cart[i].Id;
            orderItem.Quantity = quantity;
            orderItem.Discount = 0;
            orderItem.Price = price;
            orderItem.TotalPrice = quantity * price;
            orderItem.ImageUrl = cart[i].ImageUrl;
            orderItem.Color = cart[i].Color;
            orderItem.Size = cart[i].Size;

            order.OrderItems.push(orderItem);
            totalAmount += orderItem.TotalPrice;

            vatAmount += +((orderItem.TotalPrice * Number(cart[i].Gst)) / 100);
        }

        //vat = Math.round((totalAmount * getVatPercentage()) / 100);
        grandTotal = totalAmount + shippingAmount;

        order.OrderMode = localStorage.getItem("OrderType");
        //$("#order-type-shopping-cart").val();

        order.OrderStatus = 'Processing';
        order.PaymentStatus = 'Pending';
        order.PaymentType = paymentType;//isCOD === true ? 'COD' : 'Card';
        order.Ordertype = $('input[name="Ordertype"]:checked').val();

        order.Vat = vatAmount;
        order.Discount = $("#discount").val();
        order.ShippingAmount = shippingAmount;
        order.PayAmount = grandTotal - order.Discount;
        order.IsWholeSaleOrder = order.OrderMode == "Wholesale" ? true : false;
        /*$("#order-type-shopping-cart").val()*/;
        order.CustomerId = $("#wholesale-customer").val()
        showLoader();

        // Saving Records
        $.ajax({
            dataType: "json",
            contentType: 'application/json',
            url: '/Customer/PlaceOrder',
            data: JSON.stringify(order),
            method: 'POST',
            success: function (data) {
                if (data.isSuccess) {

                    clearCart();

                    if (order.OrderMode == "Wholesale") {
                        window.location.href = '/Wholesale/OrderConfirm?orderCode=' + data.orderCode;
                        return;
                    }

                    if (paymentType != "Online") {
                        window.location.href = '/Customer/OrderConfirm?orderCode=' + data.orderCode;
                    }
                    else {
                        proceedToCardPayment(data.orderId, data.orderCode, grandTotal);
                    }
                }
                else {
                    hideLoader();
                    bootbox.alert("<h4>Failed to place your order!</h4>", function () { });
                }

                $('#updateStatus').html('');
            },
            error: function (xhr) {
                hideLoader();
                $('#updateStatus').html('');
                bootbox.alert("<h4>Error occured while placing your order!</h4>", function () { });
            }
        });

    });

    $('#btnPurchaseOrder').click(function () {
        //var userStatus = getUserStatus();
        //if (!userStatus.isLoggedIn) {
        //    window.location.href = '/Security/Login/?returnUrl=/cart';
        //    return;
        //}

        // COD or Card

        let supplierId = $("#purchase-supplier").val()

        if (supplierId == "0") {
            bootbox.alert("<h4>Please Select Supplier!</h4>");
            return;
        }

        var isCOD = isCodPayment();

        var order = {};
        order.PurchaseOrderItems = [];

        var cart = getCart();
        var totalAmount = 0;
        var vatAmount = 0;
        var val = 0;
        var shippingAmount = +$("#shippingAmount").val();
        var grandTotal = 0;

        for (var i = 0; i < cart.length; i++) {

            var orderItem = {};

            var price = parseFloat(cart[i].OnlinePrice, 10);
            var quantity = parseInt(cart[i].Quantity, 10);

            orderItem.ProductId = cart[i].Id;
            orderItem.Quantity = quantity;
            orderItem.Discount = 0;
            orderItem.Price = price;
            orderItem.TotalPrice = quantity * price;
            orderItem.ImageUrl = cart[i].ImageUrl;

            order.PurchaseOrderItems.push(orderItem);
            totalAmount += orderItem.TotalPrice;

            vatAmount += +((orderItem.TotalPrice * Number(cart[i].Gst)) / 100);
        }

        //vat = Math.round((totalAmount * getVatPercentage()) / 100);
        grandTotal = totalAmount; /*+ shippingAmount;*/

        order.OrderMode = localStorage.getItem("OrderType");//$("#order-type-shopping-cart").val();
        order.OrderStatus = 'Processing';
        order.PaymentStatus = 'Pending';
        order.PaymentType = isCOD === true ? 'COD' : 'Card';
        order.Ordertype = $('input[name="Ordertype"]:checked').val();

        order.Vat = vatAmount;
        //order.Discount = $("#discount").val();
        //order.ShippingAmount = shippingAmount;
        order.PayAmount = grandTotal; /*- order.Discount;*/
        order.SupplierId = supplierId
        showLoader();
        //return;
        // Saving Records
        $.ajax({
            dataType: "json",
            contentType: 'application/json',
            url: '/PurchaseOrder/PlaceOrder',
            data: JSON.stringify(order),
            method: 'POST',
            success: function (data) {
                if (data.isSuccess) {

                    clearCart();

                    //if (isCOD) {
                    window.location.href = '/PurchaseOrder/OrderConfirm?orderCode=' + data.orderCode;
                    //}
                    //else {
                    //    proceedToCardPayment(data.orderId, data.orderCode, grandTotal);
                    //}
                }
                else {
                    hideLoader();
                    bootbox.alert("<h4>Failed to place your order!</h4>", function () { });
                }

                $('#updateStatus').html('');
            },
            error: function (xhr) {
                hideLoader();
                $('#updateStatus').html('');
                bootbox.alert("<h4>Error occured while placing your order!</h4>", function () { });
            }
        });

    });



    //Restaurant Module
    $('.btnSaveRestOrder').click(function () {
        var userStatus = getUserStatus();
        //if (!userStatus.isLoggedIn) {
        //    window.location.href = '/Security/Login/?returnUrl=/cart';
        //    return;
        //}

        showLoader();

        if ((localTableNumber == "" || localTableNumber == null) && ($("._tables:checked").val() == null || $("._tables:checked").val() == undefined)) {
            bootbox.alert("<h4>Please select table first!</h4>", function () { });
            return;
        }

        let orderType = $(this).attr('data-id');


        let order = {
            TableNumber: localTableNumber != "" ? localTableNumber : $("._tables:checked").val(),
            OrderType: orderType
        }


        //var paymentType = getPaymentType();//isCodPayment();

        order.OrderItems = [];

        var cart = getCart();
        var totalAmount = 0;
        var vatAmount = 0;
        var val = 0;
        var shippingAmount = +$("#shippingAmount").val();
        var grandTotal = 0;

        for (var i = 0; i < cart.length; i++) {
            var descriptionInputBoxId = '#txtDescription_' + cart[i].Id + '_' + i;
            var orderItem = {};

            var price = parseFloat(cart[i].OnlinePrice, 10);
            var quantity = parseInt(cart[i].Quantity, 10);

            orderItem.ProductId = cart[i].Id;
            orderItem.Quantity = quantity;
            orderItem.Discount = 0;
            orderItem.Price = price;
            orderItem.TotalPrice = quantity * price;
            orderItem.ImageUrl = cart[i].ImageUrl;
            orderItem.Color = cart[i].Color;
            orderItem.Size = cart[i].Size;
            orderItem.Description = cart[i].Description;//$(descriptionInputBoxId).val();
            orderItem.Options = cart[i].Option;

            order.OrderItems.push(orderItem);
            totalAmount += orderItem.TotalPrice;

            vatAmount += +((orderItem.TotalPrice * Number(cart[i].Gst)) / 100);
        }

        //vat = Math.round((totalAmount * getVatPercentage()) / 100);
        grandTotal = totalAmount + shippingAmount;

        order.OrderMode = localStorage.getItem("OrderType");
        //$("#order-type-shopping-cart").val();

        order.OrderStatus = 'Processing';
        order.PaymentStatus = 'Pending';
        //order.PaymentType = paymentType;//isCOD === true ? 'COD' : 'Card';
        //order.Ordertype = $('input[name="Ordertype"]:checked').val();

        order.Vat = vatAmount;
        order.Discount = $("#discount").val();
        order.ShippingAmount = shippingAmount;
        order.PayAmount = grandTotal - order.Discount;
        order.Notes = $("#orderNotes").val();
        //order.IsWholeSaleOrder = order.OrderMode == "Wholesale" ? true : false;
        /*$("#order-type-shopping-cart").val()*/;
        //order.CustomerId = $("#wholesale-customer").val()


        $("#rest-order-loader").show();

        // Saving Records
        $.ajax({
            dataType: "json",
            contentType: 'application/json',
            url: '/RestaurantTables/PlaceOrder',
            data: JSON.stringify(order),
            method: 'POST',
            success: function (data) {
                if (data.isSuccess) {

                    bootbox.alert("<h4>Your order has been saved!</h4>", function () { });
                    clearCart();
                    //if (orderType == "Complete")
                    localStorage.setItem("tableNumber", "");
                    $(".hideDiv").show();


                    //if (order.OrderMode == "Wholesale") {
                    //    window.location.href = '/Wholesale/OrderConfirm?orderCode=' + data.orderCode;
                    //    return;
                    //}

                    //if (paymentType != "Online") {
                    //window.location.href = '/Customer/OrderConfirm?orderCode=' + data.orderCode;
                    var userStatus = getUserStatus();
                    if (!userStatus.isLoggedIn) {
                        window.location.href = '/Home/Index?tableNumber = ' + order.TableNumber;
                    }
                    window.location.href = '/Home/Index';

                    //}
                    //else {
                    //    proceedToCardPayment(data.orderId, data.orderCode, grandTotal);
                    //}
                    $("#rest-order-loader").hide();
                }
                else {
                    //hideLoader();
                    console.log(data);
                    bootbox.alert("<h4>Failed to place your order!</h4>", function () { });
                }

                $('#updateStatus').html('');
            },
            error: function (xhr) {
                console.log(xhr);
                hideLoader();
                $("#rest-order-loader").hide();
                $('#updateStatus').html('');
                bootbox.alert("<h4>Error occured while placing your order!</h4>", function () { });
            }
        });

    });

    function proceedToCardPayment(orderId, orderCode, amount) {

        $.ajax({
            dataType: "json",
            url: '/Customer/CardPayment',
            type: 'POST',
            data: { orderId: orderId, orderCode: orderCode, amount: amount },
            success: function (data) {
                if (data.isSuccess) {

                    var stripeKey = getStripeKey();
                    var stripe = Stripe(stripeKey);

                    stripe.redirectToCheckout({
                        sessionId: data.sessionId
                    }).then(function (result) {
                        bootbox.alert("<h4>" + result.error.message + "</h4>", function () { });
                    });

                }
                else {
                    hideLoader();
                    bootbox.alert("<h4>Failed to initiate your order!</h4>", function () { });
                }
            },
            error: function (xhr) {
                hideLoader();
                bootbox.alert("<h4>Error occured while initiating your order!</h4>", function () { });
            }
        });
    }
    $("#shippingAmount").on("keyup", function () {


        let shippingAmount = +$(this).val();

        $(".checkout-shippingAmount").html(siteCurrency() + shippingAmount);

        let grandTotal = +$("#grandTotal").val();
        $(".checkout-grandTotal").html(siteCurrency() + (grandTotal + shippingAmount).toFixed(2));

    })
    $('#btnPlaceOrder').click(function () {

        let orderMode = localStorage.getItem("OrderType");

        let wholesaleCustomer = $("#wholesale-customer").val()
        if (orderMode == "Wholesale") {
            if (wholesaleCustomer == "0") {
                bootbox.alert("<h4>Please Select Wholesale Customer!</h4>");
                return;
            }
        }


        var userStatus = getUserStatus();
        if (!userStatus.isLoggedIn) {
            window.location.href = '/Security/Login/?returnUrl=/cart';
            return;
        }

        var paymentType = getPaymentType();//isCodPayment();
        if (paymentType != "Online") {
            $('#btnConfirmOrder').html('Confirm Order');
        }
        else {
            $('#btnConfirmOrder').html('Confirm Order & Proceed to Pay');
        }

        $('#div-confirm-order').show();
        $('#div-place-order').hide();

    });

    $('#btnBack,#btnEditAddr').click(function () {
        $('#div-place-order').show();
        $('#div-confirm-order').hide();
    });

    $("#city").on("change", function () {
        let postcode = $('option:selected', this).attr('postcode');
        $("#zip").val(postcode);
        let shippingAmount = +$('option:selected', this).attr('shipping-charges');
        $("#shippingAmount").val(shippingAmount);

        if (/*$("#order-type-shopping-cart").val()*/
            localStorage.getItem("OrderType") != "Purchase") {


            $(".checkout-shippingAmount").html(siteCurrency() + shippingAmount);

            let grandTotal = +$("#grandTotal").val();

            $(".checkout-grandTotal").html(siteCurrency() + (grandTotal + shippingAmount));
        }

    })


    $('#btnUpdateAddress').click(function () {

        $('#updateStatus').html('Updating your address...');

        var mobile = $('#mobile').val();
        var firstName = $('#firstName').val();
        var lastName = $('#lastName').val();
        var address = $('#address').val();
        var zipCode = $('#zip').val();
        var city = $('#city').val();
        var state = $('#state').val();
        var country = $('#country').val();
        var email = $("#email").val();
        if (!zipCode) {
            bootbox.alert("<h4>Please enter zipcode!</h4>", function () { });
            return;
        }
        else if (!state) {
            bootbox.alert("<h4>Please enter prefecture!</h4>", function () { });
            return;
        }
        else if (!city) {
            bootbox.alert("<h4>Please enter city!</h4>", function () { });
            return;
        }
        else if (!firstName) {
            bootbox.alert("<h4>Please enter your name!</h4>", function () { });
            return;
        }

        $.ajax({
            dataType: "json",
            url: '/Account/UpdateUserAddress',
            data: { mobile: mobile, firstName: firstName, lastName: lastName, address: address, zipCode: zipCode, city: city, state: state, country: country, email: email },
            method: 'POST',
            success: function (data) {
                if (data.isSuccess) {

                    // Show in confirm order section
                    $('#showFirstName').html(firstName);
                    $('#showMobile').html(mobile);
                    $('#showAddress').html(address);
                    $('#showZipCode').html(zipCode);
                    $('#showCity').html(city);
                    $('#showState').html(state);

                    bootbox.alert("<h4>Your address has been updated sucessfully!</h4>", function () { });
                }
                else {
                    if (data.message) {
                        bootbox.alert("<h4>" + data.message + "</h4>", function () { });
                    }
                    else {
                        bootbox.alert("<h4>Failed to update!</h4>", function () { });
                    }
                }

                $('#updateStatus').html('');
            },
            error: function (xhr) {
                $('#updateStatus').html('');
                bootbox.alert("<h4>Error occured while updating your address!</h4>", function () { });
            }
        });
    });

    $('#btn-apply-coupon').click(function () {

        let coupon = $("#coupon").val();
        if (coupon == "" || coupon == undefined || coupon == null) {
            bootbox.alert("<h4>Please add coupon!</h4>", function () { });
            return;
        }

        $.ajax({
            dataType: "json",
            url: '/Product/GetCouponDiscount',
            data: { coupon: coupon },
            method: 'POST',
            success: function (data) {


                if (data.IsSuccess) {

                    let subTotal = $("#btn-apply-coupon").attr('checkout-grandTotal');
                    let shippingAmount = +$("#shippingAmount").val();
                    let discount = (subTotal * data.Value) / 100;
                    let grandTotal = subTotal - discount + shippingAmount;

                    $(".discount").html(siteCurrency() + discount);
                    $("#discount").val(discount);
                    $(".checkout-grandTotal").html(siteCurrency() + grandTotal);

                    bootbox.alert("<h4>Coupon added sucessful!</h4>", function () { });
                }
                else {
                    if (data.message) {
                        bootbox.alert("<h4>" + data.message + "</h4>", function () { });
                    }
                    else {
                        bootbox.alert("<h4>Failed to update!</h4>", function () { });
                    }
                }

                $('#updateStatus').html('');
            },
            error: function (xhr) {
                $('#updateStatus').html('');
                bootbox.alert("<h4>Error occured while updating your address!</h4>", function () { });
            }
        });

    });
});



// Get user information
function getUserInformation() {

    var isLoggedIn = false;
    var userStatus = getUserStatus();
    if (userStatus.isLoggedIn) {
        isLoggedIn = true;
    }

    if (isLoggedIn) {
        $('.item-loading').show();
        $.ajax({
            dataType: "json",
            url: '/City/GetCities',
            success: function (data) {
                if (data) {
                    let html = "";
                    html += "<option value='0'>Select City</option>";
                    for (let i = 0; i < data.length; i++) {
                        html += "<option value='" + data[i].Name + "' postcode='" + data[i].Postcode + "' name='" + data[i].Postcode + "' shipping-charges='" + data[i].ShippingCharge + "'>" + data[i].Name + " </option>";
                    }

                    $("#city").html(html);


                    $.ajax({
                        dataType: "json",
                        url: '/Account/GetLoggedInUserAddress',
                        success: function (data) {
                            $('.item-loading').hide();
                            if (data) {
                                if (data.IsAdmin) {

                                    $(".wholesale").removeClass('hide');
                                    $("#shippingAmount").removeClass('hide');
                                    $(".checkout-shippingAmount").addClass('hide');

                                    let orderType = localStorage.getItem("OrderType");

                                    let grandTotal = +$('#grandTotal').val();
                                    let shippingCharges = +$("#shippingAmount").val();

                                    let newGrandTotal = grandTotal;

                                    if (orderType == 'Wholesale') {
                                        //$("#cart-text").text("Shopping Cart - " + orderType + " Order");
                                        $("#wholesale-customer-div").removeClass('hide');//addClass("d-none");
                                        $("#purchase-supplier-div").addClass('hide');
                                        $("#btnPlaceOrder").removeClass('hide');
                                        $("#btnPurchaseOrder").addClass('hide');
                                        $(".p-order").removeClass('hide');
                                        newGrandTotal = grandTotal + shippingCharges;
                                    }
                                    else if (orderType == 'Purchase') {
                                        //$("#cart-text").text("Shopping Cart - " + orderType + " Order");
                                        $("#wholesale-customer-div").addClass('hide');//remvoeClass("d-none");
                                        $("#purchase-supplier-div").removeClass('hide');
                                        $("#btnPlaceOrder").addClass('hide');
                                        $("#btnPurchaseOrder").removeClass('hide');
                                        $(".p-order").addClass('hide');
                                        //$("#shippingAmount").val(0);
                                        $("#btnUpdateAddress").addClass('hide');

                                    } else {
                                        /*$("#cart-text").text("Shopping Cart - Online Order");*/
                                        $("#wholesale-customer-div").addClass('hide');//remvoeClass("d-none");
                                        $("#purchase-supplier-div").addClass('hide');

                                        $("#btnPlaceOrder").removeClass('hide');
                                        $("#btnPurchaseOrder").addClass('hide');
                                        $(".p-order").removeClass('hide');
                                        newGrandTotal = grandTotal + shippingCharges;
                                    }
                                    $(".checkout-grandTotal").html(siteCurrency() + newGrandTotal);


                                } else {
                                    $("#btnCompleteRestOrder").hide();
                                    $("#btnClearCart").show();
                                    $("#btnCompleteRestOrder").show();
                                }


                                $('#firstName').val(data.FirstName);
                                $('#mobile').val(data.Mobile);
                                $('#address').val(data.ShipAddress);
                                $('#zip').val(data.ShipZipCode);
                                $('#city').val(data.ShipCity);
                                $('#state').val(data.ShipState);
                                $('#email').val(data.Email);

                                // Show in confirm order section
                                $('#showFirstName').html(data.FirstName);
                                $('#showMobile').html(data.Username);
                                $('#showAddress').html(data.ShipAddress);
                                $('#showZipCode').html(data.ShipZipCode);
                                $('#showCity').html(data.ShipCity);
                                $('#showState').html(data.ShipState);

                                $(".checkout-shippingAmount").html(siteCurrency() + $('option:selected', "#city").attr('shipping-charges'));
                                $("#shippingAmount").val($('option:selected', "#city").attr('shipping-charges'));
                                builtShoppingCartItems();
                                confirmOrderList();
                            }
                        },
                        error: function (xhr) {
                            $('.item-loading').hide();
                        }
                    });


                    $.ajax({
                        dataType: "json",
                        url: '/Admin/GetWholesaleCustomerList',
                        data: {},
                        success: function (recordSet) {
                            let html = "";

                            html += "<option value='0'>Select Customer</option>";
                            for (let i = 0; i < recordSet.length; i++) {
                                html += "<option value='" + recordSet[i].Id + "' mobile=" + recordSet[i].Mobile + " country='" + recordSet[i].ShipCountry + "' postal-code='" + recordSet[i].ShipZipCode + "' address=" + recordSet[i].ShipAddress + " name=" + recordSet[i].FirstName + " city='" + recordSet[i].ShipCity + "'>" + recordSet[i].FirstName + " </option>";
                            }

                            $("#wholesale-customer").html(html);

                        },
                        error: function (xhr) {
                            $('.item-loading').hide();
                        }
                    });
                    $.ajax({
                        dataType: "json",
                        url: '/Supplier/GetSupplierList',
                        data: {},
                        success: function (recordSet) {
                            let html = "";

                            html += "<option value='0'>Select Supplier</option>";
                            for (let i = 0; i < recordSet.length; i++) {
                                html += "<option value='" + recordSet[i].Id + "' mobile=" + recordSet[i].Mobile + " country='" + recordSet[i].State + "' postal-code='" + recordSet[i].Postcode + "' address=" + recordSet[i].Address + " name=" + recordSet[i].Name + " city='" + recordSet[i].City + "'>" + recordSet[i].Name + " </option>";
                            }

                            $("#purchase-supplier").html(html);

                        },
                        error: function (xhr) {
                            $('.item-loading').hide();
                        }
                    });

                    $.ajax({
                        dataType: "json",
                        url: '/RestaurantTables/GetRestaurantTables',
                        data: {},
                        success: function (recordSet) {
                            let html = "";
                            $('.grid-item', '#homepage-container-table').remove();
                            //html += "<option value='0'>Select Customer</option>";
                            for (let i = 0; i < recordSet.length; i++) {
                                //html += '<div class="form-group">';
                                //html += '<input type="checkbox" id="_table' + recordSet[i].Id + '" name="vehicle1" value="' + recordSet[i].Id + '">';
                                //html += '<label for="_table' + recordSet[i].Id + '">' + recordSet[i].TableNumber + '</label></div><br>';
                                //html += "<option value='" + recordSet[i].Id + "' mobile=" + recordSet[i].Mobile + " country='" + recordSet[i].ShipCountry + "' postal-code='" + recordSet[i].ShipZipCode + "' address=" + recordSet[i].ShipAddress + " name=" + recordSet[i].FirstName + " city='" + recordSet[i].ShipCity + "'>" + recordSet[i].FirstName + " </option>";

                                //new code
                                //html += '<label class="checkbox-container " ' + (recordSet[i].IsOccupied ? " disabled style=';'" : "") + ' >'
                                //    + '<div class="row"><div class="col-sm-8" ' + (recordSet[i].IsOccupied ? " disabled style='background-color:gold;'" : "") + ' >' + recordSet[i].TableNumber + '</div>'
                                //    + '<div class="col-sm-4"> <img alt="" style="width:90px;" src="' + recordSet[i].ImageUrl + '" /> </div></div>'
                                //    + '<input class="_tables" ' + (recordSet[i].IsOccupied ? "disabled style='color:red'" : "") + ' type="checkbox" value="' + recordSet[i].Id + '" id="_table' + recordSet[i].Id + '">'
                                //    + '<span class="checkmark" ' + (recordSet[i].IsOccupied ? "checked" : "") + ' data-id="' + recordSet[i].Id + '" ></span >'
                                //    + '</label >';


                                //html += '<div class="grid-item"> ' +
                                //    '<div class="div-item-container clearfix">' +
                                //    //'<a class="item-link-container clearfix" href="/Product/Details?id=' + productList[i].Id + '"> ' +
                                //    '<div class="grid-item-image img-hr-info"> ' +
                                //    '<img src="' + recordSet[i].ImageUrl + '" /> ' +
                                //    '</div> ' +
                                //    '<div class="grid-item-info product-hr-info"> ' +
                                //    '<span class="h-p-title center">' + recordSet[i].TableNumber + '</span> ' +
                                //    '<div class="center"> ' +
                                //    //'<span class="old-price">' + productList[i].PriceTextOld + '</span>' + '<span class="h-p-price">' + productList[i].PriceText + '</span>' +
                                //    '</div> ' +
                                //    '<div class="center"> ' +

                                //    //'<div class="btn-qty-container">' +
                                //    //'<button ' + minus_attr + ' class="btn-minus btn btn-default">-</button>' +
                                //    //'<input ' + qty_attr + ' type="text" value="1" class="txtQty form-control" style="    background-color: #ebebeb !important;"> ' +
                                //    //'<button ' + plus_attr + ' class="btn-plus btn btn-default">+</button>' +
                                //    //'</div>' +

                                //    //'<div class="item-basket">' +
                                //    //'<img ' + addToCartAttr + ' class="h-cart home-add-to-cart" title="Add to cart" src="/images/basket.png" style="float:right;" />' +
                                //    //'</div>' +

                                //    '</div> ' +
                                //    '</div> ' +
                                //    //'</a> ' +
                                //    '</div>' +
                                //    '</div> '


                                $('#homepage-container-table').append(
                                    '<div class="grid-item ' + (recordSet[i].IsOccupied ? '' : 'tables-click') + '" data-id="' + recordSet[i].TableNumber + '" style="width:19%;"> ' +
                                    '<div class="div-item-container">' +
                                    //'<a class="item-link-container" href="' + link + '"> ' +
                                    '<div class="grid-item-image"> ' +
                                    '<img src="/TableImages/Grid/' + recordSet[i].ImageUrl + '" /> ' +
                                    '</div> ' +
                                    '<div class="grid-item-info" style=" margin-top: 20px; "> ' +

                                    '<label class="checkbox-container" >'
                                    + '<span ' + (recordSet[i].IsOccupied ? 'style="color:red;"' : '') + '> ' + recordSet[i].TableNumber + (recordSet[i].IsOccupied ? ' - Occupied' : '') + '</span>'
                                    //+ '<div class="col-sm-4"> <img alt="" style="width:90px;" src="' + recordSet[i].ImageUrl + '" /> </div></div>'
                                    + '<input class="_tables" type="checkbox" value="' + recordSet[i].TableNumber + '" id="_table' + recordSet[i].TableNumber + '">'
                                    + '<span class="checkmark" data-id="' + recordSet[i].TableNumber + '" ></span >'
                                    + '</label >' +

                                    //'<span class="h-p-title center">' + recordSet[i].TableNumber + '</span> ' +
                                    '<div class="center"> ' +
                                    //'<span class="old-price">' + productList[i].PriceTextOld + '</span>' + '<span class="h-p-price">' + productList[i].PriceText + '</span>' +
                                    '</div> ' +
                                    '<div class="center"> ' +

                                    //'<div class="btn-qty-container">' +
                                    //'<button ' + minus_attr + ' class="btn-minus btn btn-default">-</button>' +
                                    //'<input ' + qty_attr + ' type="text" value="1" class="txtQty form-control" style="    background-color: #ebebeb !important;"> ' +
                                    //'<button ' + plus_attr + ' class="btn-plus btn btn-default">+</button>' +
                                    //'</div>' +

                                    //'<div class="item-basket">' +
                                    //'<img ' + addToCartAttr + ' class="h-cart home-add-to-cart" title="Add to cart" src="/images/basket.png" style="float:right;" />' +
                                    //'</div>' +

                                    '</div> ' +
                                    '</div> ' +
                                    //'</a> ' +
                                    '</div>' +
                                    '</div> ');



                            }

                            $("#_tableNumbers").html(html);

                        },
                        error: function (xhr) {
                            $('.item-loading').hide();
                        }
                    });

                }
            },
            error: function (xhr) {
                $('.item-loading').hide();
            }
        });

    }
    else {
        builtShoppingCartItems();
        confirmOrderList();
        $('.customer-address').hide();
    }
}

function builtShoppingCartItems() {


    var userStatus = getUserStatus();


    var subTotal = 0;
    var vatAmount = 0;
    var shippingAmount = getShippingCharge();
    var grandTotal = 0;

    var cart = getCart();

    var html = '<table class="tbl-shopping-cart-items">';

    html += '<tr class="shopping-cart-header">';
    html += '<td>Image</td>';
    html += '<td>Name</td>';
    //html += '<td>Option</td>';
    html += '<td>Description</td>';
    html += '<td class="center">Price</td>';
    html += '<td class="center">Qty</td>';
    html += '<td class="center">Discount</td>';
    html += '<td class="center">Total</td>';
    html += '<td class="center">Gst</td>';
    //if (userStatus.isLoggedIn) {
    html += '<td class="center">Remove</td>';
    //}
    html += '</tr>';

    for (var i = 0; i < cart.length; i++) {

        var itemTotal = (parseFloat(cart[i].OnlinePrice - cart[i].Discount, 10) * parseInt(cart[i].Quantity, 10));
        var quantityInputBoxId = 'txtQty_' + cart[i].Id + '_' + i;
        var descriptionInputBoxId = 'txtDescription_' + cart[i].Id + '_' + i;

        let isExist = false;
        let productIds = window.localStorage.getItem("productIds");
        if (productIds != null && productIds != '') {
            productIds = productIds.split(",");

            if (productIds.find((element) => element == cart[i].Id)) {
                isExist = true;
            }
        }




        html += '<tr>';

        html += '<td>';
        html += '<img src="' + cart[i].ImageUrl + '" />';
        html += '</td>';

        html += '<td ' + (isExist ? 'style=" background-color: bisque; "' : '') + '>';
        //html += '<a href="/Product/Details?id=' + cart[i].Id + '">' + cart[i].Name + '</a>';
        html += '<a">' + cart[i].Name + '</a>';
        html += '</td>';

        //html += '<td class="center">';
        //html += '<span>' + cart[i].Option + '</span>';
        //html += '</td>';

        html += '<td>';
        html += '<input type="text" class="form-control" style="width:100%;" value="' + cart[i].Description + '" id="' + descriptionInputBoxId + '" />';
        html += '</td>';

        html += '<td class="center">';
        html += '<span>' + siteCurrency() + cart[i].OnlinePrice + '</span>';
        html += '</td>';

        if (userStatus.isLoggedIn) {
            html += '<td>';
            html += '<input type="number" class="font-control" style="width:50px; text-align:center;" value="' + cart[i].Quantity + '" id="' + quantityInputBoxId + '" />';
            html += '</td>';
        } else {
            html += '<td>';
            html += '<input type="number" class="font-control" style="width:50px; text-align:center;" value="' + cart[i].Quantity + '" id="' + quantityInputBoxId + '" />';
            html += '</td>';
        }


        html += '<td class="center">';
        html += '<span>' + siteCurrency() + (cart[i].Discount * cart[i].Quantity).toFixed(2) + '</span>';
        html += '</td>';

        html += '<td class="center">';
        html += '<span>' + siteCurrency() + itemTotal.toFixed(2) + '</span>';
        html += '</td>';


        html += '<td class="center">';
        html += '<span>' + calculateGst(itemTotal, cart[i].Gst) + '</span>';
        html += '</td>';
        //if (userStatus.isLoggedIn) {
        html += '<td class="center">';
        html += '<img id="' + cart[i].Id + '" class="delete-shopping-cart-item img-cart" src="/Images/cross.png" style="cursor:pointer;">';
        html += '</td>';
        //}
        //else {
        //    html += '<td class="center">';
        //    html += '<img id="' + cart[i].Id + '" disabled class="delete-shopping-cart-item img-cart" src="/Images/cross.png" style="cursor:pointer;">';
        //    html += '</td>';
        //}


        html += '</tr>';
    }

    html += '</table>';

    // Getting summary calculated amount
    var obj = getSummaryAmount();
    subTotal = obj.subTotal;
    vatAmount = obj.vatAmount;
    shippingAmount = +$("#shippingAmount").val();
    grandTotal = obj.grandTotal.toFixed(2);

    $("#btn-apply-coupon").attr("checkout-grandTotal", grandTotal);

    $('#checkout-subTotal').html(siteCurrency() + subTotal.toFixed(2));
    //$('#vatPerc').html('(' + getVatPercentage() + '%)');
    $('#vatPerc').html('');
    $('#checkout-vatAmount').html(siteCurrency() + vatAmount);
    $('.checkout-shippingAmount').html(siteCurrency() + shippingAmount.toFixed(2));
    $('.checkout-grandTotal').html(siteCurrency() + (+grandTotal + shippingAmount).toFixed(2));
    $("#grandTotal").val(grandTotal);
    $('.shopping-cart-container').html(html);

    $("#div-place-order").show();

}

function calculateGst(totalAmount, gst) {
    return ((totalAmount * gst) / 100).toFixed(2);
}

function confirmOrderList() {

    var subTotal = 0;
    var vatAmount = 0;
    var shippingAmount = getShippingCharge();
    var grandTotal = 0;
    var totalQuantity = 0

    var cart = getCart();

    var html = '<table class="tbl-shopping-cart-items">';

    html += '<tr class="shopping-cart-header">';
    html += '<td>SL</td>';
    html += '<td>Image</td>';
    html += '<td class="left">Name</td>';
    html += '<td class="center">Price</td>';
    html += '<td class="center">Qty</td>';
    html += '<td class="center">GST</td>';
    html += '<td class="right">Total</td>';
    html += '</tr>';

    for (var i = 0; i < cart.length; i++) {

        var itemTotal = (parseFloat(cart[i].OnlinePrice, 10) * parseInt(cart[i].Quantity, 10));

        html += '<tr>';

        html += '<td>';
        html += '<span>' + (i + 1) + '</span>';
        html += '</td>';

        html += '<td>';
        html += '<img src="' + cart[i].ImageUrl + '" class="img-cart" />';
        html += '</td>';

        html += '<td class="left">';
        html += '<a href="/Product/Details?id=' + cart[i].Id + '">' + cart[i].Name + '</a>';
        html += '</td>';

        html += '<td class="center">';
        html += '<span>' + siteCurrency() + cart[i].OnlinePrice + '</span>';
        html += '</td>';

        html += '<td>';
        html += '<span>' + cart[i].Quantity + '</span>';
        html += '</td>';

        html += '<td>';
        html += '<span>' + calculateGst(itemTotal, cart[i].Gst) + '</span>';
        html += '</td>';

        html += '<td class="right">';
        html += '<span>' + siteCurrency() + itemTotal.toFixed(2) + '</span>';
        html += '</td>';

        html += '</tr>';
    }

    // Getting summary calculated amount
    var obj = getSummaryAmount();
    subTotal = obj.subTotal;
    vatAmount = obj.vatAmount;
    shippingAmount = +$("#shippingAmount").val();
    grandTotal = (obj.grandTotal + shippingAmount).toFixed(2);
    totalQuantity = obj.totalQuantity;

    // Summary row
    html += '<tr class="summary-row right">';

    html += '<td colspan="6">';
    html += '<span style="float:right;">Sub Total (' + totalQuantity + ' items):</span>';
    html += '</td>';

    html += '<td class="right">';
    html += '<span>' + siteCurrency() + subTotal.toFixed(2) + '</span>';
    html += '</td>';

    html += '</tr>';

    // Vat amount row    
    html += '<tr class="summary-row">';

    html += '<td colspan="6">';
    //html += '<span style="float:right;">Vat (' + getVatPercentage() + '%):</span>';
    html += '<span style="float:right;">Total Gst:</span>';
    html += '</td>';

    html += '<td class="right">';
    html += '<span>' + siteCurrency() + vatAmount + '</span>';
    html += '</td>';

    html += '</tr>';

    // Discount row
    html += '<tr class="summary-row">';

    html += '<td colspan="6">';
    html += '<span style="float:right;">Discount:</span>';
    html += '</td>';

    html += '<td class="right">';
    html += '<span class="discount">' + siteCurrency() + 0 + '</span>';
    html += '</td>';

    html += '</tr>';

    // Shipping amount row
    html += '<tr class="summary-row /*shipping-cost"*/>';

    html += '<td colspan="6">';
    html += '<span style="float:right;">Shipping Cost:</span>';
    html += '</td>';

    html += '<td class="right">';
    html += '<span class="checkout-shippingAmount">' + siteCurrency() + (+$("#shippingAmount").val()).toFixed(2) + '</span>';
    html += '</td>';

    html += '</tr>';

    // Grand total row
    html += '<tr class="summary-row grand-total">';

    html += '<td colspan="6">';
    html += '<span style="float:right;">Grand Total:</span>';
    html += '</td>';

    html += '<td class="right">';
    html += '<span class="checkout-grandTotal">' + siteCurrency() + grandTotal + '</span>';
    html += '</td>';

    html += '</tr>';

    // Shipping charge note
    html += '<tr class="summary-row shipping-cost-note">';
    html += '<td colspan="7">';
    html += '<span class="" style="float:right; font-weight:400;">Note: Shipping charge will be added based on location and weight</span>';
    html += '</td>';
    html += '</tr>';

    html += '</table>';

    $('#order-item-list').html(html);
}