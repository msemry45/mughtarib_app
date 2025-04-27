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
    public class RealEstateOfficesController : ControllerBase
    {
        private readonly AppDbContext _context;

        public RealEstateOfficesController(AppDbContext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<RealEstateOffice>>> GetRealEstateOffices()
        {
            return await _context.RealEstateOffices.ToListAsync();
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<RealEstateOffice>> GetRealEstateOffice(int id)
        {
            var office = await _context.RealEstateOffices.FindAsync(id);
            if (office == null)
            {
                return NotFound($"لا يوجد مكتب عقاري بالمعرّف: {id}");
            }
            return office;
        }

        [HttpPost]
        public async Task<ActionResult<RealEstateOffice>> CreateRealEstateOffice(RealEstateOffice office)
        {
            _context.RealEstateOffices.Add(office);
            await _context.SaveChangesAsync();
            return CreatedAtAction(nameof(GetRealEstateOffice), new { id = office.OfficeID }, office);
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateRealEstateOffice(int id, RealEstateOffice office)
        {
            if (id != office.OfficeID)
            {
                return BadRequest("عدم تطابق معرّف المكتب العقاري");
            }
            _context.Entry(office).State = EntityState.Modified;
            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateConcurrencyException)
            {
                if (!_context.RealEstateOffices.Any(o => o.OfficeID == id))
                {
                    return NotFound($"لا يوجد مكتب عقاري بالمعرّف: {id}");
                }
                else
                {
                    throw;
                }
            }
            return NoContent();
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteRealEstateOffice(int id)
        {
            var office = await _context.RealEstateOffices.FindAsync(id);
            if (office == null)
            {
                return NotFound($"لا يوجد مكتب عقاري بالمعرّف: {id}");
            }
            _context.RealEstateOffices.Remove(office);
            await _context.SaveChangesAsync();
            return NoContent();
        }
    }
}
