using backend.Models;
using Microsoft.EntityFrameworkCore;


namespace backend.Data
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options)
        {
        }

        public DbSet<Student> Students { get; set; }
        public DbSet<Property> Properties { get; set; }
        public DbSet<HostFamily> HostFamilies { get; set; }
        public DbSet<RealEstateOffice> RealEstateOffices { get; set; }
        public DbSet<Review> Reviews { get; set; }
        public DbSet<Message> Messages { get; set; }
        public DbSet<Admin> Admins { get; set; }
        public DbSet<UniversityClinic> UniversityClinics { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

        }
    }
}
