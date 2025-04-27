using System;
using System.ComponentModel.DataAnnotations;

namespace backend.Models
{
    public class Review
    {
        [Key]
        public int ReviewID { get; set; }

        public int Rating { get; set; }

        [MaxLength(255)]
        public string ReviewText { get; set; }

        public DateTime ReviewDate { get; set; }

        // مفاتيح خارجية
        public int PropertyID { get; set; }
        public int UserID { get; set; }

        // يمكن إضافة علاقات تنقل للـ Property والـ Student لاحقاً
    }
}
