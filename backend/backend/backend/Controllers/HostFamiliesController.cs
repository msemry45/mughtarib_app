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
    public class HostFamiliesController : ControllerBase
    {
        private readonly AppDbContext _context;

        public HostFamiliesController(AppDbContext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<HostFamily>>> GetHostFamilies()
        {
            return await _context.HostFamilies.ToListAsync();
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<HostFamily>> GetHostFamily(int id)
        {
            var hostFamily = await _context.HostFamilies.FindAsync(id);
            if (hostFamily == null)
            {
                return NotFound($"لا يوجد عائلة مضيفة بالمعرّف: {id}");
            }
            return hostFamily;
        }

        [HttpPost]
        public async Task<ActionResult<HostFamily>> CreateHostFamily(HostFamily hostFamily)
        {
            _context.HostFamilies.Add(hostFamily);
            await _context.SaveChangesAsync();
            return CreatedAtAction(nameof(GetHostFamily), new { id = hostFamily.HostFamilyID }, hostFamily);
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateHostFamily(int id, HostFamily hostFamily)
        {
            if (id != hostFamily.HostFamilyID)
            {
                return BadRequest("عدم تطابق معرّف العائلة المضيفة");
            }
            _context.Entry(hostFamily).State = EntityState.Modified;
            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateConcurrencyException)
            {
                if (!_context.HostFamilies.Any(h => h.HostFamilyID == id))
                {
                    return NotFound($"لا يوجد عائلة مضيفة بالمعرّف: {id}");
                }
                else
                {
                    throw;
                }
            }
            return NoContent();
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteHostFamily(int id)
        {
            var hostFamily = await _context.HostFamilies.FindAsync(id);
            if (hostFamily == null)
            {
                return NotFound($"لا يوجد عائلة مضيفة بالمعرّف: {id}");
            }
            _context.HostFamilies.Remove(hostFamily);
            await _context.SaveChangesAsync();
            return NoContent();
        }
    }
}
