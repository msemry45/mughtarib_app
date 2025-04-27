using System;
using System.ComponentModel.DataAnnotations;

namespace backend.Models
{
    public class Property
    {
        [Key]
        public int PropertyID { get; set; }

        public DateTime ListingDate { get; set; }

        [MaxLength(255)]
        public string Description { get; set; }

        public int NumberOfRooms { get; set; }

        [MaxLength(50)]
        public string Status { get; set; }

        [MaxLength(50)]
        public string Type { get; set; }

        [MaxLength(100)]
        public string Street { get; set; }

        [MaxLength(50)]
        public string City { get; set; }

        [MaxLength(10)]
        public string ZIP { get; set; }

        public float Price { get; set; }

        // مفاتيح خارجية اختيارية
        public int? AddressID { get; set; }
        public int? ManagedByAdminID { get; set; }

        // يمكن إضافة علاقات تنقل للعناصر المرتبطة مثل Admin أو Address لاحقاً
    }
}
