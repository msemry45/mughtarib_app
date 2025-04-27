using System.ComponentModel.DataAnnotations;

namespace backend.Models
{
    public class HostFamily
    {
        [Key]
        public int HostFamilyID { get; set; }

        [MaxLength(50)]
        public string FamilyName { get; set; }

        [MaxLength(100)]
        public string Location { get; set; }

        [MaxLength(100)]
        public string Email { get; set; }

        [MaxLength(15)]
        public string PhoneNumber { get; set; }
    }
}
