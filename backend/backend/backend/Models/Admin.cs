using System.ComponentModel.DataAnnotations;

namespace backend.Models
{
    public class Admin
    {
        [Key]
        public int AdminID { get; set; }

        [MaxLength(50)]
        public string AdminName { get; set; }

        [MaxLength(100)]
        public string Email { get; set; }

        [MaxLength(15)]
        public string PhoneNumber { get; set; }
    }
}
