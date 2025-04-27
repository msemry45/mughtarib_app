using System.ComponentModel.DataAnnotations;

namespace backend.Models
{
    public class UniversityClinic
    {
        [Key]
        public int ClincID { get; set; }

        [MaxLength(50)]
        public string ClincName { get; set; }

        [MaxLength(100)]
        public string Location { get; set; }

        [MaxLength(15)]
        public string PhoneNumber { get; set; }
    }
}
