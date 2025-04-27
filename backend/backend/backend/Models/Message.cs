using System;
using System.ComponentModel.DataAnnotations;

namespace backend.Models
{
    public class Message
    {
        [Key]
        public int MessageID { get; set; }

        public DateTime Timestamp { get; set; }

        [MaxLength(255)]
        public string Content { get; set; }

        public int SentBy { get; set; }

        public int ReceivedBy { get; set; }

        // يمكن إضافة علاقات تنقل مع كيانات المستخدمين إذا تم تعريف كيان مشترك للمستخدمين
    }
}
