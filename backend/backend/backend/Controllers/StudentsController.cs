using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using backend.Data;
using backend.Models;

namespace backend.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize] // حماية عامة لجميع نقاط النهاية في هذا الـ Controller
    public class StudentsController : ControllerBase
    {
        private readonly AppDbContext _context;

        // قائمة أرقام الأدمن (تحديثها بالأرقام الحقيقية)
        private readonly List<int> adminUniversityIds = new List<int> { 421210109, 421209665, 421204592, 421209463, 431204150 };

        public StudentsController(AppDbContext context)
        {
            _context = context;
        }

        // GET: api/Students
        [HttpGet]
        public async Task<ActionResult<IEnumerable<Student>>> GetStudents()
        {
            return await _context.Students.ToListAsync();
        }

        // GET: api/Students/{id}
        [HttpGet("{id}")]
        public async Task<ActionResult<Student>> GetStudent(int id)
        {
            var student = await _context.Students.FindAsync(id);
            if (student == null)
            {
                return NotFound($"لا يوجد طالب برقم جامعي: {id}");
            }
            return student;
        }

        // POST: api/Students
        // عملية تسجيل طالب جديد - تظل مفتوحة للجمهور
        [AllowAnonymous]
        [HttpPost]
        public async Task<ActionResult<Student>> RegisterStudent(Student student)
        {
            try
            {
                // --- تحقق من صحة الرقم الجامعي (معلق حتى نحصل الموافقة من الجامعة) ---
                // if (!ApprovedUniversityIds.Contains(student.UserID))
                // {
                //     return BadRequest("الرقم الجامعي غير معتمد");
                // }

                // تعيين الدور بناءً على الرقم الجامعي:
                if (adminUniversityIds.Contains(student.UserID))
                {
                    // الطالب ينتمي لقائمة الأدمن، يُسجّل كـ "Admin,User"
                    student.Role = "Admin,User";
                }
                else
                {
                    // باقي الطلاب يُسجّلون كـ "User" فقط
                    student.Role = "User";
                }

                _context.Students.Add(student);
                await _context.SaveChangesAsync();
                return CreatedAtAction(nameof(GetStudent), new { id = student.UserID }, student);
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Internal server error: {ex.Message}");
            }
        }

        // POST: api/Students/login
        // عملية تسجيل الدخول - تظل مفتوحة للجمهور
        [AllowAnonymous]
        [HttpPost("login")]
        public async Task<ActionResult<Student>> LoginStudent([FromBody] LoginModel loginModel)
        {
            var student = await _context.Students
                .FirstOrDefaultAsync(s => s.UserID == loginModel.UserID && s.Password == loginModel.Password);

            if (student == null)
            {
                return Unauthorized("بيانات الدخول غير صحيحة");
            }
            return Ok(student);
        }

        // PUT: api/Students/{id}
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateStudent(int id, Student student)
        {
            if (id != student.UserID)
            {
                return BadRequest("عدم تطابق الرقم الجامعي");
            }

            _context.Entry(student).State = EntityState.Modified;
            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateConcurrencyException)
            {
                if (!StudentExists(id))
                {
                    return NotFound($"لا يوجد طالب برقم جامعي: {id}");
                }
                else
                {
                    throw;
                }
            }
            return NoContent();
        }

        // DELETE: api/Students/{id}
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteStudent(int id)
        {
            var student = await _context.Students.FindAsync(id);
            if (student == null)
            {
                return NotFound($"لا يوجد طالب برقم جامعي: {id}");
            }
            _context.Students.Remove(student);
            await _context.SaveChangesAsync();
            return NoContent();
        }

        private bool StudentExists(int id)
        {
            return _context.Students.Any(e => e.UserID == id);
        }
    }
}
