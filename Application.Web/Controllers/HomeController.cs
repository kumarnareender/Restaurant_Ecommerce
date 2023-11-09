using Application.Common;
using Application.Model.Models;
using Application.Service;
using Application.ViewModel;
using Application.Web;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Caching;
using System.Web.Mvc;


namespace Application.Controllers
{
    public class HomeController : Controller
    {
        private readonly IUserService userService;
        private ISettingService settingService;
        private readonly IProductService productService;
        private readonly IProductImageService productImageService;
        private ICategoryService categoryService;

        public HomeController(IUserService userService, IProductService productService, IProductImageService productImageService, ISettingService settingService, ICategoryService categoryService)
        {
            this.userService = userService;
            this.productService = productService;
            this.productImageService = productImageService;
            this.categoryService = categoryService;
            this.settingService = settingService;

            ReadSettingValues();
            
        }

        public ActionResult Index()
        {
            return View();
        }

        private void ReadSettingValues()
        {
            List<Setting> settingList = new List<Setting>();
            ObjectCache cache = MemoryCache.Default;
            if (!cache.Contains(ConstKey.ckSettings))
            {
                // Get all settings from DB
                settingList = settingService.GetSettings().ToList();

                // Store data in the cache
                CacheItemPolicy cacheItemPolicy = new CacheItemPolicy
                {
                    SlidingExpiration = TimeSpan.FromDays(1)
                };
                cache.Add(ConstKey.ckSettings, settingList, cacheItemPolicy);
            }
        }

        public JsonResult GetCategoryWithImage()
        {
            List<HomePageCategoriesModel> itemList = new List<HomePageCategoriesModel>();

            IEnumerable<Category> catList = categoryService.GetHomepageCategoryList();
            foreach (Category item in catList)
            {
                HomePageCategoriesModel model = new HomePageCategoriesModel
                {
                    CategoryId = item.Id.ToString(),
                    Title = item.Name,
                    ImageName = item.ImageName
                };

                itemList.Add(model);
            }

            Random rnd = new Random();
            itemList = itemList.OrderBy(x => rnd.Next()).ToList();

            return Json(itemList, JsonRequestBehavior.AllowGet);
        }

        public JsonResult GetHomepageCategoryItems(bool isLoadProducts = true)
        {
            List<HomePageCategoriesModel> itemList = new List<HomePageCategoriesModel>();

            IEnumerable<Category> catList = categoryService.GetHomepageCategoryList();
            foreach (Category item in catList)
            {
                HomePageCategoriesModel model = new HomePageCategoriesModel
                {
                    CategoryId = item.Id.ToString(),
                    Title = item.Name,
                    ImageName = item.ImageName
                };

                if (isLoadProducts)
                {
                    model.ProductList = AppUtils.GetHomepageCategoryItems(item.Id);
                }

                itemList.Add(model);
            }

            return Json(itemList, JsonRequestBehavior.AllowGet);
        }

        public JsonResult GetHomePage_FeaturedItems()
        {
            List<HomePageItem> itemList = new List<HomePageItem>();
            itemList = Application.Web.AppUtils.GetHomePage_FeaturedItems();
            Random rnd = new Random();
            itemList = itemList.OrderBy(x => rnd.Next()).ToList();

            return Json(itemList, JsonRequestBehavior.AllowGet);
        }

        public JsonResult GetHomePage_PopularItems()
        {
            List<HomePageItem> itemList = new List<HomePageItem>();
            itemList = Application.Web.AppUtils.GetHomePage_PopularItems();
            Random rnd = new Random();
            itemList = itemList.OrderBy(x => rnd.Next()).ToList();

            return Json(itemList, JsonRequestBehavior.AllowGet);
        }

        public JsonResult GetHomePage_NewArrivals()
        {
            List<HomePageItem> itemList = new List<HomePageItem>();
            itemList = Application.Web.AppUtils.GetHomePage_NewArrivals();
            Random rnd = new Random();
            itemList = itemList.OrderBy(x => rnd.Next()).ToList();

            return Json(itemList, JsonRequestBehavior.AllowGet);
        }
    }

    internal class HomePageCategoryItemSetting
    {
        public int Id { get; set; }
        public string Title { get; set; }
    }
}