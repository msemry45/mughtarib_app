using System.ComponentModel.DataAnnotations;

namespace backend.Models
{
    public class LoginModel
    {
        [Required]
        public int UserID { get; set; }
        [Required]
        public string Password { get; set; }
    }
}
