using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.Configuration;
using Shipments.Api.Models;

namespace Shipments.Api.Data
{
    public class IdentitySeed
    {
        private static readonly string[] Roles =
        {
            "Client",
            "Courier",
            "Admin"
        };

        public static async Task SeedRolesAsync(IServiceProvider services)
        {
            using var scope = services.CreateScope();
            var roleManager = scope.ServiceProvider.GetRequiredService<RoleManager<IdentityRole>>();

            foreach (var role in Roles)
            {
                if (!await roleManager.RoleExistsAsync(role))
                {
                    var roleResult = await roleManager.CreateAsync(new IdentityRole(role));

                    if (!roleResult.Succeeded)
                    {
                        foreach (var error in roleResult.Errors)
                        {
                            Console.WriteLine($"[SEED ROLE ERROR] {error.Code}: {error.Description}");
                        }
                    }
                }
            }
        }

        public static async Task SeedAdminAsync(IServiceProvider services)
        {
            using var scope = services.CreateScope();

            var config = scope.ServiceProvider.GetRequiredService<IConfiguration>();
            var userManager = scope.ServiceProvider.GetRequiredService<UserManager<AppUser>>();

            var email = config["AdminSeed:Email"];
            var password = config["AdminSeed:Password"];

            Console.WriteLine($"[ADMIN SEED] Email from config: {email}");
            Console.WriteLine($"[ADMIN SEED] Password exists: {!string.IsNullOrWhiteSpace(password)}");

            if (string.IsNullOrWhiteSpace(email) || string.IsNullOrWhiteSpace(password))
            {
                Console.WriteLine("[ADMIN SEED] Email or password is empty. Skip.");
                return;
            }

            var admin = await userManager.FindByEmailAsync(email);
            Console.WriteLine($"[ADMIN SEED] Existing user found: {admin != null}");

            if (admin != null)
            {
                Console.WriteLine("[ADMIN SEED] Admin already exists. Skip create.");
                return;
            }

            admin = new AppUser
            {
                UserName = email,
                Email = email,
                MustChangePassword = true
            };

            var createResult = await userManager.CreateAsync(admin, password);
            Console.WriteLine($"[ADMIN SEED] Create result: {createResult.Succeeded}");

            if (!createResult.Succeeded)
            {
                foreach (var error in createResult.Errors)
                {
                    Console.WriteLine($"[ADMIN SEED] Create error: {error.Code} - {error.Description}");
                }

                return;
            }

            var roleResult = await userManager.AddToRoleAsync(admin, "Admin");
            Console.WriteLine($"[ADMIN SEED] Add role result: {roleResult.Succeeded}");

            if (!roleResult.Succeeded)
            {
                foreach (var error in roleResult.Errors)
                {
                    Console.WriteLine($"[ADMIN SEED] Role error: {error.Code} - {error.Description}");
                }
            }
        }
    }
}