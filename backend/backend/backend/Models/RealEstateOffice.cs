using System.ComponentModel.DataAnnotations;

namespace backend.Models
{
    public class RealEstateOffice
    {
        [Key]
        public int OfficeID { get; set; }

        [MaxLength(50)]
        public string OfficeName { get; set; }

        [MaxLength(100)]
        public string Location { get; set; }

        [MaxLength(15)]
        public string PhoneNumber { get; set; }

        [MaxLength(100)]
        public string Email { get; set; }
    }
}
