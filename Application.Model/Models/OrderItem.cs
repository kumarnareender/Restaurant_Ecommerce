using System;

namespace Application.Model.Models
{
    public partial class OrderItem
    {
        public string Id { get; set; }
        public string OrderId { get; set; }
        public string ProductId { get; set; }
        public int Quantity { get; set; }
        public Nullable<decimal> Discount { get; set; }
        public decimal Price { get; set; }
        public Nullable<decimal> TotalPrice { get; set; }
        public string ImageUrl { get; set; }
        public System.DateTime ActionDate { get; set; }
        public string Title { get; set; }
        public Nullable<decimal> CostPrice { get; set; }
        public virtual Order Order { get; set; }
        public virtual Product Product { get; set; }
        public string Color { get; set; }
        public string Size { get; set; }
    }
}
