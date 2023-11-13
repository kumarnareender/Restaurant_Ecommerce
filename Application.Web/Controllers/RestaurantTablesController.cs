using Application.Common;
using Application.Model.Models;
using Application.Service;
using Application.ViewModel;
using Application.Web.App_Code;
using Stripe;
using Stripe.Checkout;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.Mvc;

namespace Application.Controllers
{
    [Authorize]
    public class RestaurantTablesController : Controller
    {
        private IUserService userService;
        private IRoleService roleService;
        private IOrderService orderService;
        private IProductService productService;
        private readonly IBranchService branchService;
        private readonly IRestaurantTablesService restaurantTablesService;
        public RestaurantTablesController(IUserService userService, IOrderService orderService, IProductService productService, IRoleService roleService, IBranchService branchService, IRestaurantTablesService restaurantTables)
        {
            this.userService = userService;
            this.productService = productService;
            this.orderService = orderService;
            this.roleService = roleService;
            this.branchService = branchService;
            this.restaurantTablesService = restaurantTables;
        }

        public ActionResult Index()
        {
            return View();
        }

        public ActionResult AddRestTable()
        {
            return View();
        }

        public JsonResult CreateTable(RestaurantTable table)
        {
            bool isSuccess = true;
            try
            {
                this.restaurantTablesService.CreateRestTable(table);
            }
            catch (Exception exp)
            {
                isSuccess = false;
            }

            return Json(new Result { IsSuccess = isSuccess }, JsonRequestBehavior.AllowGet);
        }
        public JsonResult UpdateTable(RestaurantTable table)
        {
            bool isSuccess = true;
            try
            {
                this.restaurantTablesService.UpdateRestTable(table);
            }
            catch (Exception exp)
            {
                isSuccess = false;
            }

            return Json(new Result { IsSuccess = isSuccess }, JsonRequestBehavior.AllowGet);
        }

        public JsonResult DeleteTable(RestaurantTable table)
        {
            bool isSuccess = true;
            try
            {
                this.restaurantTablesService.DeleteRestTable(table);
            }
            catch (Exception exp)
            {
                isSuccess = false;
            }

            return Json(new Result { IsSuccess = isSuccess }, JsonRequestBehavior.AllowGet);
        }
        public string GetRestaurantTablesId(User userToSave)
        {
            string RestaurantTablesId = string.Empty;

            try
            {
                User user = userService.GetUserByPhone(userToSave.Username);
                if (user != null)
                {
                    RestaurantTablesId = user.Id;

                    user.FirstName = userToSave.FirstName;
                    user.LastName = userToSave.LastName;
                    user.ShipCountry = userToSave.ShipCountry;
                    user.ShipCity = userToSave.ShipCity;
                    user.ShipState = userToSave.ShipState;
                    user.ShipZipCode = userToSave.ShipZipCode;
                    user.ShipAddress = userToSave.ShipAddress;
                    user.Mobile = userToSave.Mobile;
                    user.Email = userToSave.Email;
                    userService.UpdateUserInfo(user);
                }
                else
                {
                    User newUser = new User();
                    RestaurantTablesId = Guid.NewGuid().ToString();

                    Role memberRole = roleService.GetRole(ERoleName.customer.ToString());

                    newUser.Id = RestaurantTablesId;
                    newUser.Username = userToSave.Username;
                    newUser.Password = userToSave.Username;
                    newUser.FirstName = userToSave.FirstName;
                    newUser.LastName = userToSave.LastName;
                    newUser.ShipCountry = userToSave.ShipCountry;
                    newUser.ShipCity = userToSave.ShipCity;
                    newUser.ShipState = userToSave.ShipState;
                    newUser.ShipZipCode = userToSave.ShipZipCode;
                    newUser.ShipAddress = userToSave.ShipAddress;
                    newUser.Mobile = userToSave.Mobile;
                    newUser.Email = userToSave.Email;
                    newUser.IsActive = true;
                    newUser.IsVerified = true;
                    newUser.IsDelete = false;
                    newUser.CreateDate = DateTime.Now;
                    newUser.Roles.Add(memberRole);

                    userService.CreateUser(newUser);
                }
            }
            catch
            {
                RestaurantTablesId = string.Empty;
            }

            return RestaurantTablesId;
        }

        [HttpPost]
        public JsonResult PlaceOrder(Model.Models.Order order)
        {
            //Model.Models.Order order = new Model.Models.Order();
            //return null;

            var table = restaurantTablesService.GetRestTable(order.TableNumber.Value);

            string branchName = Utils.GetSetting("CompanyName");
            Branch branch = branchService.GetBranchByName(branchName);
            order.BranchId = branch != null ? branch.Id : 4;
            string orderId = Guid.NewGuid().ToString();
            string orderCode = DateTime.Now.Ticks.ToString();
            order.OrderType = order.OrderType;
            order.OrderMode = "RestaurantOrder";
            order.TableNumber = table.TableNumber;


            bool isSuccess = false;
            try
            {
                string RestaurantTablesId = string.Empty;

                // nullify the user object
                order.User = null;

                order.Id = orderId;
                order.OrderCode = orderCode;
                order.UserId = Utils.GetLoggedInUserId();
                order.StatusId = 1;
                order.PaymentStatusId = 3;
                order.DueAmount = order.PayAmount;
                order.ActionDate = DateTime.Now;
                order.ActionBy = Utils.GetLoggedInUserName();
                foreach (Model.Models.OrderItem item in order.OrderItems)
                {
                    item.OrderId = orderId;
                    item.Id = Guid.NewGuid().ToString();
                    item.ActionDate = DateTime.Now;
                    item.CostPrice = item.Price;
                    //item.CostPrice = purchaseOrderService.price(item.ProductId);
                }
                if (!table.IsOccupied)
                {
                    table.OrderId = order.Id;
                    if (order.OrderType != "Save")
                    {
                        order.OrderStatus = EOrderStatus.Completed.ToString();
                        order.StatusId = 7;
                        order.PaymentStatus = EPaymentStatus.Paid.ToString();
                        order.PaymentStatusId = 1;

                    }
                    orderService.CreateOrder(order);
                }
                else
                {
                    var updateOrder = orderService.GetOrder(table.OrderId);


                    updateOrder.PayAmount = order.PayAmount;// - updateOrder.ShippingAmount;
                    updateOrder.DueAmount = order.DueAmount;
                    updateOrder.ShippingAmount = order.ShippingAmount;

                    foreach (var item in order.OrderItems)
                    {

                        var orderItem = updateOrder.OrderItems.FirstOrDefault(x => x.ProductId == item.ProductId);

                        if (orderItem != null)
                        {
                            orderItem.Quantity = item.Quantity;
                            orderItem.CostPrice = item.CostPrice;
                            orderItem.Discount = item.Discount;
                            orderItem.Price = item.Price;
                            orderItem.TotalPrice = orderItem.Quantity * orderItem.Price;

                        }
                        else
                        {
                            updateOrder.OrderItems.Add(item);
                        }

                    }

                    if (order.OrderType != "Save")
                    {
                        updateOrder.OrderStatus = EOrderStatus.Completed.ToString();
                        updateOrder.StatusId = 7;
                        order.PaymentStatus = EPaymentStatus.Paid.ToString();
                        updateOrder.PaymentStatusId = 1;

                    }


                    orderService.UpdateOrder(updateOrder);
                }

                isSuccess = true;


                table.IsOccupied = true;

                if (order.OrderType == "Save")
                {
                    restaurantTablesService.UpdateRestTable(table);
                }

                // Generate order barcode
                AppCommon.GenerateOrderBarcode(order.OrderCode);

            }
            catch (Exception ex)
            {
                string message = ex.Message;
                isSuccess = false;
            }

            return Json(new
            {
                isSuccess = isSuccess,
                orderId = orderId,
                orderCode = orderCode
            }, JsonRequestBehavior.AllowGet);
        }

        public JsonResult GetRestaurantTables()
        {
            List<RestaurantTable> restTables = null;
            try
            {
                string imageSrcPrefix = Utils.GetTableImageSrcPrefix() + "/Grid/";
                restTables = restaurantTablesService.GetRestTablesList();

                foreach (var item in restTables)
                {
                    item.ImageUrl = imageSrcPrefix + item.ImageUrl;
                }

            }
            catch (Exception ex)
            {
                var x = ex.Message;
            }
            return Json(restTables, JsonRequestBehavior.AllowGet);

        }


        public JsonResult GetOrderDetailsByTableNumber(int tableId)
        {
            OrderViewModel orderVM = new OrderViewModel();

            var table = restaurantTablesService.GetRestTable(tableId);

            if (table.IsOccupied)
            {
                Model.Models.Order order = orderService.GetOrder(table.OrderId);
                if (order != null)
                {
                    orderVM.Id = order.Id;
                    orderVM.UserId = order.UserId;
                    orderVM.BranchId = order.BranchId;
                    orderVM.OrderCode = order.OrderCode;
                    orderVM.OrderStatus = order.OrderStatus;
                    orderVM.OrderMode = order.OrderMode;
                    orderVM.PayAmount = order.PayAmount;
                    orderVM.Discount = order.Discount;
                    orderVM.Vat = order.Vat;
                    orderVM.ShippingAmount = order.ShippingAmount;
                    orderVM.DueAmount = order.DueAmount;
                    orderVM.ReceiveAmount = order.ReceiveAmount;
                    orderVM.ChangeAmount = order.ChangeAmount;
                    orderVM.TotalWeight = order.TotalWeight;
                    orderVM.DeliveryDate = order.DeliveryDate;
                    orderVM.DeliveryTime = order.DeliveryTime;
                    orderVM.IsFrozen = order.IsFrozen == null ? false : (bool)order.IsFrozen;
                    orderVM.ActionDate = order.ActionDate;
                    orderVM.OrderType = order.OrderType;
                    orderVM.StatusId = (int)order.StatusId;
                    orderVM.PaymentStatusId = order.PaymentStatusId;
                    orderVM.PaymentStatus = order.PaymentStatus;
                    orderVM.OrderItems = new List<ViewModel.OrderItemViewModel>();
                    foreach (Model.Models.OrderItem oi in order.OrderItems)
                    {
                        string title = oi.ProductId == Guid.Empty.ToString() ? oi.Title : oi.Product.Title;

                        OrderItemViewModel o = new ViewModel.OrderItemViewModel
                        {
                            Id = oi.Id,
                            ProductId = oi.ProductId,
                            ProductName = title,
                            Price = oi.Price,
                            Discount = oi.Discount,
                            Quantity = oi.Quantity,
                            CostPrice = oi.CostPrice == null ? oi.Price : (decimal)oi.CostPrice,
                            ImageUrl = string.IsNullOrEmpty(oi.ImageUrl) ? "/Images/no-image.png" : oi.ImageUrl,
                            ActionDate = oi.ActionDate,
                            Color = oi.Color,
                            Size = oi.Size
                        };
                        orderVM.OrderItems.Add(o);
                    }
                }
            }

            return Json(orderVM, JsonRequestBehavior.AllowGet);
        }

        private string SetStripeSession(string orderId, string orderCode, double amount)
        {
            amount = amount * 100;
            // Order currency
            string currency = Utils.GetConfigValue("StripeCurrency");

            // Stripe secret key
            string secretKey = Utils.GetConfigValue("StripeSecretKey");

            StripeConfiguration.ApiKey = secretKey;

            string scheme = System.Web.HttpContext.Current.Request.Url.Scheme;
            string hostName = System.Web.HttpContext.Current.Request.Url.Host;
            hostName += (hostName == "localhost") ? ":" + System.Web.HttpContext.Current.Request.Url.Port : "";

            string baseUrl = scheme + "://" + hostName;

            string keyInfo = orderId + "_" + orderCode + "_" + amount.ToString();

            // RestaurantTables name
            string RestaurantTablesName = string.Empty;
            User user = Utils.GetLoggedInUser();
            if (user != null)
            {
                RestaurantTablesName = user.FirstName + " " + user.LastName;
            }

            SessionCreateOptions options = new SessionCreateOptions
            {
                PaymentMethodTypes = new List<string> {
                    "card",
                },
                LineItems = new List<SessionLineItemOptions> {
                                new SessionLineItemOptions {
                                    Name = RestaurantTablesName,
                                    Description = "Online Payment",
                                    Amount = long.Parse(amount.ToString()),
                                    Currency = currency,
                                    Quantity = 1,
                                },
                            },
                SuccessUrl = baseUrl + "/RestaurantTables/PaymentSuccess_Stripe?keyInfo=" + keyInfo,
                CancelUrl = baseUrl + "/RestaurantTables/PaymentCancel_Stripe",
            };

            try
            {
                SessionService service = new SessionService();
                Session session = service.Create(options);
                return session.Id;
            }
            catch (Exception)
            {
                return string.Empty;
            }
        }

        public JsonResult CardPayment(string orderId, string orderCode, double amount)
        {
            bool isSuccess = true;
            string sessionId = string.Empty;

            try
            {
                sessionId = SetStripeSession(orderId, orderCode, amount);
            }
            catch (Exception)
            {
                isSuccess = false;
            }

            return Json(new
            {
                isSuccess = isSuccess,
                sessionId = sessionId
            }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult PaymentSuccess_Stripe(string keyInfo)
        {
            string orderId = string.Empty;
            string orderCode = string.Empty;
            string amount = string.Empty;

            string[] data = keyInfo.Split('_');
            if (data.Length == 3)
            {
                orderId = data[0];
                orderCode = data[1];
                amount = data[2];
            }

            // Update payment status to 'Done'
            orderService.OrderPaymentDone(orderId);

            // Redirect to confirmation page
            return RedirectToAction("OrderConfirm", "RestaurantTables", new { orderCode = orderCode });
        }

        public ActionResult PaymentCancel_Stripe()
        {
            return RedirectToAction("PaymentCancel", "RestaurantTables");
        }
    }
}