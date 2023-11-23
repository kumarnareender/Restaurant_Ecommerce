$(document).ready(function () {

    $(".top-cat-menu-header").click(function () {
        if ($(".top-cat-menu-container").is(":visible") == true) {
            $('.top-cat-menu-container', this).fadeOut("fast");
        }
        else {
            $('.top-cat-menu-container', this).fadeIn("fast");
        }
    });

    $(".top-cat-menu-container").mouseleave(function () {
        if ($(".top-cat-menu-container").is(":visible") == true) {
            $('.top-cat-menu-container').fadeOut("fast");
        }
    });

});

// SERVICE CALL
app.factory('homePageService', [
    '$http', function ($http) {

        return {

            getHomepageCategoryItems: function () {
                return $http({
                    url: '/Home/GetHomepageCategoryItems',
                    method: 'GET',
                    async: true
                });
            },

            getCategoryWithImage: function () {
                return $http({
                    url: '/Home/GetCategoryWithImage',
                    method: 'GET',
                    async: true
                });
            },

            getHomePage_FeaturedItems: function () {
                return $http({
                    url: '/Home/GetHomePage_FeaturedItems',
                    method: 'GET',
                    async: true
                });
            },

            getHomePage_PopularItems: function () {
                return $http({
                    url: '/Home/GetHomePage_PopularItems',
                    method: 'GET',
                    async: true
                });
            },

            getHomePage_NewArrivals: function () {
                return $http({
                    url: '/Home/GetHomePage_NewArrivals',
                    method: 'GET',
                    async: true
                });
            },

            getCategoryList: function () {
                return $http({
                    url: '/Category/GetParentCategoryList',
                    method: 'GET',
                    async: true
                });
            },

            getSliderImageList: function () {
                return $http({
                    url: '/HomeSlider/GetSliderImageList',
                    method: 'GET',
                    async: true
                });
            }
        };
    }
]);

// CONTROLLER
app.controller('HomeCtrl', ['$rootScope', '$scope', '$http', '$filter', '$location', 'Enum', 'homePageService', function ($rootScope, $scope, $http, $filter, $location, Enum, homePageService) {

    var tableNumber = getParam('tableNumber');
    if (tableNumber != null && tableNumber != "" && tableNumber != undefined) {
        localStorage.setItem("tableNumber", tableNumber);
        localStorage.setItem("isItemGotForCart", "");
    }

    loadSliderImageList();

    renderLeftCategories();

    renderCategoryImages();

    renderHomepageCategoryItems();

    renderNewArrivals();

    renderPopularItems();

    renderFeaturedItems();

    function renderHomepageCategoryItems() {

        homePageService.getHomepageCategoryItems()
            .success(function (itemList) {
                for (var i = 0; i < itemList.length; i++) {
                    var item = itemList[i];
                    LoadCategoryItemList(i, item.Title, item.ImageName, item.ProductList);
                }
            })
            .error(function (xhr) {

            });
    }

    function LoadCategoryItemList(counter, categoryName, categoryImageName, productList) {

        var containerId = 'homepage-item-container-' + counter;

        var html = '    <div class="container area-back"> ' +
            '<div class="category-info">' +
            '<a>' +
            '<img src="/photos/categories/' + categoryImageName + '" />' +
            '</a>' +
            '</div> ' +

            '<div class="homepage-section-container-slick clearfix product-info"> ' +
            '<div class="cat-title" style = "height:20px;"> ' +
            '<span> ' + categoryName + '</span> ' +
            '</div> ' +
            '<div id = "' + containerId + '" class="slider grid_popularItems"> ' +

            '</div> ' +
            '</div> ' +
            '</div> ';

        $('#category-wise-container').append('<br/>' + html + '<br/>');

        $('#' + containerId).html('');
        for (var i = 0; i < productList.length; i++) {

            var addToCartAttr = 'productId="' + productList[i].Id + '" name="' + productList[i].Title + '" price="' + productList[i].OnlinePrice + '" imageUrl="' + productList[i].PrimaryImageName + '"';

            var plus_attr = 'id="btnPlus_pi_' + productList[i].Id + '" productId="' + productList[i].Id + '"';
            var minus_attr = 'id="btnMinus_pi_' + productList[i].Id + '" productId="' + productList[i].Id + '"';
            var qty_attr = 'id="txtQty_pi_' + productList[i].Id + '" productId="' + productList[i].Id + '"';

            $('#' + containerId).append(
                '<div class="grid-item"> ' +
                '<div class="div-item-container clearfix">' +
                '<a class="item-link-container clearfix" href="/Product/Details?id=' + productList[i].Id + '"> ' +
                '<div class="grid-item-image img-hr-info"> ' +
                '<img src="' + productList[i].PrimaryImageName + '" /> ' +
                '</div> ' +
                '<div class="grid-item-info product-hr-info"> ' +
                '<span class="h-p-title center">' + productList[i].Title + '</span> ' +
                '<div class="center"> ' +
                '<span class="old-price">' + productList[i].PriceTextOld + '</span>' + '<span class="h-p-price">' + productList[i].PriceText + '</span>' +
                '</div> ' +
                '<div class="center"> ' +

                '<div class="btn-qty-container">' +
                '<button ' + minus_attr + ' class="btn-minus btn btn-default">-</button>' +
                '<input ' + qty_attr + ' type="text" value="1" class="txtQty form-control" style="    background-color: #ebebeb !important;"> ' +
                '<button ' + plus_attr + ' class="btn-plus btn btn-default">+</button>' +
                '</div>' +

                '<div class="item-basket">' +
                '<img ' + addToCartAttr + ' class="h-cart home-add-to-cart" title="Add to cart" src="/images/basket.png" style="float:right;" />' +
                '</div>' +

                '</div> ' +
                '</div> ' +
                '</a> ' +
                '</div>' +
                '</div> ');
        }

        $('#' + containerId).slick({
            rows: 2,
            slidesToShow: 2,
            slidesToScroll: 1,
            arrows: true,
            fade: false,
            speed: 300,
            responsive: [
                {
                    breakpoint: 1024,
                    settings: {
                        rows: 1,
                        slidesToShow: 2,
                        slidesToScroll: 1
                    }
                },
                {
                    breakpoint: 600,
                    settings: {
                        rows: 1,
                        slidesToShow: 2,
                        slidesToScroll: 1
                    }
                },
                {
                    breakpoint: 300,
                    settings: "unslick"
                }
            ]
        });
    }

    function loadSliderImageList() {
        homePageService.getSliderImageList()
            .success(function (data) {

                $('.hom-slider-loader').remove();

                for (var i = 0; i < data.length; i++) {
                    var image = data[i];
                    var imageSrc = '/Images/slider/' + image.ImageName + '?v=' + image.Id;
                    var html = '<a href="' + image.Url + '"><img src="' + imageSrc + '" style="height:350px;" /></a>';
                    $('.home-slider').append(html);
                }

                $('.home-slider').slick({
                    slidesToShow: 1,
                    slidesToScroll: 1,
                    dots: true,
                    arrows: false,
                    autoplay: true,
                    autoplaySpeed: 2000,
                    infinite: true,
                    focusOnSelect: true
                });

            })
            .error(function (xhr) {
            });
    };

    function renderLeftCategories() {

        homePageService.getCategoryList()
            .success(function (cats) {

                var html = '<ul>';
                for (var i = 0; i < cats.length; i++) {
                    html += '<li>' +
                        '<a style="display: block; position: relative;" href="/Product/Search?cat=' + cats[i].Id + '&catName=' + cats[i].Name + ' ">' + cats[i].Name + '</a>' + '<img src="/Images/right-arrow.png" style="height: 15px; margin-left: 5px; float:right; position:relative;top:-16px;">' +
                        '</li>';
                }

                html += '</ul>';
                $('#side-category').html(html);

                var htmlCatMenu = '<div class="row">';
                for (var i = 0; i < cats.length; i++) {

                    if (i === 0) {
                        htmlCatMenu += '<div class="col-md-4">';
                    }
                    else if (i === 10) {
                        htmlCatMenu += '<div class="col-md-4">';
                    }
                    else if (i === 20) {
                        htmlCatMenu += '<div class="col-md-4">';
                    }

                    htmlCatMenu += '<div style="padding:2px;"><a href="/Product/Search?cat=' + cats[i].Id + '">' + cats[i].Name + '</a></div>';

                    if (i === 9) {
                        htmlCatMenu += '</div>';
                    }
                    else if (i === 19) {
                        htmlCatMenu += '</div>';
                    }
                    else if (i === 29) {
                        htmlCatMenu += '</div>';
                    }
                }

                htmlCatMenu += '</div>';

                $('.top-cat-menu-container').html(htmlCatMenu);
            })
            .error(function (xhr) {

            });

        // Slim scroll
        $(".slim-scroll").slimScroll({
            size: '8px',
            width: '100%',
            height: '100%',
            color: '#ff4800',
            allowPageScroll: true,
            alwaysVisible: false
        });
    }

    function renderCategoryImages() {

        homePageService.getCategoryWithImage()
            .success(function (catList) {

                $('#homepage-category-image').html('');
                for (var i = 0; i < catList.length; i++) {

                    $('#homepage-category-image').append(
                        '<div class="grid-item"> ' +
                        '<div class="div-item-container">' +
                        '<a class="item-link-container" href="/Product/Search?cat=' + catList[i].CategoryId + '"> ' +
                        '<div class="grid-item-image"> ' +
                        '<img src="/photos/categories/' + catList[i].ImageName + '" /> ' +
                        '</div> ' +
                        '<div class="grid-item-info"> ' +
                        '<span class="h-p-title center">' + catList[i].Title + '</span> ' +
                        '</div> ' +
                        '</a> ' +
                        '</div>' +
                        '</div>');
                }

                $('#homepage-category-image').slick({
                    slidesToShow: 6,
                    slidesToScroll: 1,
                    dots: true,
                    arrows: false,
                    fade: false,
                    speed: 300,
                    responsive: [
                        {
                            breakpoint: 1024,
                            settings: {
                                slidesToShow: 4,
                                slidesToScroll: 1
                            }
                        },
                        {
                            breakpoint: 600,
                            settings: {
                                slidesToShow: 2,
                                slidesToScroll: 1
                            }
                        },
                        {
                            breakpoint: 300,
                            settings: "unslick"
                        }
                    ]
                });
            })
            .error(function (xhr) {

            });
    }

    function renderPopularItems() {

        homePageService.getHomePage_PopularItems()
            .success(function (productList) {

                $('#homepage-container-popular').html('');
                for (var i = 0; i < productList.length; i++) {

                    var addToCartAttr = 'is-size-color-availabe="' + productList[i].IsSizeColorAvailable + '" productId="' + productList[i].Id + '" name="' + productList[i].Title + '" price="' + productList[i].OnlinePrice + '" is-gst="' + productList[i].Gst + '" imageUrl="' + productList[i].PrimaryImageName + '"';

                    var plus_attr = 'id="btnPlus_pi_' + productList[i].Id + '" productId="' + productList[i].Id + '"';
                    var minus_attr = 'id="btnMinus_pi_' + productList[i].Id + '" productId="' + productList[i].Id + '"';
                    var qty_attr = 'id="txtQty_pi_' + productList[i].Id + '" productId="' + productList[i].Id + '"';
                    //let link = productList[i].IsSizeColorAvailable ? '/Product/Details?id=' + productList[i].Id : "#";
                    let link = '/Product/Details?id=' + productList[i].Id;
                    $('#homepage-container-popular').append(
                        '<div class="grid-item"> ' +
                        '<div class="div-item-container clearfix">' +
                        '<a class="item-link-container clearfix" href="' + link + '"> ' +
                        '<div class="grid-item-image"> ' +
                        '<img src="' + productList[i].PrimaryImageName + '" /> ' +
                        '</div> ' +
                        '<div class="grid-item-info"> ' +
                        '<span class="h-p-title center">' + productList[i].Title + '</span> ' +
                        '<div class="center"> ' +
                        '<span class="old-price">' + productList[i].PriceTextOld + '</span>' + '<span class="h-p-price">' + productList[i].PriceText + '</span>' +
                        '</div> ' +
                        '<div class="center"> ' +

                        '<div class="btn-qty-container">' +
                        '<button ' + minus_attr + ' class="btn-minus btn btn-default">-</button>' +
                        '<input ' + qty_attr + ' type="text" value="1" class="txtQty form-control" style="    background-color: #ebebeb !important;"> ' +
                        '<button ' + plus_attr + ' class="btn-plus btn btn-default">+</button>' +
                        '</div>' +

                        '<div class="item-basket">' +
                        '<img ' + addToCartAttr + ' class="h-cart home-add-to-cart" title="Add to cart" src="/images/basket.png" style="float:right;" />' +
                        '</div>' +

                        '</div> ' +
                        '</div> ' +
                        '</a> ' +
                        '</div>' +
                        '</div> ');
                }

                $('#homepage-container-popular').slick({
                    slidesToShow: 6,
                    slidesToScroll: 1,
                    arrows: true,
                    fade: false,
                    speed: 300,
                    responsive: [
                        {
                            breakpoint: 1024,
                            settings: {
                                slidesToShow: 4,
                                slidesToScroll: 1
                            }
                        },
                        {
                            breakpoint: 600,
                            settings: {
                                slidesToShow: 2,
                                slidesToScroll: 1
                            }
                        },
                        {
                            breakpoint: 300,
                            settings: "unslick"
                        }
                    ]
                });
            })
            .error(function (xhr) {

            });
    }

    function renderNewArrivals() {

        homePageService.getHomePage_NewArrivals()
            .success(function (productList) {

                $('#homepage-container-newarrival').html('');
                for (var i = 0; i < productList.length; i++) {

                    var addToCartAttr = 'is-size-color-availabe="' + productList[i].IsSizeColorAvailable + '" productId="' + productList[i].Id + '" name="' + productList[i].Title + '" price="' + productList[i].OnlinePrice + '"  is-gst="' + productList[i].Gst + '"  imageUrl="' + productList[i].PrimaryImageName + '"';

                    var plus_attr = 'id="btnPlus_ms_' + productList[i].Id + '" productId="' + productList[i].Id + '"';
                    var minus_attr = 'id="btnMinus_ms_' + productList[i].Id + '" productId="' + productList[i].Id + '"';
                    var qty_attr = 'id="txtQty_ms_' + productList[i].Id + '" productId="' + productList[i].Id + '"';
                    //let link = productList[i].IsSizeColorAvailable ? '/Product/Details?id=' + productList[i].Id : "#";
                    let link = '/Product/Details?id=' + productList[i].Id;
                    $('#homepage-container-newarrival').append(
                        '<div class="grid-item"> ' +
                        '<div class="div-item-container">' +
                        '<a class="item-link-container" href="' + link + '"> ' +
                        '<div class="grid-item-image"> ' +
                        '<img src="' + productList[i].PrimaryImageName + '" /> ' +
                        '</div> ' +
                        '<div class="grid-item-info"> ' +
                        '<span class="h-p-title center">' + productList[i].Title + '</span> ' +
                        '<div class="center"> ' +
                        '<span class="old-price">' + productList[i].PriceTextOld + '</span>' + '<span class="h-p-price">' + productList[i].PriceText + '</span>' +
                        '</div> ' +
                        '<div class="center"> ' +

                        '<div class="btn-qty-container">' +
                        '<button ' + minus_attr + ' class="btn-minus btn btn-default">-</button>' +
                        '<input ' + qty_attr + ' type="text" value="1" class="txtQty form-control" style="    background-color: #ebebeb !important;"> ' +
                        '<button ' + plus_attr + ' class="btn-plus btn btn-default">+</button>' +
                        '</div>' +

                        '<div class="item-basket">' +
                        '<img ' + addToCartAttr + ' class="h-cart home-add-to-cart" title="Add to cart" src="/images/basket.png" style="float:right;" />' +
                        '</div>' +

                        '</div> ' +
                        '</div> ' +
                        '</a> ' +
                        '</div>' +
                        '</div> ');
                }

                $('#homepage-container-newarrival').slick({
                    slidesToShow: 6,
                    slidesToScroll: 1,
                    arrows: true,
                    fade: false,
                    speed: 300,
                    responsive: [
                        {
                            breakpoint: 1024,
                            settings: {
                                slidesToShow: 4,
                                slidesToScroll: 1
                            }
                        },
                        {
                            breakpoint: 600,
                            settings: {
                                slidesToShow: 2,
                                slidesToScroll: 1
                            }
                        },
                        {
                            breakpoint: 300,
                            settings: "unslick"
                        }
                    ]
                });
            })
            .error(function (xhr) {

            });
    }

    function renderFeaturedItems() {

        homePageService.getHomePage_FeaturedItems()
            .success(function (productList) {

                $('.grid-item', '#homepage-container-featured').remove();
                for (var i = 0; i < productList.length; i++) {


                    var addToCartAttr = 'is-size-color-availabe="' + productList[i].IsSizeColorAvailable + '" productId="' + productList[i].Id + '" name="' + productList[i].Title + '" price="' + productList[i].OnlinePrice + '"  is-gst="' + productList[i].Gst + '"  imageUrl="' + productList[i].PrimaryImageName + '"';

                    var plus_attr = 'id="btnPlus_fi_' + productList[i].Id + '" productId="' + productList[i].Id + '"';
                    var minus_attr = 'id="btnMinus_fi_' + productList[i].Id + '" productId="' + productList[i].Id + '"';
                    var qty_attr = 'id="txtQty_fi_' + productList[i].Id + '" productId="' + productList[i].Id + '"';
                    //let link = productList[i].IsSizeColorAvailable ? '/Product/Details?id=' + productList[i].Id : "#";
                    let link = '/Product/Details?id=' + productList[i].Id;
                    $('#homepage-container-featured').append(
                        '<div class="grid-item"> ' +
                        '<div class="div-item-container">' +
                        '<a class="item-link-container" href="' + link + '"> ' +
                        '<div class="grid-item-image"> ' +
                        '<img src="' + productList[i].PrimaryImageName + '" /> ' +
                        '</div> ' +
                        '<div class="grid-item-info"> ' +
                        '<span class="h-p-title center">' + productList[i].Title + '</span> ' +
                        '<div class="center"> ' +
                        '<span class="old-price">' + productList[i].PriceTextOld + '</span>' + '<span class="h-p-price">' + productList[i].PriceText + '</span>' +
                        '</div> ' +
                        '<div class="center"> ' +

                        '<div class="btn-qty-container">' +
                        '<button ' + minus_attr + ' class="btn-minus btn btn-default">-</button>' +
                        '<input ' + qty_attr + ' type="text" value="1" class="txtQty form-control" style="    background-color: #ebebeb !important;"> ' +
                        '<button ' + plus_attr + ' class="btn-plus btn btn-default">+</button>' +
                        '</div>' +

                        '<div class="item-basket">' +
                        '<img ' + addToCartAttr + ' class="h-cart home-add-to-cart" title="Add to cart" src="/images/basket.png" style="float:right;" />' +
                        '</div>' +

                        '</div> ' +
                        '</div> ' +
                        '</a> ' +
                        '</div>' +
                        '</div> ');

                }
            })
            .error(function (xhr) {

            });
    }

    $('#homepage-container-popular').on('click', '.home-add-to-cart', function (event) {

        var productId = $(this).attr('productId');
        let isSizeColorAvailable = $(this).attr("is-size-color-availabe");
        if (isSizeColorAvailable == 'true') {
            window.location.href = '/Product/Details?id=' + productId;
            return;
        }

        let orderType = localStorage.getItem("OrderType");
        if (orderType == null || orderType != "Online") {
            localStorage.removeItem("cart");
            localStorage.setItem("OrderType", "Online")
        } else {
            localStorage.setItem("OrderType", "Online");
        }

        var productId = $(this).attr('productId');
        var name = $(this).attr('name');
        var price = $(this).attr('price');
        var imageUrl = $(this).attr('imageUrl');
        var qty = $('#txtQty_pi_' + productId).val();
        var Gst = $(this).attr('is-gst');

        addToCart(productId, name, qty, price, imageUrl, Gst, 0);
        event.preventDefault();

        animateAddToCart(this);
    });

    $('#homepage-container-newarrival').on('click', '.home-add-to-cart', function (event) {

        var productId = $(this).attr('productId');
        let isSizeColorAvailable = $(this).attr("is-size-color-availabe");
        if (isSizeColorAvailable == 'true') {
            window.location.href = '/Product/Details?id=' + productId;
            return;
        }

        let orderType = localStorage.getItem("OrderType");
        if (orderType == null || orderType != "Online") {
            localStorage.removeItem("cart");
            localStorage.setItem("OrderType", "Online")
        } else {
            localStorage.setItem("OrderType", "Online");
        }

        var productId = $(this).attr('productId');
        var name = $(this).attr('name');
        var price = $(this).attr('price');
        var imageUrl = $(this).attr('imageUrl');
        var qty = $('#txtQty_ms_' + productId).val();
        var Gst = $(this).attr('is-gst');

        addToCart(productId, name, qty, price, imageUrl, Gst, 0);
        event.preventDefault();

        animateAddToCart(this);
    });

    $('#homepage-container-featured').on('click', '.home-add-to-cart', function (event) {

        var productId = $(this).attr('productId');
        let isSizeColorAvailable = $(this).attr("is-size-color-availabe");
        if (isSizeColorAvailable == 'true') {
            window.location.href = '/Product/Details?id=' + productId;
            return;
        }

        let orderType = localStorage.getItem("OrderType");
        if (orderType == null || orderType != "Online") {
            localStorage.removeItem("cart");
            localStorage.setItem("OrderType", "Online")
        } else {
            localStorage.setItem("OrderType", "Online");
        }


        var name = $(this).attr('name');
        var price = $(this).attr('price');
        var imageUrl = $(this).attr('imageUrl');
        var qty = $('#txtQty_fi_' + productId).val();
        var Gst = $(this).attr('is-gst');

        addToCart(productId, name, qty, price, imageUrl, Gst, 0);
        event.preventDefault();

        animateAddToCart(this);
    });

    $('#homepage-container-popular').on('click', '.btn-plus', function (event) {
        var productId = $(this).attr('productId');
        var qty = $('#txtQty_pi_' + productId).val();
        var newQty = parseInt(qty, 10) + 1;

        $('#txtQty_pi_' + productId).val(newQty);
        event.preventDefault();
    });

    $('#homepage-container-newarrival').on('click', '.btn-plus', function (event) {
        var productId = $(this).attr('productId');
        var qty = $('#txtQty_ms_' + productId).val();
        var newQty = parseInt(qty, 10) + 1;

        $('#txtQty_ms_' + productId).val(newQty);
        event.preventDefault();
    });

    $('#homepage-container-featured').on('click', '.btn-plus', function (event) {
        var productId = $(this).attr('productId');
        var qty = $('#txtQty_fi_' + productId).val();
        var newQty = parseInt(qty, 10) + 1;

        $('#txtQty_fi_' + productId).val(newQty);
        event.preventDefault();
    });

    $('#homepage-container-popular').on('click', '.btn-minus', function (event) {
        var productId = $(this).attr('productId');
        var qty = $('#txtQty_pi_' + productId).val();

        var newQty = parseInt(qty, 10) - 1;

        if (newQty >= 1) {
            $('#txtQty_pi_' + productId).val(newQty);
        }

        event.preventDefault();
    });

    $('#homepage-container-newarrival').on('click', '.btn-minus', function (event) {
        var productId = $(this).attr('productId');
        var qty = $('#txtQty_ms_' + productId).val();

        var newQty = parseInt(qty, 10) - 1;

        if (newQty >= 1) {
            $('#txtQty_ms_' + productId).val(newQty);
        }

        event.preventDefault();
    });

    $('#homepage-container-featured').on('click', '.btn-minus', function (event) {
        var productId = $(this).attr('productId');
        var qty = $('#txtQty_fi_' + productId).val();

        var newQty = parseInt(qty, 10) - 1;

        if (newQty >= 1) {
            $('#txtQty_fi_' + productId).val(newQty);
        }

        event.preventDefault();
    });

    $('#homepage-container-popular,#homepage-container-newarrival,#homepage-container-featured').on('click', '.txtQty', function (event) {
        event.preventDefault();
    });

}]);