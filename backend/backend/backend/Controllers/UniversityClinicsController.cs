using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using backend.Data;
using backend.Models;

namespace backend.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class UniversityClinicsController : ControllerBase
    {
        private readonly AppDbContext _context;

        public UniversityClinicsController(AppDbContext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<UniversityClinic>>> GetUniversityClinics()
        {
            return await _context.UniversityClinics.ToListAsync();
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<UniversityClinic>> GetUniversityClinic(int id)
        {
            var clinic = await _context.UniversityClinics.FindAsync(id);
            if (clinic == null)
            {
                return NotFound($"لا يوجد عيادة جامعية بالمعرّف: {id}");
            }
            return clinic;
        }

        [HttpPost]
        public async Task<ActionResult<UniversityClinic>> CreateUniversityClinic(UniversityClinic clinic)
        {
            _context.UniversityClinics.Add(clinic);
            await _context.SaveChangesAsync();
            return CreatedAtAction(nameof(GetUniversityClinic), new { id = clinic.ClincID }, clinic);
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateUniversityClinic(int id, UniversityClinic clinic)
        {
            if (id != clinic.ClincID)
            {
                return BadRequest("عدم تطابق معرّف العيادة الجامعية");
            }
            _context.Entry(clinic).State = EntityState.Modified;
            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateConcurrencyException)
            {
                if (!_context.UniversityClinics.Any(c => c.ClincID == id))
                {
                    return NotFound($"لا يوجد عيادة جامعية بالمعرّف: {id}");
                }
                else
                {
                    throw;
                }
            }
            return NoContent();
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteUniversityClinic(int id)
        {
            var clinic = await _context.UniversityClinics.FindAsync(id);
            if (clinic == null)
            {
                return NotFound($"لا يوجد عيادة جامعية بالمعرّف: {id}");
            }
            _context.UniversityClinics.Remove(clinic);
            await _context.SaveChangesAsync();
            return NoContent();
        }
    }
}
